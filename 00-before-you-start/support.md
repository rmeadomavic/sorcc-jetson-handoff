# Support

This repo is self-serve. The docs here exist so you can solve your own problems without having to wait for help.

## Before you ask for help

Run through this checklist first. 90% of "it doesn't work" gets fixed at one of these steps.

1. **Did you read the relevant doc end-to-end?** Skimming misses the warning callouts. The lowercase-L typo trap in QSPI is in a callout, not the body text.
2. **Did `bash scripts/preflight.sh` pass?** It tells you exactly which step you're stuck on. Run it before reading anything else.
3. **Did you check `01-flash-and-update/troubleshooting.md`?** Every failure mode someone has hit lives there.
4. **Did you Google the exact error message in quotes?** NVIDIA's developer forums and the JetsonHacks site cover most JetPack issues better than anyone.
5. **Did you try a clean reflash?** Bad SD card flashes are more common than you'd think. Etcher with verify enabled, or use a different card.

## When to file an issue

File an issue when:

- You followed a doc exactly and the result doesn't match what the doc says
- You found a step that's wrong, outdated, or missing
- A command in a script fails and the error doesn't match anything in troubleshooting

Use the templates in `.github/ISSUE_TEMPLATE/`. Fill them in completely — vague issues get vague answers.

## When NOT to file an issue

- Generic Jetson questions unrelated to SORCC → try [NVIDIA's developer forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/jetson-embedded-systems/70).
- Hydra runtime / behavior questions → file against the Hydra repo, not this one.

## Out-of-band help

If your Jetson is bricked and you need direct support, reach out through the channel you were given at the end of class. Include:

- Which SORCC class you attended (e.g. "CLS 8 student")
- What step in the docs you were on
- The exact error message or symptom
- Output of `bash scripts/preflight.sh`

For non-urgent feature requests or doc improvements, file an issue on the repo.
