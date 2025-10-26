# 🚀 Configuration Husky + JavaScript pour SCD-CC

Cette configuration remplace l'approche Python/pre-commit par une solution moderne basée sur **Node.js + Husky** pour une meilleure intégration avec les environnements de développement JavaScript/TypeScript.

## 🌟 Avantages de cette Approche

### ✅ Avantages par rapport à pre-commit Python

- **🚀 Performance** : Hooks plus rapides sans initialisation Python
- **📦 Gestion unifiée** : Toutes les dépendances via npm
- **🎯 Customisation** : Script de sécurité personnalisé en JavaScript
- **🔧 Intégration IDE** : Meilleur support VS Code/WebStorm
- **📱 Cross-platform** : Fonctionne identiquement sur tous les OS
- **🎨 Formatage automatique** : lint-staged pour les corrections auto

### 🛠️ Outils Intégrés

- **Husky** : Gestion des hooks Git
- **lint-staged** : Traitement des fichiers modifiés uniquement
- **ShellCheck** : Analyse statique des scripts Bash (npm ou système)
- **Script personnalisé** : Vérifications de sécurité spécifiques à SCD-CC

## 📋 Installation et Configuration

### 🚀 Installation Automatique

```bash
# Exécution du script de setup
./.github/setup-ci.sh
```

### 📝 Installation Manuelle

```bash
# 1. Installer les dépendances
npm install

# 2. Configurer Husky
npm run prepare

# 3. Tester la configuration
npm test
```

## 🔧 Structure de la Configuration

### 📦 package.json - Scripts

```json
{
  "scripts": {
    "prepare": "husky",                          // Configuration Husky
    "lint": "npm run lint:shell && npm run lint:secrets",
    "lint:shell": "find . -name '*.sh' ... | xargs shellcheck",
    "security-check": "node scripts/bash-security-check.js",
    "test": "npm run lint && npm run security-check"
  },
  "lint-staged": {
    "*.{sh,bash}": ["shellcheck", "shfmt -w -s -i 2"],
    "*": ["node scripts/bash-security-check.js"]
  }
}
```

### 🪝 .husky/pre-commit

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Lint-staged pour les fichiers modifiés
npx lint-staged

# Vérification globale
npm run security-check
```

### 🔍 scripts/bash-security-check.js

Script JavaScript personnalisé qui vérifie :
- ✅ Mode strict (`set -euo pipefail`)
- ✅ Secrets codés en dur
- ✅ Commandes dangereuses non quotées
- ✅ Shebangs et permissions
- ✅ Nettoyage avec trap

## 🎯 Flux de Travail

### 1. Développement Local

```bash
# Edition d'un script
vim mon-script.sh

# Au commit, automatiquement :
git add mon-script.sh
git commit -m "Update script"
# → Husky déclenche les vérifications
# → lint-staged traite les fichiers modifiés
# → ShellCheck analyse le script
# → Script de sécurité vérifie les bonnes pratiques
```

### 2. Intégration Continue

```bash
# Push vers GitHub
git push origin feature/mon-script

# → GitHub Actions déclenche security-quality.yml
# → 4 jobs en parallèle :
#   - ShellCheck Analysis (avec reviewdog)
#   - Security Vulnerability Scan
#   - File Permissions Check  
#   - Best Practices Validation
```

## 📊 Scripts Disponibles

### 🔍 Analyse et Linting

```bash
npm run lint              # Analyse complète
npm run lint:shell        # ShellCheck uniquement
npm run security-check    # Vérifications de sécurité
```

### 🎨 Formatage

```bash
npm run format            # Formatage automatique
npm run format:shell      # shfmt pour les scripts
```

### 🧪 Tests

```bash
npm test                  # Tests complets (lint + security)
```

## 🔧 Personnalisation

### Modifier les Règles ShellCheck

Editez `.shellcheckrc` :
```bash
# Désactiver des règles spécifiques
disable=SC1091,SC2164,SC2034
severity=warning
```

### Personnaliser le Script de Sécurité

Editez `scripts/bash-security-check.js` :
```javascript
const SECURITY_CHECKS = {
  STRICT_MODE: {
    pattern: /set\s+-euo\s+pipefail/,
    severity: "error"
  },
  // Ajouter de nouvelles vérifications...
}
```

### Modifier lint-staged

Dans `package.json` :
```json
"lint-staged": {
  "*.{sh,bash}": [
    "shellcheck",
    "shfmt -w -s -i 2",
    "git add"
  ]
}
```

## 🚨 Dépannage

### Problèmes Courants

**1. Hooks qui ne se déclenchent pas**
```bash
# Vérifier l'installation Husky
ls -la .husky/
npm run prepare
```

**2. ShellCheck non trouvé**
```bash
# Le package npm télécharge automatiquement ShellCheck
# Ou installer au niveau système :
sudo apt install shellcheck  # Ubuntu/Debian
brew install shellcheck      # macOS
```

**3. Script de sécurité échoue**
```bash
# Test manuel
node scripts/bash-security-check.js
# Vérifier les erreurs et corriger les scripts
```

### Bypass d'Urgence

```bash
# Contourner les hooks (non recommandé)
git commit --no-verify

# Désactiver temporairement Husky
export HUSKY=0
git commit
```

## 📈 Migration depuis pre-commit Python

### Étapes de Migration

1. **Sauvegarder l'ancienne config** :
   ```bash
   mv .pre-commit-config.yaml .pre-commit-config.yaml.backup
   ```

2. **Installer la nouvelle configuration** :
   ```bash
   npm install
   npm run setup
   ```

3. **Désinstaller pre-commit** (optionnel) :
   ```bash
   pre-commit uninstall
   pip uninstall pre-commit
   ```

### Comparaison des Fonctionnalités

| Fonctionnalité | pre-commit Python | Husky + JavaScript |
|----------------|-------------------|-------------------|
| **Performance** | ⚡ Moyen | ⚡⚡⚡ Excellent |
| **Setup** | 🔧 Complexe | 🔧 Simple |
| **Maintenance** | 📋 Python + YAML | 📋 JavaScript + JSON |
| **Intégration IDE** | ⚙️ Limitée | ⚙️⚙️ Excellente |
| **Customisation** | 🎨 Limitée | 🎨🎨🎨 Complète |
| **Cross-platform** | 🌍 Bon | 🌍🌍 Excellent |

## 🎉 Résultat Final

Avec cette configuration, chaque script Bash du projet bénéficie automatiquement :

- ✅ **Analyse statique** avec ShellCheck
- ✅ **Vérifications de sécurité** personnalisées  
- ✅ **Formatage automatique** avec shfmt
- ✅ **Hooks Git** transparents et rapides
- ✅ **Intégration CI/CD** avec GitHub Actions
- ✅ **Documentation** et rapports détaillés

Le tout avec une approche moderne, performante et facilement maintenable ! 🚀