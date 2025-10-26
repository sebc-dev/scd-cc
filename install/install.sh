#!/bin/bash
set -euo pipefail

# CC-Skills Installation Script
# Version: 2.0.0
# Description: Installe les Skills et Subagents Claude Code pour l'analyse des PR GitHub

readonly REPO_URL="https://github.com/sebc-dev/cc-skills"
readonly REPO_BRANCH="main"
declare PROJECT_ROOT
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
readonly PROJECT_ROOT
readonly SKILLS_DIR="${PROJECT_ROOT}/.claude/skills"
readonly AGENTS_DIR="${PROJECT_ROOT}/.claude/agents"
readonly DATA_DIR="${PROJECT_ROOT}/.scd"
TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR
trap 'rm -rf "$TEMP_DIR"' EXIT

# Couleurs pour l'affichage
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

echo -e "${BLUE}🚀 Installation de CC-Skills dans le projet courant...${NC}"
echo -e "${BLUE}📂 Projet détecté: $PROJECT_ROOT${NC}"

# Vérification des prérequis
echo -e "${YELLOW}🔍 Vérification des prérequis...${NC}"
for cmd in gh jq curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}❌ $cmd n'est pas installé${NC}"
        echo "Veuillez installer $cmd avant de continuer."
        exit 1
    else
        echo -e "${GREEN}✅ $cmd détecté${NC}"
    fi
done

# Vérification GitHub CLI authentification
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  GitHub CLI n'est pas authentifié${NC}"
    echo "Exécutez 'gh auth login' pour vous authentifier."
    echo "L'installation continuera sans cette vérification."
fi

# Vérification que nous sommes dans un projet Git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Attention: Pas dans un dépôt Git.${NC}"
    echo "Installation dans le dossier courant: $(pwd)"
fi

# Création de la structure locale
echo -e "${BLUE}📁 Création de la structure de dossiers...${NC}"
mkdir -p "$SKILLS_DIR/github-pr-collector/scripts"
mkdir -p "$AGENTS_DIR"
mkdir -p "$DATA_DIR/pr-data"
mkdir -p "$DATA_DIR/config"
mkdir -p "$DATA_DIR/cache"

echo -e "${GREEN}✅ Structure créée:${NC}"
echo "  📂 $SKILLS_DIR (Skills Claude Code)"
echo "  📂 $AGENTS_DIR (Subagents Claude Code)"
echo "  📂 $DATA_DIR (Données et configuration)"

# Téléchargement des composants depuis le repository
echo -e "${BLUE}📥 Téléchargement depuis le repository (v2.0.0)...${NC}"

# Fonction pour télécharger un fichier depuis GitHub
download_file() {
    local file_path="$1"
    local dest_path="$2"
    local url="${REPO_URL}/raw/${REPO_BRANCH}/${file_path}"
    
    # Créer le répertoire parent si nécessaire
    local dest_dir
    dest_dir=$(dirname "$dest_path")
    mkdir -p "$dest_dir"
    
    if curl -sSfL "$url" -o "$dest_path" 2>/dev/null; then
        if [[ -f "$dest_path" ]] && [[ -s "$dest_path" ]]; then
            echo -e "${GREEN}  ✅ ${file_path}${NC}"
            return 0
        else
            echo -e "${RED}  ❌ Fichier téléchargé mais vide: ${file_path}${NC}"
            return 1
        fi
    else
        echo -e "${RED}  ❌ Échec du téléchargement: ${file_path}${NC}"
        echo -e "${YELLOW}     URL: ${url}${NC}"
        return 1
    fi
}

# Télécharger le skill github-pr-collector
echo -e "${BLUE}📦 Installation du skill: github-pr-collector${NC}"
download_file ".claude/skills/github-pr-collector/SKILL.md" \
    "$SKILLS_DIR/github-pr-collector/SKILL.md"
download_file ".claude/skills/github-pr-collector/scripts/collect-pr-data.sh" \
    "$SKILLS_DIR/github-pr-collector/scripts/collect-pr-data.sh"

# Télécharger le subagent pr-review-analyzer
echo -e "${BLUE}🤖 Installation du subagent: pr-review-analyzer${NC}"
download_file ".claude/agents/pr-review-analyzer.md" \
    "$AGENTS_DIR/pr-review-analyzer.md"
download_file ".claude/agents/EXAMPLES.md" \
    "$AGENTS_DIR/EXAMPLES.md"
