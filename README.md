# Architecture CC-Skills

Cette architecture implémente les Skills Claude Code pour l'analyse des Pull Requests GitHub avec support multi-agents IA.

## Structure du Projet

```
cc-skills/
├── .claude/                       # Skills Claude Code (installés localement)
│   └── skills/
│       ├── github-pr-collector/   # Skill de collecte des PR
│       │   ├── SKILL.md          # Définition du skill
│       │   └── scripts/          # Scripts bash (à implémenter)
│       │       ├── collect-pr-data.sh
│       │       ├── parse-review-agents.sh
│       │       └── generate-summary.sh
│       └── review-analyzer/       # Skill d'analyse des données
│           ├── SKILL.md          # Définition du skill
│           └── resources/
│               └── analysis-templates.md  # Templates de rapports
├── .scd/                          # Données des analyses (dans le projet)
│   ├── pr-data/                   # Données des Pull Requests
│   │   └── [Structure générée dynamiquement]
│   │       ├── pr-{number}/       # Dossier par PR
│   │       │   ├── 🔴-critical/   # Commentaires critiques
│   │       │   ├── 🟠-major/      # Commentaires majeurs
│   │       │   ├── 🟡-minor/      # Commentaires mineurs
│   │       │   ├── 🔵-trivial/    # Commentaires triviaux
│   │       │   ├── summary.md     # Résumé de la PR
│   │       │   └── data.json      # Données brutes
│   │       └── global-summary.md  # Résumé global
│   ├── config/                    # Configuration des agents
│   │   ├── agents-patterns.json   # Patterns pour tous les agents
│   │   └── severity-mapping.json  # Mapping de sévérité
│   └── cache/                     # Cache temporaire
├── install/
│   └── install.sh                # Script d'installation
├── docs/
│   └── Guide_Skills_Claude_Code_Bash_GitHub_CodeRabbit.md
└── README.md
```

## Skills Créés

### 1. github-pr-collector
- **Objectif :** Collecter et organiser les commentaires des agents IA sur les PR
- **Supports :** CodeRabbit, GitHub Copilot, Codex, agents génériques
- **Sortie :** Structure organisée par PR et par importance

### 2. review-analyzer
- **Objectif :** Analyser les données collectées et générer des insights
- **Fonctionnalités :** Rapports exécutifs, techniques, comparaisons inter-agents
- **Templates :** Prédéfinis pour différents types de rapports

## Configuration

### agents-patterns.json
Définit la détection et classification des agents IA :
- Patterns de détection par agent
- Classification de sévérité par emojis/mots-clés
- Catégories de commentaires
- Patterns de fichiers et niveaux de confiance

### severity-mapping.json
Configure la hiérarchie des sévérités :
- Ordre de priorité (critical > major > minor > trivial)
- Mapping des dossiers avec emojis
- Seuils de qualité et recommandations d'actions
- Métriques et alertes

## Installation

```bash
# Installation en une ligne
curl -fsSL https://raw.githubusercontent.com/negus/cc-skills/main/install/install.sh | bash

# Ou installation locale
./install/install.sh
```

## Utilisation

1. **Collecte des données :**
   ```
   "Analyse les PR en cours de ce repository"
   ```

2. **Analyse approfondie :**
   ```
   "Analyse les reviews des agents IA collectées"
   ```

## Prérequis

- GitHub CLI (`gh`) >= 2.0.0
- jq >= 1.6
- bash >= 4.0
- Authentification GitHub CLI (`gh auth login`)

## Extensibilité

L'architecture est conçue pour être facilement extensible :

1. **Nouveaux agents IA :** Ajouter dans `agents-patterns.json`
2. **Nouvelles catégories :** Étendre `category_patterns`
3. **Nouveaux seuils :** Modifier `severity-mapping.json`
4. **Nouveaux templates :** Ajouter dans `analysis-templates.md`

## États des Composants

- ✅ **Architecture créée**
- ✅ **Skills définis** (SKILL.md)
- ✅ **Configuration JSON**
- ✅ **Templates de rapports**
- ✅ **Script d'installation**
- ⏳ **Scripts bash** (à implémenter)

## Prochaines Étapes

1. Implémenter les scripts bash dans `github-pr-collector/scripts/`
2. Tester l'installation sur un projet réel
3. Valider la détection des agents IA
4. Affiner les patterns selon les retours d'usage