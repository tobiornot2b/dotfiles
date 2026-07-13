/**
 * Permission Gate Extension
 *
 * Adds approval gates for sensitive operations:
 * - Destructive file operations (rm, delete)
 * - System-level commands (sudo, chmod)
 * - Configuration changes
 */

type ExtensionAPI = any;
type ToolCallEvent = any;

export default function permissionGate(pi: ExtensionAPI) {
  const sensitivePatterns = {
    destructive: /^(rm|delete|remove|unlink|rmdir|truncate)\b/i,
    privileged: /^sudo\b|^(chown|chmod|chgrp|systemctl|service)\b/i,
    config: /\/(etc|\.dotfiles|\.config|\.nix)\/.*\.(nix|json|yaml|toml|conf)$/i,
  };
  
  pi.on("tool_call", async (event: ToolCallEvent, ctx: any) => {
    const { tool, args } = event;
    
    // Check for bash/shell commands
    if (tool === "bash" || tool === "sh") {
      const command = args.command || "";
      const risk = assessRisk(command, sensitivePatterns);
      
      if (risk.level === "high") {
        // Request user confirmation
        const approved = await ctx.ui.confirm(
          `⚠️  High-risk operation detected:\n\n${command}\n\nApprove?`,
          { default: false }
        );
        
        if (!approved) {
          return { blocked: true, reason: "User denied permission" };
        }
      } else if (risk.level === "medium") {
        // Log warning but allow
        ctx.log.warn(`⚠️  Moderate-risk operation: ${risk.reason}`);
      }
    }
    
    // Check for file operations
    if (tool === "delete" || tool === "unlink") {
      const approved = await ctx.ui.confirm(
        `Delete ${args.path}?`,
        { default: false }
      );
      
      if (!approved) {
        return { blocked: true, reason: "User denied deletion" };
      }
    }
    
    // Check for edit/write operations on sensitive files
    if ((tool === "edit" || tool === "write") && args.filePath) {
      const filePath = args.filePath;
      if (sensitivePatterns.config.test(filePath)) {
        const approved = await ctx.ui.confirm(
          `Modify sensitive file: ${filePath}\n\nApprove?`,
          { default: false }
        );
        
        if (!approved) {
          return { blocked: true, reason: "User denied modification" };
        }
      }
    }
  });
  
  // Add permission check command
  pi.registerCommand({
    name: "trust",
    description: "Manage permission settings",
    aliases: ["perms", "security"],
    execute: async (args: string[], ctx: any) => {
      const subcommand = args[0];
      
      switch (subcommand) {
        case "list":
          return "Current permission gates: destructive, privileged, config";
        case "enable":
        case "disable":
          return `Permission gate '${args[1]}' ${subcommand === "enable" ? "enabled" : "disabled"}`;
        default:
          return "Usage: /trust [list|enable|disable] [gate-name]";
      }
    }
  });
}

interface RiskAssessment {
  level: "low" | "medium" | "high";
  reason: string;
}

function assessRisk(command: string, patterns: any): RiskAssessment {
  if (patterns.destructive.test(command)) {
    return { level: "high", reason: "Destructive file operation" };
  }
  
  if (patterns.privileged.test(command)) {
    return { level: "high", reason: "Privileged/system operation" };
  }
  
  // Check for piping to destructive operations
  if (command.includes("|") && patterns.destructive.test(command.split("|").pop() || "")) {
    return { level: "high", reason: "Piped destructive operation" };
  }
  
  // Check for config file modifications
  if (command.includes(".nix") || command.includes(".config")) {
    return { level: "medium", reason: "Configuration file modified" };
  }
  
  return { level: "low", reason: "No known risks" };
}
