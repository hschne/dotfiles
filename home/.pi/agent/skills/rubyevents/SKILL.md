---
name: rubyevents
description: "Add talks and videos to rubyevents.org. Use when creating meetups, adding videos, or adding new speakers."
---

# RubyEvents Skill

Repo: `https://github.com/rubyevents/rubyevents` (upstream)
Fork: `https://github.com/hschne/rubyevents` (origin)
Local: `/home/hschne/Source/forks/rubyevents`

## Critical Rules

**Always verify the diff is clean before committing:**

```bash
git diff --stat
git diff data/speakers.yml 
```

## Fetching Videos from a YouTube Playlist

Fetch playlist items:

```bash
YOUTUBE_API_KEY=<key> bin/rails runner scripts/create_videos_yml.rb <playlist_id>
```

This outputs YAML for each video with: `title`, `raw_title`, `video_id`, `video_provider`, `published_at`, `description`. Use this as reference — **do not paste it directly**, merge it into the existing entry.

## Vienna.rb Meetup Structure

Data lives in a single `videos.yml` for the whole meetup series:

- `data/vienna-rb/vienna-rb-meetup/videos.yml`

Each meetup edition is one top-level entry with `video_provider: "children"` and individual talks nested under `talks:`.

### Vienna.rb edition entry fields

```yaml
- id: "vienna-rb-<month>-<year>"
  title: "Vienna.rb <Month> <Year>"
  event_name: "Vienna.rb <Month> <Year>"
  date: "<YYYY-MM-DD>" # actual meetup date
  announced_at: "<YYYY-MM-DD>" # when it was announced
  published_at: "<YYYY-MM-DD>" # when videos were published (TODAY if just uploaded)
  video_provider: "children"
  video_id: "vienna-rb-<month>-<year>"
  thumbnail_xs: "<meetup photo URL>"
  thumbnail_sm: "<meetup photo URL>"
  thumbnail_md: "<meetup photo URL>"
  thumbnail_lg: "<meetup photo URL>"
  thumbnail_xl: "<meetup photo URL>"
  description: |-
    <Full meetup description from meetup.com, including talk summaries>
  talks:
    - title: "<Talk Title>"
      event_name: "Vienna.rb <Month> <Year>"
      date: "<YYYY-MM-DD>"
      announced_at: "<YYYY-MM-DD>"
      published_at: "<YYYY-MM-DD>"
      speakers:
        - Speaker Name
      id: "<speaker-slug>-vienna-rb-<month>-<year>"
      video_id: "<youtube-video-id>" # real ID once uploaded
      video_provider: "youtube" # or "scheduled" / "not_recorded"
      description: |-
        <Talk description from meetup.com>
```

### video_provider values

| Situation                 | Edition `video_provider` | Talk `video_provider` |
| ------------------------- | ------------------------ | --------------------- |
| Videos uploaded           | `children`               | `youtube`             |
| Planned, not yet recorded | `children`               | `scheduled`           |
| Not recorded              | `children`               | `not_recorded`        |
| One long video with cues  | `youtube`                | `parent`              |


## Adding a New Speaker

```yaml
- name: "First Last"
  github: "github-username"
  slug: "first-last"
```

Optional fields: `twitter`, `bio`, `website`, `linkedin`.

To find the right alphabetical position:

```bash
grep -n "^- name: \"<nearby name>" data/speakers.yml
```

## Workflow for Adding Meetup Videos

1. **Check YouTube playlist** to get video IDs and descriptions:

   ```bash
   YOUTUBE_API_KEY=<key> bin/rails runner scripts/create_videos_yml.rb <playlist_id>
   ```

2. **Update `videos.yml`** — change existing `scheduled` entries to `youtube`, set real `video_id`, update `published_at`, add descriptions. Use the descriptions from meetup.com (not YouTube), as they are more complete.

3. **Update the parent edition entry** — set `published_at`, add thumbnail URLs from meetup.com, update any `TBD` descriptions.

4. **Add missing speakers** to `speakers.yml` — output snippet, let user insert manually.

5. **Validate:**

   ```bash
   YOUTUBE_API_KEY=<key> bin/rails validate:videos 2>&1 | tail -3
   ```

6. **Git workflow** — always branch off a clean sync with upstream:

   ```bash
   git fetch upstream
   git checkout main
   git reset --hard upstream/main
   git push origin main --force  # only if main was dirty
   git checkout -b <branch-name>
   ```

7. **Commit only the files you actually changed:**

   ```bash
   git add data/vienna-rb/vienna-rb-meetup/videos.yml
   git add data/speakers.yml  # only if you're sure the diff is clean
   git commit -m "Add Vienna.rb <Month> <Year> videos"
   ```

8. **Push and open PR against upstream:**
   ```bash
   git push origin <branch-name>
   gh pr create --repo rubyevents/rubyevents --title "..." --body "..." --head hschne:<branch-name>
   ```

## Meetup Photo Thumbnails

Meetup.com photo URLs look like:
`https://secure.meetupstatic.com/photos/event/.../highres_<id>.webp?w=750`

Use the same URL for all five thumbnail sizes (`xs`, `sm`, `md`, `lg`, `xl`).
