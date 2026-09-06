# Clay Institute Compliance — P vs NP

This document implements **§4–§7 of the Millennium Prize Rules**
(https://www.claymath.org/millennium-problems/rules/,
https://www.claymath.org/wp-content/uploads/2022/03/millennium_prize_rules_0.pdf)
for this repository.

## Official Problem Description

- Cook, Stephen. *The P versus NP Problem.* Clay Mathematics Institute, 2000.
  https://www.claymath.org/wp-content/uploads/2022/06/pvsnp.pdf
- A paper that does not address the specific mathematical questions therein
  is not a Proposed Solution (§4.d), even if it addresses related questions.

## What Counts as a Qualifying Outlet (§6)

Must have ALL of (§6.e):
1. Named editorial board available for contact
2. Editor(s) with professional knowledge to identify appropriate referees
3. Published refereeing process ensuring review by appropriate experts
4. Inclusion in MathSciNet

CMI will not recommend journals, certify outlets, maintain a list, or
consider supplementary material (§6.b–d). Relaxed route §6(f) requires
SAB recommendation + BOD approval after expert advice that the solution
is likely correct.

**This GitHub repository is NOT a Qualifying Outlet and NOT a submission.**

## Two Stages After Publication (§7.a)

1. **General acceptance** — ≥2 years rigorous examination by the global
   mathematics community, in CMI's sole discretion. Indicators:
   independent journal articles/books, international conferences, awards
   (§7.a.i.4). Plausible solutions are "effectively unmissable."

2. **CMI examination** — If general acceptance is found and ≥2 years have
   elapsed, CMI decides whether detailed consideration is merited. If yes,
   SAB constitutes a Special Advisory Committee (≥1 SAB + ≥2 non-SAB
   international experts); each component is verified by one or more
   members (§7.a.ii). For P vs NP, resolution in *either* direction is
   evaluated by the standard procedure (§4.b).

No entitlement to explanation (§8). No CMI-affiliated entity will accept
invitations to recognize status during the examination period (§7.a.i.3).

## How This Repository Satisfies the Rules While Preserving Sovereignty

- **Dual license** (`LICENSE` §3): Mathematical content (theorems,
  SharedFoundation, HybridQuantumSAT/Basic, Bridge spec) under CC BY 4.0 /
  Apache 2.0 grants refereed-publication rights, arXiv deposit, and
  MathSciNet-indexable verification. Engineering implementation remains
  Sovereign Source License v1.0.
- **Publication grant** (`LICENSE` §5): Authors may submit to any Qualifying
  Outlet and transfer customary publication rights without further permission.
- **Attribution**: Required citation preserves fingerprint SDC-Ω-∂-2026-PVSNP
  (F(53)%107=8, π(108)=72, 64=55+8+1).
- **Status**: P vs NP remains **UNRESOLVED** in this repository. No axiom
  assumes P=NP or P≠NP (`SharedFoundation/PinNP.lean:pVsNP_status = .unresolved`).

## Checklist for Authors Pursuing Clay Consideration

- [ ] Publish complete mathematical solution addressing Cook's official
      description in a Qualifying Outlet
- [ ] Ensure outlet is MathSciNet-indexed and refereeing is documented
- [ ] Wait ≥2 years post-publication; cultivate independent citations,
      conference discussion, and scrutiny
- [ ] Do not submit directly to CMI; do not send supplementary material
- [ ] Retain attribution to this repository's Mathematical Content per LICENSE §4

Questions about licensing for publication: jessicalw34@gmail.com
Questions about Clay Rules: contact CMI per https://www.claymath.org/millennium-problems/rules/
