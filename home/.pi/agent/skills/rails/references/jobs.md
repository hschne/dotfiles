# Jobs

## Jobs Orchestrate, Models Execute

**Good separation:**

```ruby
# Job orchestrates workflow
class CloudGenerationJob < ApplicationJob
  def perform(cloud)
    step :generate
  end

  private

  def generate(_step)
    generator = Cloud::CardGenerator.new(cloud)
    io = generator.generate  # Delegates to model class
    cloud.generated_image.attach(io:, filename: "...")
  end
end

# Model class executes business logic
class Cloud::CardGenerator
  def initialize(cloud)
    @cloud = cloud
  end

  def generate
    # Complex API/processing logic here
    # Returns IO object or raises exception
    StringIO.new(decoded_image_data)
  end

  private

  def build_prompt
    # ...
  end

  def call_api(prompt)
    # ...
  end
end
```

**Don't put complex logic in jobs.** Jobs are for orchestration. Model classes handle complexity.

## Error Handling in Jobs

```ruby
def moderate(_step)
  # Do work
  cloud.update!(state: :analyzed)
rescue => err
  Rails.error.report(err, handled: true)  # Sends to Sentry if configured
  cloud.update!(state: :failed, failure_reason: err.message)
end
```

Always:

- Catch errors with `rescue => err`
- Report to error tracking (Rails.error.report)
- Update model state to reflect failure
- Don't re-raise unless you want the entire job to fail
