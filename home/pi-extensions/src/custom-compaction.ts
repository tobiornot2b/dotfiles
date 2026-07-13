/**
 * Custom Compaction Extension
 *
 * Implements topic-aware message compaction for Pi sessions.
 * Groups related messages and creates semantic summaries instead of naive truncation.
 */

type ExtensionAPI = any; // Replace with actual Pi ExtensionAPI type

export default function customCompaction(pi: ExtensionAPI) {
  pi.on("session_before_compact", async (event: any, ctx: any) => {
    const { session, messages, targetSize } = event;
    
    // Group messages by topic/context
    const groups = groupMessagesByTopic(messages);
    
    // Create semantic summaries for each group
    const summaries = await Promise.all(
      groups.map(group => summarizeGroup(group, pi, ctx))
    );
    
    // Return compacted history
    return {
      compactedMessages: summaries.map(s => ({
        role: "assistant",
        content: s,
        metadata: { type: "compaction_summary" }
      }))
    };
  });
}

/**
 * Group messages by semantic topic
 */
function groupMessagesByTopic(messages: any[]): any[][] {
  const groups: any[][] = [];
  let currentGroup: any[] = [];
  
  for (const msg of messages) {
    if (currentGroup.length === 0 || isSameTopic(currentGroup[0], msg)) {
      currentGroup.push(msg);
    } else {
      groups.push(currentGroup);
      currentGroup = [msg];
    }
  }
  
  if (currentGroup.length > 0) {
    groups.push(currentGroup);
  }
  
  return groups;
}

/**
 * Check if two messages are on the same topic
 */
function isSameTopic(msg1: any, msg2: any): boolean {
  // Simple heuristic: check if messages share common keywords
  const content1 = (msg1.content || "").toLowerCase();
  const content2 = (msg2.content || "").toLowerCase();
  
  const keywords = extractKeywords(content1);
  const hasCommon = keywords.some(kw => content2.includes(kw));
  
  return hasCommon || Math.abs(msg1.timestamp - msg2.timestamp) < 300000; // 5 min window
}

/**
 * Extract important keywords from text
 */
function extractKeywords(text: string): string[] {
  // Simple keyword extraction (replace with ML model for production)
  const words = text.split(/\s+/);
  const stopwords = new Set([
    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
    "of", "with", "by", "from", "is", "are", "was", "were", "be", "been"
  ]);
  
  return words
    .filter(w => !stopwords.has(w.toLowerCase()) && w.length > 3)
    .slice(0, 5);
}

/**
 * Summarize a group of messages
 */
async function summarizeGroup(group: any[], pi: any, ctx: any): Promise<string> {
  const content = group.map(m => m.content).join("\n");
  
  // Use Pi's LLM to create a concise summary
  // (This is a placeholder - actual implementation depends on Pi's SDK)
  return `[Compacted ${group.length} messages about: ${extractKeywords(content).join(", ")}]`;
}
