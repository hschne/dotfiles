# Inertia and Svelte

This reference covers Rails-side conventions for apps that use Inertia with Svelte. For CSS and styling patterns, also read the `tailwind` skill.

## Props

- Expect server-side snake_case props to arrive as camelCase in frontend components.
- Design props intentionally and keep them explicit.

## Forms

Prefer the Inertia `Form` component over ad hoc JavaScript form handling and over `useForm` when simple forms are enough.

## Frontend Logic

- Prefer backend-driven state.
- Compute permissions, derived status, and business booleans in Ruby.
- Let javascript frameworks focus on rendering and local UI state.

Backend should own:

- authorization flags
- business rules
- derived counts and statuses
- formatted display data when helpful

Frontend should own:

- open/closed UI state
- transitions and animation
- submission/loading state
- event handlers

## Svelte Conventions

- prefer constant function declarations
- prefer early returns over nested branching
- keep components presentation-focused when backend can compute state
