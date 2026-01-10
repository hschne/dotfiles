import type { Plugin } from "@opencode-ai/plugin"

function extractPreview(text: string): string {
  const cleanText = text
    .replace(/```[\s\S]*?```/g, "")
    .replace(/`[^`]*`/g, "")
    .replace(/\n/g, " ")
    .replace(/\s+/g, " ")
    .trim()

  const words = cleanText.split(" ").filter(w => w.length > 0)
  if (words.length === 0) return "Task Completed"

  return words.slice(0, 5).join(" ") + (words.length > 5 ? "..." : "")
}

function getLastAssistantText(messages: any[]): string | null {
  if (messages.length === 0) return null

  const lastMessage = messages[messages.length - 1]
  if (lastMessage.info.role !== "assistant") return null

  const parts = lastMessage.parts as any[]
  const textParts = parts.filter(p => p.type === "text")
  if (textParts.length === 0) return null

  return textParts[textParts.length - 1].text
}

export const NotifyPlugin: Plugin = async ({ client, $ }) => {
  async function isSubagent(sessionID: string): Promise<boolean> {
    const result = await client.session.get({ path: { id: sessionID } })
    return !!result.data?.parentID
  }

  async function getMessagePreview(sessionID: string): Promise<string> {
    const response = await client.session.messages({ path: { id: sessionID } })
    const lastText = getLastAssistantText(response.data || [])
    return lastText ? extractPreview(lastText) : "Task Completed"
  }

  async function sendNotification(title: string, message: string, urgency: "low" | "normal" | "critical" = "normal") {
    await $`notify-send -u ${urgency} "${title}" "${message}"`
  }

  return {
    async event(input) {
      const { event } = input
      
      if (event.type === "session.updated") {
        const sessionID = event.properties.sessionID
        if (await isSubagent(sessionID)) return

        const status = event.properties.info.status

        if (status === "waiting_for_input") {
          await sendNotification("OpenCode", "Waiting for your input...", "normal")
        } else if (status === "error" || status === "failed") {
          await sendNotification("OpenCode Error", "Session encountered an error", "critical")
        }
      } else if (event.type === "session.idle") {
        const sessionID = event.properties.sessionID

        if (await isSubagent(sessionID)) return
        try {
          const message = await getMessagePreview(sessionID)
          await sendNotification("OpenCode", message, "low")
        } catch {
          await sendNotification("OpenCode", "Task Completed", "low")
        }
      }
    },
  }
}
