---
name: "review-analyzer"
description: "Analyse les commentaires de review des agents IA préalablement collectés et génère des insights approfondis. Utilise les données structurées du dossier .scd pour fournir des analyses de tendances, des recommandations d'amélioration et des métriques de qualité. À utiliser après avoir collecté les données avec github-pr-collector."
version: "1.0.0"
dependencies:
  - "github-pr-collector >= 1.0.0"
---

# Review Analyzer Skill

## Objectif

Ce skill analyse les données de review des agents IA préalablement collectées et stockées dans `.scd/pr-data/` pour générer des insights approfondis, des tendances et des recommandations d'amélioration pour l'équipe de développement.

## Processus d'Analyse

### 1. Analyse des Données Collectées

Le skill examine les fichiers générés par `github-pr-collector` :
- Lit les résumés de PR (`summary.md`)
- Parse les données JSON structurées (`data.json`)
- Analyse la distribution dans les dossiers par sévérité
- Examine les commentaires individuels par agent

### 2. Génération d'Insights

#### Métriques de Qualité
- Distribution des sévérités des commentaires par agent
- Tendances par fichier/répertoire
- Types de problèmes les plus fréquents par agent IA
- Évolution temporelle de la qualité

#### Analyses Comportementales
- Patterns de review récurrents par agent
- Comparaison entre agents (CodeRabbit vs Copilot vs Codex)
- Catégories de problèmes dominantes
- Impact des corrections sur les métriques

#### Recommandations
- Zones du code nécessitant plus d'attention
- Formations recommandées pour l'équipe
- Processus d'amélioration suggérés
- Configuration optimale des agents

### 3. Génération de Rapports

Le skill produit plusieurs types de rapports :
- **Rapport Exécutif** : Vue d'ensemble pour le management
- **Rapport Technique** : Analyse détaillée pour les développeurs
- **Rapport par Agent** : Performance et insights spécifiques par IA
- **Plan d'Action** : Recommandations prioritaires

## Utilisation

### Déclencheurs Typiques
- "Analyse les reviews des agents IA collectées"
- "Quelles sont les tendances des commentaires des agents ?"
- "Génère un rapport sur la qualité du code basé sur les agents IA"
- "Compare les performances entre CodeRabbit et Copilot"
- "Que nous apprennent les reviews IA sur notre code ?"

### Prérequis
Les données doivent avoir été collectées au préalable avec le skill `github-pr-collector`.

## Templates de Rapports

Le skill utilise des templates prédéfinis dans `resources/analysis-templates.md` pour générer des rapports cohérents et professionnels.

## Personnalisation

L'analyse peut être personnalisée via :
- Filtres par période
- Focus sur des agents spécifiques
- Focus sur des catégories spécifiques
- Seuils de sévérité ajustables
- Métriques personnalisées

## Extensibilité

Le système est conçu pour s'adapter automatiquement :
- Nouveaux agents détectés dans les données
- Nouvelles catégories de commentaires
- Nouveaux patterns de sévérité
- Évolution des métadonnées des agents