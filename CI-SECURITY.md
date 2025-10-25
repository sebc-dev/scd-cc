# 🔒 CI de Sécurité pour CC-Skills

Cette configuration implémente une CI complète basée sur le **Guide de Sécurisation des Scripts Bash** pour garantir la qualité et la sécurité de tous les scripts du projet.

## 🚀 Activation Rapide

```bash
# Exécutez le script d'activation automatique
./.github/setup-ci.sh
```

Ce script configure automatiquement :
- ✅ Installation de `pre-commit` et `detect-secrets`
- ✅ Configuration des hooks de validation
- ✅ Test de la configuration
- ✅ Vérification de tous les fichiers

## 📋 Architecture de la CI

### 🔄 GitHub Actions Workflow

Le workflow `security-quality.yml` exécute 4 jobs en parallèle :

1. **🐚 ShellCheck Analysis**
   - Analyse statique de tous les scripts shell
   - Utilise `reviewdog` pour commenter directement sur les PR
   - Fallback automatique si reviewdog échoue

2. **🔐 Security Vulnerability Scan** 
   - Scan de sécurité avec Bandit
   - Détection de secrets codés en dur
   - Validation des patterns suspects

3. **🔐 File Permissions Check**
   - Vérification des permissions de fichiers
   - Détection de permissions dangereuses (world-writable)
   - Validation des fichiers sensibles

4. **📋 Best Practices Validation**
   - Vérification du mode strict (`set -euo pipefail`)
   - Validation des shebangs
   - Contrôle des variables non quotées
   - Vérification des trap pour le nettoyage

### 🎯 Hooks Pre-commit

Les hooks s'exécutent automatiquement avant chaque commit :

- **ShellCheck** : Analyse et correction automatique
- **shfmt** : Formatage uniforme des scripts
- **detect-secrets** : Détection de secrets
- **Trailing whitespace** : Nettoyage des espaces
- **YAML/JSON validation** : Vérification syntaxique
- **Custom security check** : Vérifications spécifiques au projet

## 🛡️ Niveaux de Sécurité

### Niveau 1 : Local (Pre-commit)
- Validation immédiate lors du commit
- Corrections automatiques quand possible
- Blocage des commits non conformes

### Niveau 2 : CI/CD (GitHub Actions)
- Validation sur toutes les PR
- Rapports détaillés avec commentaires
- Génération d'artefacts de sécurité

### Niveau 3 : Branch Protection
- Blocage des merges non validés
- Obligations de review
- Protection contre les contournements

## 🔧 Configuration

### Fichiers de Configuration

```
.github/
├── workflows/
│   └── security-quality.yml     # Workflow principal de CI
├── setup-ci.sh                  # Script d'activation
└── BRANCH_PROTECTION.md         # Guide de protection des branches

.pre-commit-config.yaml           # Configuration des hooks
.shellcheckrc                     # Règles ShellCheck personnalisées  
.secrets.baseline                 # Baseline de détection de secrets
```

### Variables d'Environnement

Le workflow utilise ces variables configurables :

```yaml
env:
  SHELLCHECK_OPTS: "-e SC1091 -e SC2164"  # Options ShellCheck
```

### Exclusions

Les vérifications ignorent automatiquement :
- `.git/` : Fichiers de contrôle de version
- `.scd/cache/` : Cache du projet
- `node_modules/` : Dépendances Node.js
- `venv/` : Environment virtuel Python
- `*.log` : Fichiers de log

## 📊 Rapports et Artefacts

### Artefacts Générés

1. **scripts-list** : Liste des scripts analysés
2. **security-report** : Rapport de sécurité Bandit (JSON)
3. **security-summary** : Résumé Markdown avec recommandations

### Format des Rapports

Les rapports suivent le format du guide de sécurisation :

```markdown
# 🔒 Security & Quality Analysis Summary

## 📋 Job Results
- ✅ **ShellCheck Analysis**: success
- ✅ **Security Scan**: success  
- ✅ **Permissions Check**: success
- ✅ **Best Practices**: success

## 🎯 Recommendations
[Recommandations détaillées basées sur les résultats]
```

## 🚨 Gestion des Échecs

### Échecs Bloquants

Ces erreurs empêchent le merge :
- Mode strict manquant (`set -euo pipefail`)
- Secrets codés en dur détectés
- Permissions dangereuses (world-writable)
- Erreurs ShellCheck critiques

### Avertissements Non-Bloquants

Ces problèmes génèrent des avertissements :
- Variables potentiellement non quotées
- Fichiers temporaires sans trap
- Suggestions d'optimisation ShellCheck

## 🔍 Dépannage

### Problèmes Courants

**1. Hook pre-commit qui échoue**
```bash
# Voir les détails de l'erreur
pre-commit run --all-files --verbose

# Mettre à jour les hooks
pre-commit autoupdate
```

**2. ShellCheck trouve des erreurs**
```bash
# Analyser un script spécifique
shellcheck mon_script.sh

# Ignorer une règle temporairement
# shellcheck disable=SC2086
```

**3. Secrets détectés par erreur**
```bash
# Mettre à jour le baseline
detect-secrets scan --baseline .secrets.baseline

# Marquer comme faux positif dans le baseline
```

### Contournement d'Urgence

En cas d'urgence critique, les administrateurs peuvent :

1. **Contourner les hooks localement** (non recommandé) :
   ```bash
   git commit --no-verify
   ```

2. **Forcer le merge** (avec permissions admin) :
   - Via l'interface GitHub si configuré
   - Sera audité et notifié

## 📈 Métriques et Monitoring

### Métriques Collectées

- Nombre de scripts analysés
- Taux de conformité par PR  
- Types d'erreurs les plus fréquents
- Temps d'exécution des vérifications

### Tableaux de Bord

Les résultats sont visibles dans :
- **GitHub Actions** : Logs détaillés et historique
- **Pull Requests** : Commentaires automatiques
- **Branch Protection** : Status checks obligatoires

## 🔄 Maintenance

### Mises à Jour Régulières

```bash
# Mise à jour des hooks pre-commit
pre-commit autoupdate

# Mise à jour du baseline de secrets
detect-secrets scan --baseline .secrets.baseline

# Test de la configuration
pre-commit run --all-files
```

### Versions des Outils

- **ShellCheck** : v0.11.0+ (via koalaman/shellcheck-precommit)
- **detect-secrets** : v1.4.0+
- **shfmt** : v3.8.0+
- **GitHub Actions** : checkout@v4, upload-artifact@v4

## 📖 Références

- [Guide de Sécurisation des Scripts Bash](../docs/bash/Sécurisation%20des%20Scripts%20Bash%20_%20Bonnes%20Pratiques.md)
- [Configuration des Protections de Branche](.github/BRANCH_PROTECTION.md)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck)
- [Pre-commit Framework](https://pre-commit.com/)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides)