/**
 * Summary Extension
 *
 * Provides a /summary command that generates a distilled session note
 * and saves it to ~/Documents/Wiki/memory/sessions/.
 *
 * The generated note captures:
 * - What was worked on
 * - Key decisions made and their rationale
 * - Technical findings and conclusions
 * - Commands, scripts, or snippets worth keeping
 * - Open questions or next steps
 *
 * Files are saved as: YY-MM-DD-HHmm-<slug>.md
 * and immediately indexed with `qmd update`.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { join } from "node:path";

const SESSIONS_DIR = join(
  process.env.HOME ?? "~",
  "Documents/Wiki/memory/sessions",
);

const STATUS_KEY = "summary";
const ICON = "󰏪"; // Nerd Font icon for note/alert

export default function (pi: ExtensionAPI) {
  let summaryRun = false;

  pi.registerCommand("summary", {
    description:
      "Generate a distilled session note and save to memory/sessions/",
    handler: async (args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is busy — wait for it to finish first", "warning");
        return;
      }

      summaryRun = true;
      updateStatus(ctx);

      const now = new Date();
      const date = now.toISOString().slice(2, 10); // YY-MM-DD
      const hhmm = now.toTimeString().slice(0, 5).replace(":", ""); // HHmm
      const timestamp = `${date}-${hhmm}`; // YY-MM-DD-HHmm

      ctx.ui.setStatus(STATUS_KEY, "Generating session note...");

      // Let the LLM choose the slug and write the file itself
      pi.sendUserMessage([
        {
          type: "text",
          text: `Please generate a session summary note for this session.

1. First, pick a short descriptive slug for the filename — lowercase, hyphens only, max 5 words
   (e.g. "mapit-phase-refactor", "syncthing-ds115j-fix", "qmd-wiki-setup").
   The slug should capture the main topic of this session.

2. Save the note to: ${SESSIONS_DIR}/${timestamp}-<your-slug>.md

Use this structure:

# <descriptive title>

**Date:** ${new Date().toISOString().slice(0, 10)}
**Topic:** <one-line description>

## What we did
<brief narrative of what was worked on>

## Key decisions
<bullet list of decisions made and their rationale — focus on the WHY>

## Findings
<technical discoveries, conclusions from research, things learned>

## Snippets
<any commands, scripts, configs, or code worth keeping — only if relevant>

## Open questions / next steps
<unresolved questions, follow-up tasks>

---
Rules:
- Be concise. This is a reference document, not a transcript.
- Skip sections that have nothing worth capturing (omit the heading entirely).
- Focus on durable knowledge — things useful in a future session.
- Do NOT summarize the conversation itself. Extract the signal.
- After writing the file, run: qmd update
`,
        },
      ]);

      ctx.ui.setStatus(STATUS_KEY, "");
    },
  });

  pi.on("session_start", async (_, ctx) => {
    summaryRun = false;
    updateStatus(ctx);
  });

  pi.on("session_shutdown", (_, ctx) => {
    ctx.ui.setStatus(STATUS_KEY, undefined);
  });

  function updateStatus(ctx: any) {
    if (summaryRun) {
      ctx.ui.setStatus(STATUS_KEY, undefined);
    } else {
      ctx.ui.setStatus(
        STATUS_KEY,
        ctx.ui.theme.fg("error", `${ICON} no summary`),
      );
    }
  }
}
