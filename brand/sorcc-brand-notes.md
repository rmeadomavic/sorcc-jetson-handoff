# SORCC Brand reference (extracted from style sheet v1, May 2026)

## Pronunciation / casing
- Pronounced "sork"
- Always **UPPER in prose**: SORCC. Never "Sorcc" or "sorcc."

## Color palette (canonical, do not invent alternates)
| Token | Hex | Role |
|---|---|---|
| DK_GREEN | #385723 | Primary. Headers, titles, badges, footer rule |
| MID_GREEN | #507A2F | Sub-sub headers, legacy gradient endpoint |
| OLIVE | #6B8E4E | Alt table header fill |
| SAGE | #A6BC92 | Dividers, accent rules, header bottom borders |
| ALT_ROW | #D5E8CD | Alternating table rows |
| PALE | #EFF5EB | Subtle backgrounds (NOT for table rows) |
| GRAY | #595959 | Body text, secondary labels |
| WHITE | #FFFFFF | Text on DK_GREEN |
| BLACK | #000000 | High-contrast body |
| PLACEHOLDER | #C00000 | Italic fill-in. Remove before delivery |

## Typography
**One font family across the entire system: Calibri.** No Times. No Helvetica. No Arial.
Monospace where needed: **Consolas**.

Letter-spacing is the visual tell. Every UPPERCASE header gets letter-spacing; mixed-case never does.
- Document Title: Calibri 18pt Bold, WHITE on DK_GREEN, UPPER, cs 60 (≈3pt tracking)
- Section Header: Calibri 13pt Bold, DK_GREEN, UPPER, cs 60
- Sub-Header: Calibri 11pt Bold, DK_GREEN, normal case
- Sub-sub: Calibri 10pt Bold, MID_GREEN, normal
- Table Col Header: 8pt Bold, DK_GREEN/WHITE, UPPER, cs 40
- Body: 10pt Regular, GRAY
- Footer: 7pt Regular, GRAY/SAGE
- Classification bar: 9pt Bold, DK_GREEN, UPPER, cs 80

## Component patterns
**Header bar** — full content width, ~0.5in tall, solid DK_GREEN fill. Left: logo. Right: title (white bold UPPER cs 60) + italic SAGE "Oak Grove Technologies" subtitle. SAGE bottom-border rule beneath.

**Section dividers** — paragraph with bottom SAGE 4pt rule. Section label above the rule, UPPER cs 60, DK_GREEN 13pt bold.

**Tables (modern minimal)**
- Vertical borders: NONE. Columns defined by whitespace.
- Header row fill: none, OLIVE, or DK_GREEN.
- Header bottom border: SAGE 4pt rule.
- Header text: UPPER cs 40 8pt bold.
- Body rows alternate ALT_ROW (#D5E8CD) and WHITE.
- Row separators: thin 1pt SAGE.
- Last row: DK_GREEN 6pt bottom border.

**Footer** — every page. SAGE top-border rule. Three-column footer text in 7pt Calibri GRAY:
- Left: SORCC [context]
- Center: UNCLASSIFIED (bold, cs 60)
- Right: CLASS XX-YY or context tag

## Banned in operational products
**No em dashes (—)** in OPORDs, checklists, student handouts. Read as AI/marketing tell. Use a period or a comma.

## Terminology
- "Uncrewed" not "Unmanned"
- "UxS / sUxS" not "UAS"
- "Jetson Orin Nano Super Developer's Kit" first ref; "Jetson" or "Orin Nano" after
- "SORCC CLASS 02-26" / "CLS 02-26", never "Class 8"

## Notes for this web project
- This handoff guide is **closer to instructor-tool / student-handout** category than CDRL deliverable.
- UNCLASSIFIED footer marker required.
- Em dashes banned (have to scrub the existing markdown).
