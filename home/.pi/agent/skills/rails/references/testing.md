# Testing Patterns

## Minitest > Rspec

Use Minitest for simpler DSL and readability.

## Test File Organization

Test files mirror the app structure — one test file per controller or model. **Never create cross-cutting "feature" test files** (e.g. `guest_access_test.rb`, `authorization_test.rb`). Tests for a controller's behavior belong in that controller's test file.

**Bad:**

```bash
test/controllers/guest_access_test.rb      # ✗ feature-based grouping
test/controllers/authorization_test.rb     # ✗ cross-cutting concern
```

**Good:**

```bash
test/controllers/pages_controller_test.rb  # ✓ tests PagesController
test/controllers/votes_controller_test.rb  # ✓ tests VotesController
test/models/entry_test.rb                  # ✓ tests Entry model
```

## Model Tests: Logic & Validations

```ruby
class IdeaTest < ActiveSupport::TestCase
  setup do
    @project = projects(:default)
    @user = users(:default)
  end

  test "valid idea placement within polygon project boundary" do
    @project.update!(
      geometry_json: {
        type: "Polygon",
        coordinates: [[[-1, -1], [1, -1], [1, 1], [-1, 1], [-1, -1]]]
      },
      geometry_type: "polygon"
    )

    idea = Idea.new(
      project: @project,
      user: @user,
      title: "Inside",
      description: "description",
      geometry_json: {type: "Point", coordinates: [0, 0]}
    )
    assert idea.valid?
  end

  test "invalid idea placement outside polygon project boundary" do
    @project.update!(
      geometry_json: {
        type: "Polygon",
        coordinates: [[[-1, -1], [1, -1], [1, 1], [-1, 1], [-1, -1]]]
      },
      geometry_type: "polygon"
    )

    idea = Idea.new(
      project: @project,
      user: @user,
      title: "Outside",
      description: "description",
      geometry_json: {type: "Point", coordinates: [2, 2]}
    )
    assert_not idea.valid?
  end
```

## Request Tests: HTTP Behavior

```ruby
class Identity::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(users(:default))
  end

  test "should get edit" do
    get edit_identity_email_url
    assert_response :success
  end

  test "should update email" do
    patch identity_email_url, params: {email: "new_email@hey.com", password_challenge: "Secret1*3*5*"}
    assert_redirected_to root_url
  end


```

## System Tests: Not Needed

**Do not use System tests**, they are brittle and offer no use for us.

## Use Simple Fixtures

Prefer simple fixtures over factories and creating models on the fly. Modify fixtures as necessary in the tests.

**Bad: Multiple fixtures, non-descriptive test data**

```yaml
one:
  project: one
  title: Community Garden
  description: We should create a community garden in the neighborhood park
  geometry_json: '{"type":"Point","coordinates":[16.37252442681125,48.20881050095637]}'

two:
  project: one
  title: Bike Lanes
  description: Add protected bike lanes on Main Street for safer cycling
  geometry_json: '{"type":"Point","coordinates":[16.37352442681125,48.20981050095637]}'
```

**Good: Default fixture with minimal descriptive test data**

```yaml
# test/fixtures/projects.yml
default:
  title: title
  description: description
  geometry_json: '{"type":"Point","coordinates":[0,0]}'
```

```ruby
# Usage in tests
project = projects(:default)
project.update(title 'updated title')
```

## Fixtures Over Creating Data

Prefer updating existing fixtures over creating new records in tests or using factories. Fixtures provide a consistent, shared state and are faster.

However, **do not eagerly create new fixtures**. For data that is used in only a single or a handful of tests, creating data in tests is preferred.

**Bad:**

```ruby
# Wipes out fixtures, creates new records
setup do
  User.destroy_all
  @user = User.create!(email: "test@example.com")
end
```

**Good:**

```ruby
# Uses fixture, modifies if needed
setup do
  @user = users(:default)
end

test "admin can delete" do
  @user.update!(role: :admin) # Modify for this test
end
```

## Avoid Excessive Data Creation

If you find yourself creating data in a loop - stop. Reconsider whether you can rewrite the test or configure the system under test to avoid excessive data creation.

**Bad**:

```ruby
test "entries are paginated" do
  # Bad, creates a lot of data and is slow
  12.times do |i|
    Entry.create!(...)
  end

  sign_in_as @user
  get manage_entries_path

  assert_response :success
end
```

**Good**:

```ruby
test "entries are paginated" do

  Entry.create!(...)
  Entry.create!(...)

  sign_in_as @user
  # Test pagination without excessive data setup through configuration
  get manage_entries_path, params: { page_size: 2 }

  assert_response :success
end
```

## Avoid Testing Response Content

Reading page content is brittle and slow, avoid it. 

**Bad**:
```ruby
# Needs to render the full page, and breaks easily!
assert_includes response.body, I18n.t("shared.pagination.next")
assert_includes response.body, I18n.t("shared.pagination.page_info", current: 1, total: 2)
```


## Prefer Flat Assertions Over Nested `assert_difference`

Don't nest `assert_difference` / `assert_no_difference` blocks. They're hard to read and obscure what's being tested. Instead, call the action, then assert on the result directly.

**Bad:**

```ruby
assert_difference("GuestSession.count", 1) do
  assert_difference("PendingEntry.count", 1) do
    assert_no_difference("Entry.count") do
      assert form.save
    end
  end
end
```

**Good:**

```ruby
assert form.save

assert GuestSession.exists?(email: "guest@example.com")
assert PendingEntry.exists?(guest_session: form.new_guest_session, project: @project)
```

## Don't Test Framework Behavior

**Skip these tests:**

- ActiveRecord callbacks (framework tests these)
- Basic CRUD (framework tests these)
- Model associations (too simple to break)
- Generated code (don't test the generator output)

**Test these:**

- Custom validations
- Business logic methods
- Controller responses
- Integration flows



