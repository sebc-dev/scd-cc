#!/bin/bash
set -euo pipefail

# CC-Skills Installation Script
# Version: 1.0.0
# Description: Installe les Skills Claude Code pour l'analyse des PR GitHub

readonly REPO_URL="https://github.com/sebc-dev/cc-skills"
readonly REPO_BRANCH="main"
declare PROJECT_ROOT
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
readonly PROJECT_ROOT
readonly SKILLS_DIR="${PROJECT_ROOT}/.claude/skills"
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
mkdir -p "$SKILLS_DIR"/{github-pr-collector/scripts,review-analyzer/resources}
mkdir -p "$DATA_DIR"/github-pr-collector/{data,cache,config}
mkdir -p "$DATA_DIR"/review-analyzer/{data,cache,config}

echo -e "${GREEN}✅ Structure créée:${NC}"
echo "  📂 $SKILLS_DIR (Skills Claude Code)"
echo "  📂 $DATA_DIR (Données par skill)"

# Téléchargement des Skills depuis le repository
echo -e "${BLUE}📥 Téléchargement des Skills depuis le repository...${NC}"

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

# Télécharger les fichiers du skill github-pr-collector
echo -e "${BLUE}📦 Installation du skill: github-pr-collector${NC}"
download_file ".claude/skills/github-pr-collector/SKILL.md" \
    "$SKILLS_DIR/github-pr-collector/SKILL.md"
download_file ".claude/skills/github-pr-collector/scripts/collect-pr-data.sh" \
    "$SKILLS_DIR/github-pr-collector/scripts/collect-pr-data.sh"

# Télécharger les fichiers du skill review-analyzer
echo -e "${BLUE}📦 Installation du skill: review-analyzer${NC}"
download_file ".claude/skills/review-analyzer/SKILL.md" \
    "$SKILLS_DIR/review-analyzer/SKILL.md"
download_file ".claude/skills/review-analyzer/resources/analysis-templates.md" \
    "$SKILLS_DIR/review-analyzer/resources/analysis-templates.md" || true

# Télécharger les fichiers de configuration
echo -e "${BLUE}⚙️  Installation des fichiers de configuration${NC}"
download_file ".scd/github-pr-collector/config/agents-patterns.json" \
    "$DATA_DIR/github-pr-collector/config/agents-patterns.json"
download_file ".scd/github-pr-collector/config/severity-mapping.json" \
    "$DATA_DIR/github-pr-collector/config/severity-mapping.json"

# Vérification de l'installation
echo -e "${BLUE}🔍 Vérification de l'installation...${NC}"

readonly -a REQUIRED_FILES=(
    "$SKILLS_DIR/github-pr-collector/SKILL.md"
    "$SKILLS_DIR/github-pr-collector/scripts/collect-pr-data.sh"
    "$SKILLS_DIR/review-analyzer/SKILL.md"
    "$DATA_DIR/github-pr-collector/config/agents-patterns.json"
    "$DATA_DIR/github-pr-collector/config/severity-mapping.json"
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
            echo "# CC-Skills runtime data (keep config/ for each skill)"
            echo ".scd/**/cache/"
            echo ".scd/**/data/"
            echo "!.scd/**/config/"
        } >> "${PROJECT_ROOT}/.gitignore"
        echo -e "${GREEN}✅ .gitignore mis à jour${NC}"
    else
        echo -e "${GREEN}✅ .gitignore déjà configuré${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Pas de .gitignore trouvé${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation terminée avec succès!${NC}"
echo -e "${BLUE}📂 Skills installés dans: $SKILLS_DIR${NC}"
echo -e "${BLUE}📊 Données stockées dans: $DATA_DIR${NC}"
echo ""
echo -e "${YELLOW}🚀 Pour commencer:${NC}"
echo "  1. Ouvrez Claude Code dans ce projet"
echo "  2. Assurez-vous d'être authentifié avec GitHub CLI: gh auth login"
echo "  3. Tapez: 'Analyse les PR en cours de ce repository'"
echo ""
echo -e "${BLUE}📖 Documentation: https://github.com/sebc-dev/cc-skills/tree/main/docs${NC}"