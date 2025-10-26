#!/bin/bash
set -euo pipefail

# Script d'activation rapide de la CI de sécurité pour SCD-CC
# Basé sur le guide "Sécurisation des Scripts Bash _ Bonnes Pratiques"

# Déclaration et assignation séparées pour éviter de masquer les codes de retour
declare SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

declare PROJECT_ROOT
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
readonly PROJECT_ROOT

# Couleurs pour l'affichage
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

echo -e "${BLUE}🔒 Configuration de la CI de Sécurité SCD-CC${NC}"
echo -e "${BLUE}📂 Projet: $PROJECT_ROOT${NC}"
echo ""

# Fonction de vérification des prérequis
check_prerequisites() {
    echo -e "${YELLOW}🔍 Vérification des prérequis...${NC}"
    
    local missing_tools=()
    
    # Outils requis pour l'approche JavaScript/Node.js
    local required_tools=("git" "node" "npm")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        else
            echo -e "${GREEN}✅ $tool détecté${NC}"
            if [[ "$tool" == "node" ]]; then
                local node_version
                node_version=$(node --version)
                echo -e "${GREEN}   Version: $node_version${NC}"
            fi
            if [[ "$tool" == "npm" ]]; then
                local npm_version
                npm_version=$(npm --version)
                echo -e "${GREEN}   Version: $npm_version${NC}"
            fi
        fi
    done
    
    # Outils optionnels mais recommandés
    local optional_tools=("gh" "shellcheck")
    
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  $tool non installé (recommandé)${NC}"
        else
            echo -e "${GREEN}✅ $tool détecté${NC}"
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Outils manquants: ${missing_tools[*]}${NC}"
        echo "Veuillez installer ces outils avant de continuer."
        echo ""
        echo -e "${YELLOW}💡 Suggestions d'installation:${NC}"
        echo "  • Node.js: https://nodejs.org/ ou via gestionnaire de paquets"
        echo "  • npm: Généralement inclus avec Node.js"
        return 1
    fi
    
    return 0
}

# Installation des dépendances Node.js et Husky
install_node_dependencies() {
    echo -e "${BLUE}� Installation des dépendances Node.js...${NC}"
    
    if [[ ! -f "${PROJECT_ROOT}/package.json" ]]; then
        echo -e "${RED}❌ package.json non trouvé${NC}"
        return 1
    fi
    
    echo "Installation des dépendances npm..."
    if cd "$PROJECT_ROOT" && npm install; then
        echo -e "${GREEN}✅ Dépendances installées${NC}"
    else
        echo -e "${RED}❌ Échec de l'installation des dépendances${NC}"
        return 1
    fi
    
    # Vérification que Husky est installé
    if [[ -d "${PROJECT_ROOT}/.husky" ]]; then
        echo -e "${GREEN}✅ Husky configuré${NC}"
    else
        echo "Configuration de Husky..."
        if cd "$PROJECT_ROOT" && npm run prepare; then
            echo -e "${GREEN}✅ Husky installé et configuré${NC}"
        else
            echo -e "${YELLOW}⚠️  Problème avec la configuration Husky${NC}"
        fi
    fi
}

# Installation des outils de sécurité
install_security_tools() {
    echo -e "${BLUE}🔍 Vérification des outils de sécurité...${NC}"
    
    # ShellCheck (optionnel si pas installé système)
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  ShellCheck non installé au niveau système${NC}"
        echo "Installation recommandée:"
        echo "  • Ubuntu/Debian: sudo apt install shellcheck"
        echo "  • macOS: brew install shellcheck"
        echo "  • Ou utilisez la version npm (incluse dans les dépendances)"
    else
        echo -e "${GREEN}✅ ShellCheck détecté${NC}"
    fi
    
    # Test du script de sécurité personnalisé
    if [[ -f "${PROJECT_ROOT}/scripts/bash-security-check.js" ]]; then
        echo "Test du script de sécurité personnalisé..."
        if cd "$PROJECT_ROOT" && node scripts/bash-security-check.js --help >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Script de sécurité fonctionnel${NC}"
        else
            echo -e "${YELLOW}⚠️  Le script de sécurité peut avoir des problèmes${NC}"
        fi
    else
        echo -e "${RED}❌ Script de sécurité manquant${NC}"
        return 1
    fi
    
    # Initialisation du baseline de secrets si nécessaire
    if [[ ! -f "${PROJECT_ROOT}/.secrets.baseline" ]]; then
        echo "Création du baseline de détection de secrets..."
        if cd "$PROJECT_ROOT"; then
            echo "{\"results\": {}, \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > .secrets.baseline
        fi
        echo -e "${GREEN}✅ Baseline créé${NC}"
    fi
}

