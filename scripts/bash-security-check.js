#!/usr/bin/env node

/**
 * Script de vérification de sécurité personnalisé pour les scripts Bash
 * Basé sur le guide "Sécurisation des Scripts Bash _ Bonnes Pratiques"
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration des couleurs pour la console
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  bold: '\x1b[1m'
};

// Configuration des vérifications
const SECURITY_CHECKS = {
  STRICT_MODE: {
    pattern: /set\s+-[a-z]*e[a-z]*u[a-z]*o[a-z]*\s+pipefail|set\s+-euo\s+pipefail/,
    message: "Mode strict manquant (set -euo pipefail)",
    severity: "error"
  },
  HARDCODED_SECRETS: {
    patterns: [
      /(?:password|passwd|pwd|api[_-]?key|secret|token)\s*=\s*['"'][^'"]{3,}['"]/i,
      /https?:\/\/[^:]+:[^@]+@/,  // URLs avec credentials
      /['"'][A-Za-z0-9+/]{20,}={0,2}['"]/  // Base64 suspects
    ],
    message: "Secret potentiel codé en dur détecté",
    severity: "error"
  },
  DANGEROUS_COMMANDS: {
    patterns: [
      /rm\s+.*\$[A-Za-z_][A-Za-z0-9_]*(?!["])/,
      /sudo\s+.*\$[A-Za-z_][A-Za-z0-9_]*(?!["])/,
      /chmod\s+.*\$[A-Za-z_][A-Za-z0-9_]*(?!["])/
    ],
    message: "Commande potentiellement dangereuse avec variable non quotée",
    severity: "warning"
  },
  SHEBANG_CHECK: {
    pattern: /^#!/,
    message: "Shebang manquant",
    severity: "warning"
  },
  TRAP_CLEANUP: {
    tempPattern: /mktemp|tempfile/,
    trapPattern: /trap.*EXIT/,
    message: "Fichiers temporaires utilisés mais pas de trap EXIT pour le nettoyage",
    severity: "warning"
  }
};

class BashSecurityChecker {
  constructor() {
    this.errors = [];
    this.warnings = [];
    this.filesChecked = 0;
  }

  log(message, color = colors.reset) {
    console.log(`${color}${message}${colors.reset}`);
  }

  logError(file, line, message) {
    const errorMsg = `❌ ${file}:${line} - ${message}`;
    this.log(errorMsg, colors.red);
    this.errors.push({ file, line, message });
  }

  logWarning(file, line, message) {
    const warningMsg = `⚠️  ${file}:${line} - ${message}`;
    this.log(warningMsg, colors.yellow);
    this.warnings.push({ file, line, message });
  }

  findShellScripts(directory = '.') {
    const scripts = [];
    
    try {
      const output = execSync(`find "${directory}" -type f \\( -name "*.sh" -o -name "*.bash" \\) -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.husky/_/*"`, 
        { encoding: 'utf8' });
      
      scripts.push(...output.trim().split('\n').filter(Boolean));
    } catch (error) {
      this.log(`⚠️  Erreur lors de la recherche de scripts: ${error.message}`, colors.yellow);
    }

    return scripts;
  }

  checkFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      const lines = content.split('\n');
      
      this.filesChecked++;
      this.log(`🔍 Analyse: ${filePath}`, colors.blue);

      // Vérification du shebang
      if (lines.length > 0) {
        this.checkShebang(filePath, lines[0]);
      }

      // Vérification du mode strict
      this.checkStrictMode(filePath, content);

      // Vérification des secrets codés en dur
      this.checkHardcodedSecrets(filePath, lines);

      // Vérification des commandes dangereuses
      this.checkDangerousCommands(filePath, lines);

      // Vérification des fichiers temporaires et trap
      this.checkTempFilesAndTraps(filePath, content);

    } catch (error) {
      this.logError(filePath, 0, `Erreur de lecture du fichier: ${error.message}`);
    }
  }

  checkShebang(filePath, firstLine) {
    if (!SECURITY_CHECKS.SHEBANG_CHECK.pattern.test(firstLine)) {
      this.logWarning(filePath, 1, SECURITY_CHECKS.SHEBANG_CHECK.message);
    }
  }

  checkStrictMode(filePath, content) {
    if (!SECURITY_CHECKS.STRICT_MODE.pattern.test(content)) {
      this.logError(filePath, 0, SECURITY_CHECKS.STRICT_MODE.message);
    }
  }

  checkHardcodedSecrets(filePath, lines) {
    lines.forEach((line, index) => {
      // Ignorer les commentaires
      if (line.trim().startsWith('#')) return;

      SECURITY_CHECKS.HARDCODED_SECRETS.patterns.forEach(pattern => {
        if (pattern.test(line)) {
          this.logError(filePath, index + 1, SECURITY_CHECKS.HARDCODED_SECRETS.message);
        }
      });
    });
  }

  checkDangerousCommands(filePath, lines) {
    lines.forEach((line, index) => {
      // Ignorer les commentaires
      if (line.trim().startsWith('#')) return;

      SECURITY_CHECKS.DANGEROUS_COMMANDS.patterns.forEach(pattern => {
        if (pattern.test(line)) {
          this.logWarning(filePath, index + 1, SECURITY_CHECKS.DANGEROUS_COMMANDS.message);
        }
      });
    });
  }

  checkTempFilesAndTraps(filePath, content) {
    const hasTempFiles = SECURITY_CHECKS.TRAP_CLEANUP.tempPattern.test(content);
    const hasTrapExit = SECURITY_CHECKS.TRAP_CLEANUP.trapPattern.test(content);

    if (hasTempFiles && !hasTrapExit) {
      this.logWarning(filePath, 0, SECURITY_CHECKS.TRAP_CLEANUP.message);
    }
  }

  generateReport() {
    this.log('\n📊 Rapport de Sécurité', colors.bold + colors.blue);
    this.log('═'.repeat(50), colors.blue);
    
    this.log(`📁 Fichiers analysés: ${this.filesChecked}`, colors.blue);
    this.log(`❌ Erreurs: ${this.errors.length}`, this.errors.length > 0 ? colors.red : colors.green);
    this.log(`⚠️  Avertissements: ${this.warnings.length}`, this.warnings.length > 0 ? colors.yellow : colors.green);

    if (this.errors.length === 0 && this.warnings.length === 0) {
      this.log('\n✅ Aucun problème de sécurité détecté!', colors.green);
    } else {
      this.log('\n🔒 Recommandations de Sécurité:', colors.yellow);
      this.log('  • Utilisez toujours "set -euo pipefail" au début des scripts');
      this.log('  • Mettez les variables entre guillemets: "$variable"');
      this.log('  • Externalisez les secrets dans des variables d\'environnement');
      this.log('  • Utilisez des chemins absolus pour les commandes système');
      this.log('  • Implémentez un nettoyage avec "trap" pour les fichiers temporaires');
      this.log('\n📖 Guide complet: docs/bash/Sécurisation des Scripts Bash _ Bonnes Pratiques.md');
    }

    return this.errors.length === 0;
  }

  async run() {
    this.log('🔒 Vérification de Sécurité des Scripts Bash', colors.bold + colors.blue);
    this.log('Basé sur le guide de sécurisation CC-Skills\n', colors.blue);

    const scripts = this.findShellScripts();
    
    if (scripts.length === 0) {
      this.log('ℹ️  Aucun script shell trouvé dans le projet', colors.yellow);
      return true;
    }

    scripts.forEach(script => this.checkFile(script));
    
    return this.generateReport();
  }
}

// Exécution du script
if (require.main === module) {
  const checker = new BashSecurityChecker();
  
  checker.run().then(success => {
    process.exit(success ? 0 : 1);
  }).catch(error => {
    console.error(`${colors.red}❌ Erreur lors de l'exécution: ${error.message}${colors.reset}`);
    process.exit(1);
  });
}

module.exports = BashSecurityChecker;