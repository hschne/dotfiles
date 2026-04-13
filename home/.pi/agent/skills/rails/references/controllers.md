# Controllers

Use this reference when writing or refactoring controllers.

## Order

Always follow this order in controller files:

```ruby
class ProjectsController < ApplicationController
  # 1. Concerns in alphabetical order
  include Authentication,
  include Maptiler
  include Pundit::Authorization

  # 2. Various Framework & Utility methods
  allow_browser versions: Browserslist.browsers
  allow_unauthenticated_access only: %i[index show]
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # 3. Callbacks
  before_action :set_project

  # 4. Layout
  layout "app"

  # 5. Actions
  def index
  end

  def show
  end

  # 6. Private helpers and setters
  private

  def set_project
    @project = Project.find(params[:id])
  end
end
```

## Keep Controllers Thin

Controller actions should contain 5-10 lines per action and not contain business logic.

```ruby
class Participant::CloudsController < Participant::ApplicationController
  def new
    redirect_to home_path unless @participant.can_generate_cloud?
  end

  def create
    return head 422 unless @participant.can_generate_cloud?

    blob = ActiveStorage::Blob.find_signed(params[:cloud][:blob_signed_id])
    return head 422 unless blob

    cloud = @participant.clouds.create do
      it.image.attach(blob)
    end

    CloudGenerationJob.perform_later(cloud)

    redirect_to cloud_path(cloud)
  end

  def update
    cloud = @participant.clouds.find(params[:id])
    Cloud.transaction do
      @participant.clouds.update_all(picked: false)
      cloud.update_column(:picked, true)
    end

    redirect_to home_path
  end
end
```

They must not contain:
- Business logic
- Complex conditionals
- Multiple model operations 
- Data transformation

## Avoid Custom Actions.

Prefer a nested CRUD controller over a custom action like ProjectsController#archive.

## Use Namespace Controllers for Scoping

**Pattern:**

```ruby
# app/controllers/participant/application_controller.rb
class Participant::ApplicationController < ::ApplicationController
  before_action :set_participant

  private

  def set_participant
    @participant = ::Participant.find_by!(access_token: params[:access_token])
  end
end

# app/controllers/participant/clouds_controller.rb
class Participant::CloudsController < Participant::ApplicationController
  # @participant is automatically set
  def index
    @clouds = @participant.clouds.recent
  end
end
```

All routes under `Participant::` are automatically scoped. No need for concerns or custom modules.

## Return Early, Use Guard Clauses

**Bad:**

```ruby
def create
  if user.premium?
    if params[:name].present?
      if validate_input
        cloud = create_cloud
        return redirect_to cloud
      end
    end
  end
  head 422
end
```

**Good:**

```ruby
def create
  return head 401 unless @participant.premium?
  return head 422 unless params[:name].present?
  return head 422 unless validate_input

  cloud = @participant.clouds.create!(params.permit(:name))
  redirect_to cloud
end
```

Guard clauses make the happy path obvious.
