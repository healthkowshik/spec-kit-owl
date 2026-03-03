---
description: "Display spec vs non-spec line counts, character counts, and percentages"
scripts:
  sh: ../scripts/bash/metrics.sh
  ps: ../scripts/powershell/metrics.ps1
---

# Owl Metrics

Run the metrics script to display spec-to-code ratios for this repository.

```bash
{SCRIPT} $ARGUMENTS
```

Display the script's stdout output directly to the user. The output includes:
- Total spec lines and characters
- Total non-spec lines and characters
- Spec percentages (by lines and by characters)

If `--breakdown` is passed, a per-directory breakdown table is also shown.
