# Models

This reference details how to organize and structure Rails models.

## Order

Always follow this order in model files:

```ruby
class Project < ApplicationRecord
  # 1. Concerns, Gems and DSL extensions
  include Mappable
  extend FriendlyId
  friendly_id :title, use: :slugged

  # 2. Associations
  belongs_to :account
  has_many :ideas, dependent: :destroy

  # 3. Enums (for state)
  enum :state, %w[uploaded analyzing analyzed generating generated failed].index_by(&:itself)

  # 3.5 compositions
  composed_of :duration,
    class_name: "Duration",
    mapping: {duration: :minutes},
    converter: ->(value) { Duration.new(value) },
    allow_nil: true

  # 4. Normalization (Rails 8+)
  normalizes :name, with: ->(name) { name.strip }

  # 5. Validations
  validates :name, :state, presence: true
  validates :participant_id, presence: true

  # 6. Scopes
  scope :generated, -> { where(state: :generated) }
  scope :picked, -> { where(picked: true) }
  scope :recent, -> { order(created_at: :desc) }

  # 7. Callbacks
  before_create do
    self.state ||= :uploaded
  end

  # 8. Delegated methods
  delegate :email, to: :participant, prefix: true

  # 9. Public instance methods
  def ready_to_generate?
    analyzed? && !generating?
  end

  # 10. Private methods
  private

  def generate_filename
    "cloud-#{participant.slug}-#{id}.png"
  end
end
```

## Use Enums for State

**Always use enums for states.** No string columns like `status` or `state_string`.

```ruby
class Idea < ApplicationRecord
  enum :state, %w[uploaded analyzing analyzed generating generated failed].index_by(&:itself)
end

# Usage:
cloud.uploaded?          # Predicate method
cloud.generating!        # Bang method (update + save)
Cloud.generated.count    # Scope
```

Why: Type-safe, gives you predicate methods for free, database-efficient.

## Use `normalizes` for Data Cleanup

**Rails 8 feature.** Automatically clean data before validation.

```ruby
class User < ApplicationRecord
  normalizes :email, with: ->(email) { email.strip.downcase }
end

# Before save:
participant = Participant.new(email: "  USER@EXAMPLE.COM  ")
participant.save
participant.email  # → "user@example.com"
```

## Thin Models, Smart Organization

**Model should not be 100+ lines.** If it is, extract to namespaced classes or concerns (if reusable).

**Bad (Model too fat):**

```ruby
class Cloud < ApplicationRecord
  def generate_card_image
    # 50 lines of API logic
    # 20 lines of image processing
    # 30 lines of error handling
  end

  def check_nsfw
    # 40 lines of moderation logic
  end

  def upload_to_storage
    # 30 lines of storage logic
  end
end
```

**Good (Extracted to namespaced classes):**

```ruby
class Cloud < ApplicationRecord
  # Model: just data and simple methods
  def ready_to_generate?
    analyzed?
  end
end

class Cloud::CardGenerator
  def initialize(cloud, api_key: GeminiConfig.api_key)
    @cloud = cloud
    @api_key = api_key
  end

  def generate
    # Complex API logic here, returns IO object
  end
end

class Cloud::NSFWDetector
  def initialize(cloud, api_key: GeminiConfig.api_key)
    @cloud = cloud
    @api_key = api_key
  end

  def check
    # Moderation logic, returns true/false
  end
end
```

**When to extract:**

- Any method over 15 lines
- Any method calling external APIs
- Any complex calculation
- Anything reusable

**How to structure:**

```ruby
# app/models/cloud/card_generator.rb
class Cloud::CardGenerator
  private attr_reader :cloud, :api_key

  def initialize(cloud, api_key: GeminiConfig.api_key)
    @cloud = cloud
    @api_key = api_key
  end

  def generate
    # Public method that returns simple value or raises
    prompt = build_prompt
    response = call_api(prompt)
    decode_image(response)
  end

  private

  def build_prompt
    # ...
  end

  def call_api(prompt)
    # ...
  end

  def decode_image(response)
    # ...
  end
end
```

Use `private attr_reader` for internal state. Delegates to related objects. Returns simple values (IO, strings, booleans). Raises exceptions on error (don't return error objects).

## Use Counter Caches

**Every has_many should have a counter cache.**

```ruby
class Participant < ApplicationRecord
  has_many :clouds, dependent: :destroy
  has_many :invitations, dependent: :destroy
end

class Cloud < ApplicationRecord
  belongs_to :participant, counter_cache: true
end

class Invitation < ApplicationRecord
  belongs_to :participant, counter_cache: true
end

# No N+1 queries. Count is always up-to-date.
participant.clouds_count    # Fast, no query
participant.invitations_count
```

## Callbacks: Use Sparingly

**Callbacks are okay for simple things. Not for workflows.**

Good use:

```ruby
class Participant < ApplicationRecord
  before_create do
    self.access_token ||= Nanoid.generate(size: 6)
  end

  before_save do
    self.slug = nil if name_changed?  # Friendly ID will regenerate
  end
end
```

Bad use:

```ruby
# DON'T: Complex workflow in callback
class Cloud < ApplicationRecord
  after_create do
    CloudGenerationJob.perform_later(self)
    Mailer.notify_created(self).deliver_later
    Metrics.record_cloud_created(self)
  end
end
```

**Instead use:** A job or form object for workflows.
