# CC-Skills: AI Agent Instructions

## Project Overview
CC-Skills is a Claude Code Skills framework for GitHub PR analysis with multi-agent IA support. The project emphasizes **bash script security** through automated validation and custom security checks.

## Architecture

### Core Components
- **`.claude/agents/`** - Claude Code Subagents (specialized AI assistants)
  - `pr-review-analyzer.md` - Analyzes collected data, generates insights, recommendations
  - `EXAMPLES.md` - Detailed usage examples for subagents
- **`.claude/skills/`** - Claude Code Skills (local installation)
  - `github-pr-collector/` - Collects PR data from GitHub CLI, categorizes by severity
- **`.scd/`** - Runtime data storage (gitignored except config)
  - `pr-data/` - PR analysis results organized by severity (🔴 critical, 🟠 major, 🟡 minor, 🔵 trivial)
  - `config/` - Agent patterns (`agents-patterns.json`) and severity mapping
  - `cache/` - Temporary data
- **`scripts/`** - Node.js validation scripts
  - `bash-security-check.js` - Custom security validator enforcing project bash standards

### Architecture Pattern: Skill + Subagent

**Skill (github-pr-collector)**: Bash-based deterministic tasks
- Collects PR data via GitHub CLI
- Parses and classifies comments by severity
- Generates structured Markdown files
- Token-efficient preprocessing

**Subagent (pr-review-analyzer)**: AI-powered analysis
- Reads structured data from `.scd/pr-data/`
- Generates insights, trends, recommendations
- Produces executive/technical reports
- Separate context window (doesn't pollute main conversation)
- Read-only tools (Read, Grep, Glob) for security

### Technology Stack
- **Node.js 18+** for tooling and validation
- **Bash 4.0+** for Skills scripts (to be implemented)
- **GitHub CLI (`gh`)** for PR data collection
- **Husky + lint-staged** for Git hooks (replaces Python pre-commit)

## Critical Workflows

### Development Workflow
```bash
npm install        # Setup dependencies + Husky hooks
npm test           # Run all checks (lint + security)
npm run security-check  # Custom bash security validation
```

### Git Hooks (Automatic)
Pre-commit triggers on every commit:
1. `lint-staged` - Runs ShellCheck + shfmt on modified `.sh` files
2. `npm run security-check` - Validates ALL bash scripts for security compliance

### CI/CD Pipeline
`.github/workflows/security-quality.yml` runs 4 parallel jobs:
1. **ShellCheck Analysis** - Static analysis with reviewdog PR comments
2. **Security Vulnerability Scan** - Custom checks + secret detection
3. **File Permissions Check** - Validates script permissions (755/750, never 777)
4. **Best Practices Validation** - Enforces strict mode and patterns

## Bash Script Requirements (MANDATORY)

Every bash script MUST include at line 2-3:
```bash
#!/bin/bash
set -euo pipefail
```

**Rationale**: Based on `docs/bash/Sécurisation des Scripts Bash _ Bonnes Pratiques.md`
- `set -e` - Exit on any error
- `set -u` - Exit on undefined variables
- `set -o pipefail` - Catch errors in pipes

### Security Patterns
❌ **NEVER** do this:
```bash
rm -rf $variable    # Unquoted - DANGEROUS
password="secret123"  # Hardcoded secret
```

✅ **ALWAYS** do this:
```bash
rm -rf "$variable"          # Quoted variable
password="${PASSWORD:-}"    # From environment
readonly PROJECT_ROOT       # Immutable constants
```

### Cleanup Pattern
When using temp files:
```bash
readonly TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT  # Cleanup on any exit
```

## Project-Specific Conventions

### Configuration Files
- **`agents-patterns.json`** - Defines how to detect and classify IA agents (CodeRabbit, GitHub Copilot, etc.)
- **`severity-mapping.json`** - Maps emoji prefixes to severity levels
- **`.shellcheckrc`** - Disables SC1091, SC2164, SC2034 (see comments in file)

### ShellCheck Exceptions
```bash
# SC1091: source files can be external - OK with set -e
# SC2164: cd failures handled by set -e - no need for || exit
# SC2034: Variables may be used by external scripts
```

### Directory Conventions
- Skills should organize output in `.scd/github-pr-collector/data/pr-data/pr-{number}/{severity}/`
- Severity folders: `🔴 Critical/`, `🟠 Major/`, `🟡 Minor/`, `🔵 Trivial/`
- Each PR gets `summary.md` and `COMMENTS_CHECKLIST.md`

### Installation Script Pattern
See `install/install.sh` for the canonical pattern:
- Use `set -euo pipefail` + `readonly` for all paths
- Colorized output with color reset codes
- Graceful degradation when Git/GitHub CLI unavailable
- Verify prerequisites before proceeding

## Testing & Validation

### Before Committing
```bash
npm test  # Runs full validation suite
```

### Manual Checks
```bash
npm run lint:shell     # ShellCheck only
npm run security-check # Security validator only
shellcheck path/to/script.sh  # Single file
```

### Validation Tool Behavior
`bash-security-check.js` checks:
- Strict mode presence
- Hardcoded secrets (patterns: password/api_key/token with values)
- Dangerous commands with unquoted variables (`rm/sudo/chmod $var`)
- Missing shebangs
- Temp files without EXIT traps

Exit code 1 = blocking errors (missing strict mode, hardcoded secrets)  
Warnings = non-blocking but should be reviewed

## Key Files for Context

- **`README.md`** - Architecture overview, Skill+Subagent pattern, installation
- **`.claude/agents/pr-review-analyzer.md`** - Subagent definition and system prompt
- **`.claude/agents/EXAMPLES.md`** - Detailed subagent usage examples
- **`.claude/skills/github-pr-collector/SKILL.md`** - Skill definition for data collection
- **`HUSKY-SETUP.md`** - Why Node.js hooks replace Python pre-commit
- **`CI-SECURITY.md`** - Complete CI/CD security implementation guide
- **`package.json`** - All npm scripts and lint-staged config
- **`scripts/bash-security-check.js`** - Security validation implementation

## Common Tasks

### Adding a New Bash Script
1. Start with mandatory header (shebang + strict mode)
2. Use `readonly` for constants
3. Quote all variable expansions
4. Add EXIT trap if using temp files
5. Run `npm test` before committing

### Adding Support for New IA Agent
1. Edit `.scd/config/agents-patterns.json`
2. Add detection patterns and severity mappings
3. Update documentation in relevant SKILL.md files
4. Test with actual PR data to validate detection

### Using the Subagent
The `pr-review-analyzer` subagent is invoked automatically or explicitly:
- Automatic: "Analyse les PR collectées"
- Explicit: "Utilise le subagent pr-review-analyzer pour générer un rapport exécutif"
- See `.claude/agents/EXAMPLES.md` for detailed usage patterns

### Troubleshooting Failed Checks
```bash
# See detailed ShellCheck errors
find . -name "*.sh" | xargs shellcheck

# Review security check failures
node scripts/bash-security-check.js

# Bypass hooks in emergency (NOT recommended)
git commit --no-verify
```

## References
- Architecture: `README.md` (Skill+Subagent pattern)
- Subagent examples: `.claude/agents/EXAMPLES.md`
- Security guide: `docs/bash/Sécurisation des Scripts Bash _ Bonnes Pratiques.md`
- Skills guide: `docs/Guide_Skills_Claude_Code_Bash_GitHub_CodeRabbit.md`
- Subagents doc: `docs/claude-code/Subagents - Claude Docs.md`
- Branch protection: `.github/BRANCH_PROTECTION.md`
