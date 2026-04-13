# Policies

## Record Type

Policies should receive their own record type. Do not pass a different record and branch with `is_a?`.

Good:

```ruby
@vote = current_user.votes.find_or_initialize_by(idea: @idea)
authorize @vote
```

Bad:

```ruby
authorize @idea, policy_class: VotePolicy
```

## Authorize Return Value

Use the return value from `authorize` directly when it improves clarity.

```ruby
@idea = authorize(@project.ideas.find(params[:id]))
```

## Alias Similar Policy Methods

Prefer `alias_method` for actions that share the same rules.

```ruby
def create?
  user.present?
end
alias_method :new?, :create?
```
