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

## Keep `setup` Minimal

Only put data in `setup` that is used by the **majority** of tests in the file. Data used by only one or two tests should be defined locally inside those tests.

**Bad:**

```ruby
setup do
  @project = projects(:default)
  @valid_params = {title: "Title", description: "Desc"}  # only used in 2 tests
  @other_params = {name: "Guest", email: "g@example.com"} # only used in 1 test
end
```

**Good:**

```ruby
setup do
  @project = projects(:default)
end

test "creates with valid params" do
  valid_params = {title: "Title", description: "Desc"}
  post project_entries_path(@project), params: {entry: valid_params}
  assert_response :redirect
end
```

## No Comments in Tests

Tests are documentation themselves. Do not add section headers, inline comments, or explanatory notes. The test name explains what is being tested.

**Bad:**

```ruby
# Location step
test "valid location advances" do ...

# Back navigation
test "back from details" do ...
```

**Good:**

```ruby
test "valid location advances" do ...
test "back from details" do ...
```

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


## No Numbers in Variable Names

Don't use numbered suffixes like `entry1`, `vote2`. Use descriptive names that reflect the role in the test.

**Bad:**

```ruby
entry1 = build_entry
entry2 = build_entry
vote1 = Vote.create!(entry: entry1, user: @user)
vote2 = Vote.create!(entry: entry2, user: @user)
assert_equal vote2, @guest.latest_vote
```

**Good:**

```ruby
older_entry = build_entry
newer_entry = build_entry
older_vote = Vote.create!(entry: older_entry, user: @user)
newer_vote = Vote.create!(entry: newer_entry, user: @user)
assert_equal newer_vote, @guest.latest_vote
```

## No Assertions Inside Blocks

Don't put assertions inside `travel`, `assert_difference`, or other blocks. Assert after the block so failures are clear and the assertion is not lost in nesting.

**Bad:**

```ruby
travel 1.second do
  entry = build_entry
  Entry::Guest.create!(entry:, user_guest: @guest)
  assert_equal entry, @guest.latest_entry
end
```

**Good:**

```ruby
later_entry = nil
travel 1.second do
  later_entry = build_entry
  Entry::Guest.create!(entry: later_entry, user_guest: @guest)
end
assert_equal later_entry, @guest.latest_entry
```

## Move Test Helpers to Private

Helper methods used across tests in a file belong in a `private` section at the bottom, not inline before the tests.

**Bad:**

```ruby
class EntryTest < ActiveSupport::TestCase
  def build_entry
    Entry.create!(...)
  end

  test "visibility is :visible" do
    assert_equal :visible, build_entry.visibility
  end
end
```

**Good:**

```ruby
class EntryTest < ActiveSupport::TestCase
  test "visibility is :visible" do
    assert_equal :visible, build_entry.visibility
  end

  private

  def build_entry
    Entry.create!(...)
  end
end
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

## Don't Widen Visibility for Tests

Never make a method `public` solely so tests can assert on it. If a method is only called internally, keep it private and assert through the public API or the database.

**Bad**:

```ruby
class Importer
  # Only used internally, but public so tests can check intermediate state
  def parsed_rows
    @parsed_rows
  end
end
```

**Good:**

```ruby
assert importer.save
assert_equal 3, Entry.count
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



