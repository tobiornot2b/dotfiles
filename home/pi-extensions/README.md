# Pi Extensions

Custom extensions for the Pi coding agent harness.

## Structure

- `src/` - TypeScript source files for extensions
- `dist/` - Compiled JavaScript (generated, not tracked)

## Extensions

### custom-compaction.ts
Implements topic-aware message compaction for long conversations. Uses semantic analysis to group related messages before summarization.

### permission-gate.ts
Adds permission gates to sensitive operations (file deletion, system commands). Useful for sandboxed or shared environments.

### ssh-executor.ts
Extends Pi to execute commands on remote systems via SSH. Integrates with configured SSH hosts.

## Development

```bash
npm install
npm run build

# Watch for changes
npm run watch
```

## Installation

Pi automatically loads extensions from:
- Global: `~/.config/pi/extensions/`
- Project: `.pi/extensions/`

To enable an extension, add its path to pi's configuration or use:
```bash
pi install ./home/pi-extensions/dist/my-extension.js
```
