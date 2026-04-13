# Views

### Use Class Names Helper

**Good**:

```erb
<%= tag.div class: class_names(item: true, item__complete: item.completed?, item__over_due: !item.completed? && item.over_due?) do %>
  <%= item.name %>
<% end %>

<%= tag.div class: class_names("item", { item__complete: item.completed?, item__over_due: !item.completed? && item.over_due? }) do %>
  <%= item.name %>
<% end %>

<%= tag.div class: ["item", { item__complete: item.completed?, item__over_due: !item.completed? && item.over_due? }] do %>
  <%= item.name %>
<% end %>
```

### Use Hotwire: Turbo + Stimulus

**Turbo for page updates:**

```erb
<%= turbo_stream_from @cloud %>

<div id="<%= dom_id(@cloud) %>">
  <%= render "cloud", cloud: @cloud %>
</div>
```

```ruby
# In job or controller
cloud.update!(state: :generated)
Turbo::StreamsChannel.broadcast_refresh_to(cloud)
```

**Stimulus for JavaScript sprinkles:**

```erb
<div data-controller="timer">
  <button data-action="timer#start">Start</button>
  <span data-timer-target="display">0:00</span>
</div>
```

```javascript
// app/javascript/controllers/timer_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display"];

  start() {
    // Timer logic
  }

  #privateFunction() {
    // private function content
  }
}
```

### Use Turbo Stream Templates

**Always use `.turbo_stream.erb` templates instead of inline turbo stream rendering in controllers.**

**Bad:**

```ruby
def create
  @block = Current.user.blocks.create!(block_params)

  respond_to do |format|
    format.html { redirect_to blocks_path }
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.update("new_block", ""),
        turbo_stream.append("blocks", partial: "blocks/block_frame", locals: { block: @block })
      ]
    end
  end
end
```

**Good:**

```ruby
# app/controllers/blocks_controller.rb
def create
  @block = Current.user.blocks.create!(block_params)

  respond_to do |format|
    format.html { redirect_to blocks_path }
    format.turbo_stream
  end
end
```

```html+eruby
<%# app/views/blocks/create.turbo_stream.erb %>
<%= turbo_stream.update "new_block", "" %>

<%= turbo_stream.append "blocks" do %>
  <%= render "block_frame", block: @block %>
<% end %>
```

Why:

- Keeps controllers thin (no view logic)
- Templates are easier to read and modify
- Follows Rails convention (views belong in views/)
- Easier to test and debug

### Never Nest `button_to` Inside `form_with`

`button_to` renders its own `<form>` element. Placing it inside a `form_with` block creates nested `<form>` tags, which is invalid HTML. Browsers silently discard the inner form and submit the outer one instead — so a Delete button triggers Save, not delete.

**Bad — nested forms, delete triggers update:**

```erb
<%= form_with model: block do |f| %>
  <article>...</article>

  <div class="modal-action">
    <%# DON'T: button_to inside form_with renders a nested <form> %>
    <%= button_to block_path(block), method: :delete, class: "btn btn-ghost text-error" do %>
      Delete
    <% end %>

    <%= f.submit "Save Changes" %>
  </div>
<% end %>
```

**Good — delete form is a sibling, not a child:**

```erb
<%= form_with model: block do |f| %>
  <article>...</article>

  <div class="modal-action">
    <%= f.submit "Save Changes" %>
  </div>
<% end %>

<%# button_to lives outside form_with, at the same level %>
<% if block.persisted? %>
  <%= button_to block_path(block), method: :delete, class: "btn btn-ghost text-error",
      data: { turbo_confirm: "Delete this block?" } do %>
    Delete
  <% end %>
<% end %>
```

When working inside a Turbo Frame (e.g. a modal), both the `form_with` and the `button_to` can still be children of the same `turbo_frame_tag` — just not nested inside each other.

### Database Queries from Views

**Good:** Simple associations and scopes

```erb
<% @participant.clouds.recent.each do |cloud| %>
  <%= render "cloud", cloud: %>
<% end %>
```

**Bad:** N+1 queries, complex logic in views

```erb
<!-- DON'T: complex query logic -->
<% @clouds.select { |c| c.participant.premium? && c.state.in?(%w[generated]) } %>
```

**Instead:** Use scope

```ruby
# Model
scope :recent, -> { order(created_at: :desc) }

# Controller
@clouds = @participant.clouds.recent

# View
<% @clouds.each do |cloud| %>
  <%= render "cloud", cloud: %>
<% end %>
```