download_file ".claude/agents/README.md" \
    "$AGENTS_DIR/README.md"

# Télécharger les fichiers de configuration
echo -e "${BLUE}⚙️  Installation des fichiers de configuration${NC}"
download_file ".scd/config/agents-patterns.json" \
    "$DATA_DIR/config/agents-patterns.json"
download_file ".scd/config/severity-mapping.json" \
    "$DATA_DIR/config/severity-mapping.json"

# Vérification de l'installation
echo -e "${BLUE}🔍 Vérification de l'installation...${NC}"

readonly -a REQUIRED_FILES=(
    "$SKILLS_DIR/github-pr-collector/SKILL.md"
    "$SKILLS_DIR/github-pr-collector/scripts/collect-pr-data.sh"
    "$AGENTS_DIR/pr-review-analyzer.md"
    "$AGENTS_DIR/EXAMPLES.md"
    "$AGENTS_DIR/README.md"
    "$DATA_DIR/config/agents-patterns.json"
    "$DATA_DIR/config/severity-mapping.json"
)

install_success=true
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✅ $(basename "$file")${NC}"
    else
        echo -e "${RED}❌ Fichier manquant: $(basename "$file")${NC}"
        install_success=false
    fi
done

if [[ "$install_success" == "false" ]]; then
    echo -e "${RED}❌ L'installation a échoué. Certains fichiers sont manquants.${NC}"
    echo -e "${YELLOW}💡 Vérifiez votre connexion et réessayez, ou clonez le repository manuellement:${NC}"
    echo -e "${YELLOW}   git clone ${REPO_URL}${NC}"
    exit 1
fi

# Configuration des permissions pour les scripts
echo -e "${BLUE}🔧 Configuration des permissions...${NC}"
find "$SKILLS_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
echo -e "${GREEN}✅ Permissions configurées${NC}"

# Ajout au .gitignore si existe
if [[ -f "${PROJECT_ROOT}/.gitignore" ]]; then
    if ! grep -q "^\.scd/" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
        {
            echo ""
            echo "# CC-Skills runtime data (v2.0.0)"
            echo ".scd/cache/"
            echo ".scd/pr-data/"
            echo ".scd/*.log"
            echo "!.scd/config/"
        } >> "${PROJECT_ROOT}/.gitignore"
        echo -e "${GREEN}✅ .gitignore mis à jour${NC}"
    else
        echo -e "${GREEN}✅ .gitignore déjà configuré${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Pas de .gitignore trouvé${NC}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✅ Installation CC-Skills v2.0.0 Terminée !                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}� Composants installés:${NC}"
echo -e "  ${GREEN}✅${NC} Skill:    github-pr-collector (collecte de données)"
echo -e "  ${GREEN}✅${NC} Subagent: pr-review-analyzer (analyse IA)"
echo ""
echo -e "${BLUE}📂 Emplacements:${NC}"
echo -e "  Skills:    $SKILLS_DIR"
echo -e "  Subagents: $AGENTS_DIR"
echo -e "  Données:   $DATA_DIR"
echo ""
echo -e "${YELLOW}🚀 Pour commencer:${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Authentifiez-vous avec GitHub CLI (si pas déjà fait):"
echo -e "     ${GREEN}gh auth login${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} Ouvrez Claude Code dans ce projet"
echo ""
echo -e "  ${BLUE}3.${NC} Lancez une analyse complète:"
echo -e "     ${GREEN}\"Analyse les PR en cours de ce repository\"${NC}"
echo ""
echo -e "     ${BLUE}Ou en deux étapes:${NC}"
echo -e "     ${GREEN}\"Collecte les données des PR\"${NC}"
echo -e "     ${GREEN}\"Utilise le subagent pr-review-analyzer\"${NC}"
echo ""
echo -e "${BLUE}� Documentation:${NC}"
echo -e "  Architecture:  ${YELLOW}ARCHITECTURE-PATTERN.md${NC}"
echo -e "  Migration:     ${YELLOW}MIGRATION-SKILL-TO-SUBAGENT.md${NC}"
echo -e "  Exemples:      ${YELLOW}.claude/agents/EXAMPLES.md${NC}"
echo -e "  Guide complet: ${YELLOW}https://github.com/sebc-dev/cc-skills${NC}"
echo ""
echo -e "${GREEN}🎊 Profitez de l'architecture Skill+Subagent !${NC}"