# Architecture SCD-CC

Cette architecture implémente les Skills Claude Code pour l'analyse des Pull Requests GitHub avec support multi-agents IA.

## Structure du Projet

```
scd-cc/
├── .claude/
│   ├── agents/                    # Subagents Claude Code
│   │   └── pr-review-analyzer.md  # Subagent d'analyse des PR
│   └── skills/                    # Skills Claude Code
│       └── github-pr-collector/   # Skill de collecte des PR
│           ├── SKILL.md          # Définition du skill
│           └── scripts/          # Scripts bash (à implémenter)
│               ├── collect-pr-data.sh
│               ├── parse-review-agents.sh
│               └── generate-summary.sh
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

## Composants Créés

### Skills Claude Code

#### 1. github-pr-collector
- **Type :** Skill (exécution automatique via bash)
- **Objectif :** Collecter et organiser les commentaires des agents IA sur les PR
- **Supports :** CodeRabbit, GitHub Copilot, Codex, agents génériques
- **Sortie :** Structure organisée par PR et par importance dans `.scd/pr-data/`

### Subagents Claude Code

#### 2. pr-review-analyzer
- **Type :** Subagent (IA spécialisée avec contexte séparé)
- **Objectif :** Analyser les données collectées et générer des insights approfondis
- **Capacités :**
  - Analyse de tendances et patterns récurrents
  - Génération de rapports exécutifs et techniques
  - Recommandations d'amélioration priorisées
  - Métriques de qualité et scores
- **Tools :** Read-only (Read, Grep, Glob) pour sécurité
- **Model :** Sonnet (optimisé pour l'analyse)

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
curl -fsSL https://raw.githubusercontent.com/sebc-dev/scd-cc/main/install/install.sh | bash

# Ou installation locale
./install/install.sh
```

## Utilisation

### Workflow Complet (Recommandé)

1. **Collecte automatique des données :**
   ```
   "Analyse les PR en cours de ce repository"
   ```
   → Le skill `github-pr-collector` collecte et structure les données
   → Le subagent `pr-review-analyzer` est automatiquement invoqué pour l'analyse

### Workflow Étape par Étape

1. **Collecte uniquement :**
   ```
   "Collecte les données des PR"
   ```

2. **Analyse approfondie :**
   ```
   "Utilise le subagent pr-review-analyzer pour analyser les données collectées"
   ```

### Analyses Spécialisées

- **Focus sécurité :**
  ```
  "Quels sont les problèmes de sécurité dans les PR collectées ?"
  ```

- **Tendances :**
  ```
  "Quelles sont les tendances des reviews sur les dernières PR ?"
  ```

- **Rapport pour management :**
  ```
  "Génère un rapport exécutif pour le management"
  ```

Voir `.claude/agents/EXAMPLES.md` pour plus d'exemples détaillés.

## Prérequis

- GitHub CLI (`gh`) >= 2.0.0
- jq >= 1.6
- bash >= 4.0
- Authentification GitHub CLI (`gh auth login`)

## Extensibilité

L'architecture Skill+Subagent est conçue pour être facilement extensible :

### Niveau Skill (Collecte)
1. **Nouveaux agents IA :** Ajouter dans `agents-patterns.json`
2. **Nouvelles catégories :** Étendre `category_patterns`
3. **Nouveaux seuils :** Modifier `severity-mapping.json`

### Niveau Subagent (Analyse)
1. **Nouveaux types de rapports :** Le subagent s'adapte aux demandes
2. **Métriques personnalisées :** Demander des analyses spécifiques
3. **Intégrations :** Connecter avec Slack, Jira via extensions

### Pourquoi Skill + Subagent ?

**Skill (github-pr-collector)** :
- ✅ Tâches déterministes (collecte, parsing, classification)
- ✅ Économie de tokens (bash optimisé)
- ✅ Reproductibilité parfaite
- ✅ Pas de contexte IA nécessaire

**Subagent (pr-review-analyzer)** :
- ✅ Analyse intelligente et contextuelle
- ✅ Génération de insights complexes
- ✅ Adaptation aux demandes variées
- ✅ Contexte séparé (pas de pollution du contexte principal)
- ✅ Spécialisation de l'IA

## États des Composants

- ✅ **Architecture Skill+Subagent créée**
- ✅ **Skill github-pr-collector défini** (SKILL.md)
- ✅ **Subagent pr-review-analyzer créé** (.claude/agents/)
- ✅ **Configuration JSON** (agents-patterns, severity-mapping)
- ✅ **Exemples d'utilisation détaillés** (EXAMPLES.md)
- ✅ **Script d'installation**
- ⏳ **Scripts bash** (à implémenter)

## Documentation

- **Architecture complète :** `docs/Guide_Skills_Claude_Code_Bash_GitHub_CodeRabbit.md`
- **Exemples subagent :** `.claude/agents/EXAMPLES.md`
- **Sécurité bash :** `docs/bash/Sécurisation des Scripts Bash _ Bonnes Pratiques.md`
- **Claude Code Skills :** `docs/claude-code/`
- **Claude Code Subagents :** `docs/claude-code/Subagents - Claude Docs.md`

## Prochaines Étapes

1. Implémenter les scripts bash dans `github-pr-collector/scripts/`
2. Tester l'installation sur un projet réel
3. Valider la détection des agents IA
4. Affiner les patterns selon les retours d'usage