/**
 * Azuro Marketplace plugin for OpenCode.ai
 *
 * Injects azuro-marketplace bootstrap context via system prompt transform.
 * Skills are discovered via OpenCode's native skill tool from symlinked directory.
 */

import path from 'path';
import fs from 'fs';
import os from 'os';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const normalizePath = (p, homeDir) => {
  if (!p || typeof p !== 'string') return null;
  let normalized = p.trim();
  if (!normalized) return null;
  if (normalized.startsWith('~/')) {
    normalized = path.join(homeDir, normalized.slice(2));
  } else if (normalized === '~') {
    normalized = homeDir;
  }
  return path.resolve(normalized);
};

export const AzuroMarketplacePlugin = async () => {
  const homeDir = os.homedir();
  const azuroRoot = path.resolve(__dirname, '../..');
  const envConfigDir = normalizePath(process.env.OPENCODE_CONFIG_DIR, homeDir);
  const configDir = envConfigDir || path.join(homeDir, '.config/opencode');

  const getBootstrapContent = () => {
    const claudeMdPath = path.join(azuroRoot, 'CLAUDE.md');
    if (!fs.existsSync(claudeMdPath)) return null;

    const toolMapping = `**Tool Mapping for OpenCode:**
When skills reference Claude Code tools, substitute OpenCode equivalents:
- \`TodoWrite\` → \`update_plan\`
- \`Task\` tool with subagents → Use OpenCode's subagent system (@mention)
- \`Skill\` tool → OpenCode's native \`skill\` tool
- \`Read\`, \`Write\`, \`Edit\`, \`Bash\` → Your native tools

**Skills location:**
Azuro skills are in \`${configDir}/skills/\`
Use OpenCode's native \`skill\` tool to list and load skills.`;

    return `<EXTREMELY_IMPORTANT>
You have access to Azuro Marketplace — an industrial-grade AI development suite.

Run: \`cat ${azuroRoot}/CLAUDE.md\` to load the development guidelines and available commands.

${toolMapping}
</EXTREMELY_IMPORTANT>`;
  };

  return {
    'experimental.chat.system.transform': async (_input, output) => {
      const bootstrap = getBootstrapContent();
      if (bootstrap) {
        (output.system ||= []).push(bootstrap);
      }
    }
  };
};
