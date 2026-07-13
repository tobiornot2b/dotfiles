/**
 * SSH Executor Extension
 *
 * Enables Pi to execute commands on remote systems via SSH.
 * Useful for distributed development and remote infrastructure management.
 */

type ExtensionAPI = any;

interface SSHConfig {
  host: string;
  user: string;
  port: number;
  keyPath?: string;
}

export default function sshExecutor(pi: ExtensionAPI) {
  // Store SSH configurations
  const sshConfigs = new Map<string, SSHConfig>();
  
  // Register SSH tool
  pi.registerTool({
    name: "ssh-exec",
    description: "Execute commands on remote hosts via SSH",
    parameters: {
      type: "object",
      properties: {
        host: { type: "string", description: "SSH host alias or hostname" },
        command: { type: "string", description: "Command to execute" },
        user: { type: "string", description: "Remote user (optional, uses configured)" }
      },
      required: ["host", "command"]
    },
    async execute(id: string, args: any, signal: AbortSignal, onUpdate: any, ctx: any) {
      const { host, command, user } = args;
      const config = sshConfigs.get(host);
      
      if (!config) {
        return { error: `Unknown host: ${host}` };
      }
      
      const remoteUser = user || config.user;
      const sshCommand = buildSSHCommand(remoteUser, config.host, command, config);
      
      try {
        // Use Pi's existing bash tool to execute
        const result = await ctx.tools.exec("bash", {
          command: sshCommand,
          signal
        }, onUpdate);
        
        return {
          success: true,
          host,
          output: result.stdout,
          error: result.stderr
        };
      } catch (err: any) {
        return {
          success: false,
          host,
          error: err.message
        };
      }
    }
  });
  
  // Register host management command
  pi.registerCommand({
    name: "ssh-config",
    description: "Manage SSH host configurations",
    aliases: ["remote"],
    execute: async (args: string[], ctx: any) => {
      const subcommand = args[0];
      
      switch (subcommand) {
        case "add":
          if (args.length < 3) {
            return "Usage: /ssh-config add <alias> <user@host[:port]>";
          }
          const [_, alias, hostStr] = args;
          addSSHConfig(alias, hostStr, sshConfigs);
          return `Added SSH host: ${alias}`;
          
        case "list":
          if (sshConfigs.size === 0) {
            return "No SSH hosts configured. Use: /ssh-config add <alias> <user@host>";
          }
          return Array.from(sshConfigs.entries())
            .map(([k, v]) => `${k}: ${v.user}@${v.host}:${v.port}`)
            .join("\n");
            
        case "remove":
          if (args.length < 2) return "Usage: /ssh-config remove <alias>";
          sshConfigs.delete(args[1]);
          return `Removed SSH host: ${args[1]}`;
          
        default:
          return `Unknown subcommand: ${subcommand}. Use: add, list, remove`;
      }
    }
  });
  
  // Add SSH context to agent prompt
  pi.on("before_agent_start", async (event: any, ctx: any) => {
    if (sshConfigs.size > 0) {
      const hostList = Array.from(sshConfigs.keys()).join(", ");
      return {
        injectedMessage: {
          role: "system",
          content: `Available SSH hosts: ${hostList}. Use ssh-exec tool to run remote commands.`
        }
      };
    }
  });
}

function addSSHConfig(alias: string, hostStr: string, configs: Map<string, SSHConfig>): void {
  const match = hostStr.match(/^(.+)@(.+?)(?::(\d+))?$/);
  
  if (!match) {
    throw new Error("Invalid host format. Use: user@hostname[:port]");
  }
  
  const [, user, host, portStr] = match;
  const port = portStr ? parseInt(portStr, 10) : 22;
  
  configs.set(alias, { host, user, port });
}

function buildSSHCommand(user: string, host: string, command: string, config: SSHConfig): string {
  let cmd = `ssh -p ${config.port}`;
  
  if (config.keyPath) {
    cmd += ` -i ${config.keyPath}`;
  }
  
  cmd += ` ${user}@${host}`;
  cmd += ` '${command.replace(/'/g, "'\\''")}'`;
  
  return cmd;
}
