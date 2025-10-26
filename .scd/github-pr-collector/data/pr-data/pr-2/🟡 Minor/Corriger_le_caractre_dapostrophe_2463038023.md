# 🟡 Minor _⚠️ Potential issue_ Corriger le caractère d'apostrophe.

- **Auteur**: CodeRabbit Bot
- **Date**: 2025-01-29T08:00:44Z
- **URL**: https://github.com/sebc-dev/scd-cc/pull/2#discussion_r2463038023
- **PR**: #2

## Description

L'analyse statique détecte un caractère d'apostrophe incorrect. Vérifiez que vous utilisez une apostrophe droite (') plutôt qu'une apostrophe courbe (') pour garantir la cohérence typographique.

<details>
<summary>🧰 Tools</summary>

<details>
<summary>🪛 LanguageTool</summary>

[typographical] ~20-~20: Caractère d’apostrophe incorrect.
Context: ....scd/github-pr-collector/data/pr-data/` (`summary.md`) - Parse les données JSON st...

(APOS_INCORRECT)

</details>

</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>

```
In .claude/skills/review-analyzer/SKILL.md around line 20, the string contains a
curly/apostrophe (’) instead of a straight ASCII apostrophe ('). Replace the
curly apostrophe with the straight one so the line reads: Lit les résumés de PR
dans `.scd/github-pr-collector/data/pr-data/` (`summary.md`) using ' not ’ and
save the file with UTF-8 encoding.
```

</details>

<!-- This is an auto-generated comment by CodeRabbit -->
