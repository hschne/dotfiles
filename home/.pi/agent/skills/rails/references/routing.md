# Routing

## RESTful Routes with Namespaces

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

- RESTful resources (index, show, create, update, delete)
- Namespaces for logical grouping (admin, webhooks, app)

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
