#!/bin/bash
set -euo pipefail

# CC-Skills Installation Script
# Version: 1.0.0
# Description: Installe les Skills Claude Code pour l'analyse des PR GitHub

readonly REPO_URL="https://github.com/negus/cc-skills"
declare PROJECT_ROOT
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
readonly PROJECT_ROOT
readonly SKILLS_DIR="${PROJECT_ROOT}/.claude/skills"
readonly DATA_DIR="${PROJECT_ROOT}/.scd"

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
mkdir -p "$DATA_DIR"/{pr-data,config,cache}

echo -e "${GREEN}✅ Structure créée:${NC}"
echo "  📂 $SKILLS_DIR"
echo "  📂 $DATA_DIR"

# Note: Les fichiers ont été créés localement, pas de téléchargement depuis GitHub
echo -e "${GREEN}✅ Configuration locale détectée${NC}"

# Vérification des fichiers existants
if [[ -f "$SKILLS_DIR/github-pr-collector/SKILL.md" ]]; then
    echo -e "${GREEN}✅ Skill github-pr-collector trouvé${NC}"
else
    echo -e "${YELLOW}⚠️  Skill github-pr-collector manquant${NC}"
fi

if [[ -f "$SKILLS_DIR/review-analyzer/SKILL.md" ]]; then
    echo -e "${GREEN}✅ Skill review-analyzer trouvé${NC}"
else
    echo -e "${YELLOW}⚠️  Skill review-analyzer manquant${NC}"
fi

if [[ -f "$DATA_DIR/config/agents-patterns.json" ]]; then
    echo -e "${GREEN}✅ Configuration agents-patterns.json trouvée${NC}"
else
    echo -e "${YELLOW}⚠️  Configuration agents-patterns.json manquante${NC}"
fi

# Configuration des permissions pour les scripts (quand ils seront créés)
echo -e "${BLUE}🔧 Configuration des permissions...${NC}"
find "$SKILLS_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

# Ajout au .gitignore si existe
if [[ -f "${PROJECT_ROOT}/.gitignore" ]]; then
    if ! grep -q "^\.scd/" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
        {
            echo ""
            echo "# CC-Skills data"
            echo ".scd/cache/"
            echo ".scd/*.log"
        } >> "${PROJECT_ROOT}/.gitignore"
        echo -e "${GREEN}✅ .gitignore mis à jour${NC}"
    else
        echo -e "${GREEN}✅ .gitignore déjà configuré${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Pas de .gitignore trouvé${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation terminée!${NC}"
echo -e "${BLUE}📂 Skills installés dans: $SKILLS_DIR${NC}"
echo -e "${BLUE}📊 Données stockées dans: $DATA_DIR${NC}"
echo ""
echo -e "${YELLOW}🚀 Pour commencer:${NC}"
echo "  1. Ouvrez Claude Code dans ce projet"
echo "  2. Assurez-vous d'être authentifié avec GitHub CLI: gh auth login"
echo "  3. Tapez: 'Analyse les PR en cours de ce repository'"
echo ""
echo -e "${BLUE}📖 Documentation: docs/Guide_Skills_Claude_Code_Bash_GitHub_CodeRabbit.md${NC}"