# Routing

## RESTful Routes with Namespaces

Prefer using RESTful routes over inventing new action verbs or one-off controller actions.

**Good**:
```ruby
Rails.application.routes.draw do
  root "clouds#index"

  # Public routes
  resources :clouds, only: [:index, :show]

  # Participant-scoped routes
  namespace :app do
    resources :projects, only: %i[index show] do
      resources :ideas
    end
  end
end
```

**Route patterns:**

- RESTful resources (index, show, create, update, destroy)
- Namespaces for logical grouping (admin, webhooks, app)
- Singular `resource` when there is only one logical thing in that scope

## Prefer Default Resource Verbs

If a page is just another state of an existing resource, prefer the default REST actions (`new`, `show`, `edit`, `create`, `update`, `destroy`) instead of inventing custom route names.

This matters especially for flows like:
- “check your email” after submitting a sign-in form
- confirmation/result pages
- stateful setup screens

**Good**:
```ruby
namespace :sessions do
  resource :passwordless, only: %i[new show edit create]
end
```

- `new` = form to request the magic link
- `create` = submit the form
- `show` = confirmation / check-your-email page
- `edit` = consume the signed link

### Bad: custom collection/member actions for standard page states

**Bad**:
```ruby
namespace :sessions do
  resource :passwordless, only: %i[new edit create] do
    get :sent, on: :collection
  end
end
```

Why this is bad:
- `sent` is not a business resource, just a page/state
- Rails already gives you `show` for that
- custom verbs make routes harder to guess and controllers less conventional

Prefer:
```ruby
namespace :sessions do
  resource :passwordless, only: %i[new show edit create]
end
```

### Bad: making one action/template serve multiple pages via params/flash

Avoid routing that forces one controller action and template to branch into totally different screens.

**Bad**:
```ruby
# controller
redirect_to new_sessions_passwordless_path(email_hint: params[:email]), notice: "Sent"

# view
<% if flash[:notice].present? %>
  <!-- confirmation page -->
<% else %>
  <!-- form page -->
<% end %>
```

Why this is bad:
- one route is pretending to be two pages
- view behavior depends on flash/flags instead of the action being rendered
- harder to reason about, test, and maintain
- pushes screen/state concerns into incidental controller data

Prefer:
```ruby
# controller
redirect_to sessions_passwordless_path(email_hint: params[:email])

# views
# app/views/sessions/passwordlesses/new.html.erb   -> form only
# app/views/sessions/passwordlesses/show.html.erb  -> confirmation only
```

Rule of thumb:
- If the user sees a meaningfully different page, give it its own action/view.
- First ask: can this be `show`/`edit`/`new` on the existing resource?
- Only add custom actions when the action is truly outside the standard CRUD/state vocabulary.

## Resources over Actions

Instead of custom actions on controllers, use module-scoped controllers for a resource-centric approach.

```ruby
resources :sources, except: %i[show] do
  scope module: :sources do
    resource :duplication, only: %i[new]
  end

  collection do
    scope module: :sources do
      resource :script_verification, only: %i[create]
    end
  end
end
```
