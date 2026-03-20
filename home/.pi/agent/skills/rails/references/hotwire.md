# Hotwire

Use Hotwire for server-rendered interactivity in management and admin style UIs.

## Turbo Streams

Prefer Turbo Stream templates for inline updates.

Pattern:

- wrap each item in `turbo_frame_tag dom_id(record)`
- respond with `format.turbo_stream`
- provide an HTML fallback
- keep stream templates small and explicit

```ruby
respond_to do |format|
  format.turbo_stream
  format.html { redirect_to entries_path, notice: t(".success") }
end
```

```erb
<%= turbo_stream.remove @entry %>
```

## Views

Keep queries out of views.
Views should render assigned relations, associations, and simple scopes.

Prefer:

- controller assigns `@entries = @project.entries.recent`
- view iterates and renders

Avoid:

- filtering large collections in ERB
- business rules in templates
