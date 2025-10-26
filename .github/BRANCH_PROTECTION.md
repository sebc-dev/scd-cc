# 🔒 Configuration des Protections de Branche pour GitHub

Cette configuration établit des règles de sécurité strictes basées sur le guide de sécurisation des scripts Bash.

## 📋 Règles de Protection Recommandées

### Branches Principales (main/master)

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "🔒 Security & Quality Checks / 🐚 ShellCheck Analysis",
      "🔒 Security & Quality Checks / 🔐 Security Vulnerability Scan", 
      "🔒 Security & Quality Checks / 🔐 File Permissions Check",
      "🔒 Security & Quality Checks / 📋 Best Practices Validation"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
```

## 🛠️ Configuration via GitHub CLI

Pour appliquer ces protections automatiquement, utilisez les commandes suivantes :

### 1. Protection de la branche principale

```bash
#!/bin/bash
set -euo pipefail

# Configuration des protections de branche principale
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["🔒 Security & Quality Checks / 🐚 ShellCheck Analysis","🔒 Security & Quality Checks / 🔐 Security Vulnerability Scan","🔒 Security & Quality Checks / 🔐 File Permissions Check","🔒 Security & Quality Checks / 📋 Best Practices Validation"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"require_last_push_approval":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true
```

### 2. Protection de la branche develop (si utilisée)

```bash
#!/bin/bash
set -euo pipefail

# Configuration pour la branche develop (moins stricte)
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["🔒 Security & Quality Checks / 🐚 ShellCheck Analysis","🔒 Security & Quality Checks / 📋 Best Practices Validation"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## 🎯 Interface Web GitHub

Alternativement, configurez via l'interface web GitHub :

1. **Accédez aux paramètres du repository**
   - `Settings` → `Branches`

2. **Ajoutez une règle de protection**
   - Cliquez sur `Add rule`
   - Branch name pattern: `main` (ou `master`)

3. **Activez les options suivantes :**
   - ✅ `Require a pull request before merging`
     - ✅ `Require approvals` (1 approbation minimum)
     - ✅ `Dismiss stale PR approvals when new commits are pushed`
     - ✅ `Require approval of the most recent reviewable push`
   
   - ✅ `Require status checks to pass before merging`
     - ✅ `Require branches to be up to date before merging`
     - Recherchez et sélectionnez :
       - `🔒 Security & Quality Checks / 🐚 ShellCheck Analysis`
       - `🔒 Security & Quality Checks / 🔐 Security Vulnerability Scan`
       - `🔒 Security & Quality Checks / 🔐 File Permissions Check`
       - `🔒 Security & Quality Checks / 📋 Best Practices Validation`
   
   - ✅ `Require conversation resolution before merging`
   - ✅ `Restrict pushes that create new files`
   - ✅ `Do not allow bypassing the above settings` (pour les admins)

## 🔐 Politique de Sécurité Avancée

### Variables d'Environnement Protégées

Configurez les secrets nécessaires dans `Settings` → `Secrets and variables` → `Actions` :

```bash
# Exemple de secrets recommandés (selon vos besoins)
GITHUB_TOKEN        # Token GitHub avec permissions appropriées
SLACK_WEBHOOK_URL   # Pour les notifications (optionnel)
SECURITY_EMAIL      # Email pour les alertes de sécurité
```

### Permissions Minimales

Pour les Actions GitHub, utilisez des permissions minimales :

```yaml
# Dans le workflow YAML
permissions:
  contents: read          # Lecture du code source
  pull-requests: write    # Commentaires sur les PR
  checks: write          # Mise à jour des vérifications
  security-events: write # Rapports de sécurité (optionnel)
```

## 📊 Monitoring et Alertes

### Notifications Slack (Optionnel)

Ajoutez cette étape à votre workflow pour les notifications :

```yaml
- name: 🚨 Notify on Security Issues
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: 'Security check failed in ${{ github.repository }}'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Email Notifications

GitHub peut automatiquement envoyer des notifications par email pour :
- Échecs de vérifications de sécurité
- Pull Requests bloquées par les protections
- Tentatives de contournement des règles

## 🚀 Activation Rapide

Pour activer rapidement toute la configuration :

```bash
#!/bin/bash
set -euo pipefail

echo "🔒 Configuration des protections de sécurité pour SCD-CC..."

# Vérification que nous sommes dans le bon repository
if ! git remote get-url origin | grep -q "scd-cc"; then
    echo "❌ Ce script doit être exécuté dans le repository scd-cc"
    exit 1
fi

# Installation des hooks pre-commit
echo "📋 Installation des hooks pre-commit..."
if command -v pre-commit >/dev/null 2>&1; then
    pre-commit install
    echo "✅ Hooks pre-commit installés"
else
    echo "⚠️  pre-commit n'est pas installé. Installez-le avec: pip install pre-commit"
fi

# Création du baseline pour detect-secrets
echo "🔍 Initialisation du baseline de détection de secrets..."
if command -v detect-secrets >/dev/null 2>&1; then
    detect-secrets scan --baseline .secrets.baseline
    echo "✅ Baseline créé"
else
    echo "⚠️  detect-secrets n'est pas installé. Installez-le avec: pip install detect-secrets"
fi

echo ""
echo "✅ Configuration locale terminée!"
echo ""
echo "🔧 Prochaines étapes:"
echo "  1. Commitez les fichiers de configuration"
echo "  2. Poussez vers GitHub"
echo "  3. Configurez les protections de branche (voir instructions ci-dessus)"
echo "  4. Testez avec une Pull Request"
```

## 📖 Références

- [Guide de Sécurisation des Scripts Bash](../bash/Sécurisation%20des%20Scripts%20Bash%20_%20Bonnes%20Pratiques.md)
- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Actions Security](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)