# Vérification de la configuration Git
check_git_config() {
    echo -e "${BLUE}🔧 Vérification de la configuration Git...${NC}"
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo -e "${RED}❌ Pas dans un dépôt Git${NC}"
        return 1
    fi
    
    # Vérification de l'origine remote
    if git remote get-url origin >/dev/null 2>&1; then
        local origin_url
        origin_url=$(git remote get-url origin)
        echo -e "${GREEN}✅ Repository: $origin_url${NC}"
    else
        echo -e "${YELLOW}⚠️  Pas de remote 'origin' configuré${NC}"
    fi
    
    # Vérification des branches
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ Branche courante: $current_branch${NC}"
    
    return 0
}

# Test des hooks Husky et des scripts
test_husky_hooks() {
    echo -e "${BLUE}🧪 Test des hooks Husky et scripts de sécurité...${NC}"
    
    # Test du script de sécurité
    if [[ -f "${PROJECT_ROOT}/scripts/bash-security-check.js" ]]; then
        echo "Test du script de sécurité..."
        if cd "$PROJECT_ROOT" && npm run security-check; then
            echo -e "${GREEN}✅ Script de sécurité fonctionne${NC}"
        else
            echo -e "${YELLOW}⚠️  Le script de sécurité a détecté des problèmes${NC}"
        fi
    fi
    
    # Test des scripts npm
    echo "Test des scripts de linting..."
    if cd "$PROJECT_ROOT" && npm run test; then
        echo -e "${GREEN}✅ Tous les tests ont réussi${NC}"
    else
        echo -e "${YELLOW}⚠️  Certains tests ont échoué (normal pour la première fois)${NC}"
        echo "Les scripts corrigeront automatiquement certains problèmes."
    fi
}

# Vérification des fichiers de configuration
check_config_files() {
    echo -e "${BLUE}📁 Vérification des fichiers de configuration...${NC}"
    
    local config_files=(
        ".github/workflows/security-quality.yml"
        "package.json"
        "scripts/bash-security-check.js"
        ".shellcheckrc"
        ".secrets.baseline"
        ".github/BRANCH_PROTECTION.md"
    )
    
    local missing_files=()
    
    for file in "${config_files[@]}"; do
        if [[ -f "${PROJECT_ROOT}/$file" ]]; then
            echo -e "${GREEN}✅ $file${NC}"
        else
            echo -e "${RED}❌ $file manquant${NC}"
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Fichiers manquants: ${#missing_files[@]}${NC}"
        return 1
    fi
    
    return 0
}

# Affichage du résumé
show_summary() {
    echo ""
    echo -e "${GREEN}✅ Configuration de la CI de sécurité terminée!${NC}"
    echo ""
    echo -e "${BLUE}📋 Résumé de la configuration:${NC}"
    echo "  🔒 GitHub Actions workflow pour l'analyse de sécurité"
    echo "  🐚 ShellCheck pour l'analyse statique des scripts"
    echo "  🔍 Script de sécurité personnalisé en JavaScript"
    echo "  📋 Hooks Husky + lint-staged pour la validation locale"
    echo "  🛡️  Vérifications de permissions et bonnes pratiques"
    echo "  📦 Configuration npm avec scripts automatisés"
    echo ""
    echo -e "${YELLOW}🚀 Prochaines étapes:${NC}"
    echo "  1. Commitez et poussez ces changements"
    echo "  2. Configurez les protections de branche (voir .github/BRANCH_PROTECTION.md)"
    echo "  3. Créez une Pull Request pour tester la CI"
    echo ""
    echo -e "${BLUE}📖 Documentation:${NC}"
    echo "  - Guide complet: docs/bash/Sécurisation des Scripts Bash _ Bonnes Pratiques.md"
    echo "  - Configuration des branches: .github/BRANCH_PROTECTION.md"
    echo "  - Workflow CI: .github/workflows/security-quality.yml"
}

# Fonction principale
main() {
    # Vérifications préliminaires
    if ! check_prerequisites; then
        exit 1
    fi
    
    if ! check_git_config; then
        exit 1
    fi
    
    # Vérification des fichiers de configuration
    if ! check_config_files; then
        echo -e "${YELLOW}⚠️  Certains fichiers de configuration sont manquants${NC}"
        echo "Assurez-vous que tous les fichiers CI ont été créés correctement."
    fi
    
    # Installation des outils
    install_node_dependencies || echo -e "${YELLOW}⚠️  Problème avec les dépendances Node.js${NC}"
    install_security_tools || echo -e "${YELLOW}⚠️  Problème avec les outils de sécurité${NC}"
    
    # Test des hooks
    test_husky_hooks
    
    # Résumé final
    show_summary
}

# Gestion des interruptions
trap 'echo -e "\n${YELLOW}⚠️  Configuration interrompue${NC}"; exit 130' INT TERM

# Exécution du script principal
main "$@"