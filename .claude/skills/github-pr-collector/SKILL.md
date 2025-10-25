---
name: "github-pr-collector"
description: "Collecte et analyse les Pull Requests GitHub avec leurs commentaires d'agents de review IA (CodeRabbit, GitHub Copilot, Codex, etc.). Utilise GitHub CLI pour récupérer les données, extrait les métadonnées des agents avec jq, et génère une structure organisée par PR et par importance dans le dossier .scd du projet. Extensible pour supporter de nouveaux agents de review."
version: "1.0.0"
dependencies:
  - "github-cli >= 2.0.0"
  - "jq >= 1.6"
---

# GitHub PR Collector Skill

## Objectif

Ce skill automatise la collecte et l'extraction des données des Pull Requests GitHub, avec support pour multiple agents de review IA (CodeRabbit, GitHub Copilot, Codex, et autres). Il optimise l'utilisation des tokens en préprocessant les données via des scripts Bash et organise les commentaires par PR et par niveau d'importance.

## Processus

### 1. Collecte des Données

Le skill utilise le script `collect-pr-data.sh` pour :
- Identifier le repository courant via `gh repo view`
- Récupérer la liste des PR en cours avec `gh pr list`
- Pour chaque PR, extraire les métadonnées complètes
- Télécharger tous les commentaires de review

### 2. Extraction des Métadonnées des Agents IA

Via `parse-review-agents.sh`, le skill :
- Identifie les commentaires provenant des agents IA (CodeRabbit, Copilot, Codex, etc.)
- Extrait les métadonnées de classification (⚠️ Potential issue, 🟠 Major, etc.)
- Classe les commentaires par agent, type et importance
- Crée une structure organisée : PR > Importance > Commentaire individuel
- Architecture extensible pour supporter de nouveaux agents

### 3. Génération de Résumés

Le script `generate-summary.sh` produit :
- Validation de chaque étape du processus avec indicateurs visuels
- Statistiques concises par PR et globales
- Fichier `summary.md` par PR avec métriques essentielles
- Rapport global `global-summary.md` avec vue d'ensemble

## Utilisation

### Déclencheurs Typiques
- "Analyse les PR en cours de ce repository"
- "Que disent les agents de review sur les dernières PR ?"
- "Donne-moi un résumé des reviews des PR ouvertes"
- "Quels sont les problèmes identifiés par les agents IA ?"

### Sortie

Les données sont stockées dans `.scd/pr-data/` avec la structure :
```
pr-{number}/
├── 🔴-critical/     # Commentaires critiques
├── 🟠-major/        # Commentaires majeurs  
├── 🟡-minor/        # Commentaires mineurs
├── 🔵-trivial/      # Commentaires triviaux
├── summary.md       # Résumé de la PR
└── data.json        # Données brutes
```

Un résumé est affiché à l'utilisateur avec :
- Nombre de PR analysées
- Distribution des types de commentaires par agent
- Principales préoccupations identifiées
- Lien vers les fichiers détaillés générés

## Gestion des Erreurs

Le skill gère gracieusement :
- L'absence de GitHub CLI ou d'authentification
- Les repositories sans PR
- Les PR sans commentaires d'agents IA
- Les limites de taux de l'API GitHub

## Référence

Les scripts utilisent les ressources suivantes :
- `scripts/collect-pr-data.sh` - Collection GitHub CLI
- `scripts/parse-review-agents.sh` - Parsing jq des métadonnées multi-agents
- `scripts/generate-summary.sh` - Génération résumés avec validation visuelle