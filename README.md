# Paper2 — finite orthogonal difference-in-differences

**Target GitHub repository name:** `Paper2_Causal_Discovery_DID`. The Lean package remains `paper2` and the namespace remains `Paper2`.

**Author and responsible maintainer:** Antonio Lam García.

This repository contains the substantive Lean development of two finite
statistical identities/results accompanying the revised Paper2 preprint.
It adapts the orthogonal DiD CATT risk of Lan et al. (2025); it does not claim
to invent doubly robust DiD or to prove the full causal-discovery conjecture.

## Recorded mathematical claims

1. **Paper2.finite_cell_CATT_bias.** For a finite covariate law and any cell
   of positive treated probability, the treated-normalized signal equals
   the treated contrast plus its exact product nuisance bias. The bias
   vanishes when either nuisance is correct. Fitted denominators must not
   vanish; causal identification of the contrast is an external assumption.
2. **Paper2.finite_orthogonal_product_bound.** For finite W and X=W, positive
   overlap and treated mass, a fitted-nuisance excess population risk bound
   implies treated MSE at most 2 epsilon plus 4/(rho c³) times the product of
   squared L4 nuisance errors. The proof derives the signal/risk identities,
   pointwise Young inequality and weighted Cauchy–Schwarz bound. The learning
   hypothesis remains explicit.

The precise definitions, hypotheses and proof outline are in
[docs/MATHEMATICAL_ACCOUNT.md](docs/MATHEMATICAL_ACCOUNT.md).
The selected statements are the declarations named in comparator.json.

## Repository map

| Path | Purpose |
|---|---|
| Challenge.lean | Small, self-contained statement surface with complete proofs. |
| Solution.lean | Matching definitions and proofs in a separate module. |
| Math/ | Auxiliary finite-probability, scalar and supplied-graph formalizations. |
| Audit.lean | Audits Math/Solution: 26 declarations. |
| AuditChallenge.lean | Independently audits six parallel Challenge declarations. |
| comparator.json | Selects two results and the three permitted standard axioms. |
| formalization.yaml | v0.4 metadata, sources, automation, review and limitations. |
| lean-toolchain, lakefile.toml, lake-manifest.json | Lean and dependency pins. |
| LICENSE | Confirmed MIT repository license. |
| scripts/ | Preliminary repository checks and a read-only submission summary helper. |
| .github/workflows/ | Manual ordinary CI and official full mechanical preflight. |
| evidence/ | Dated local execution evidence and preparation checks. |
| SHA256SUMS.txt | File-integrity manifest, excluding itself. |

Challenge and Solution are independent modules declaring the same Paper2 names;
do not import them together in a third module. Both are proof-complete, including
Challenge. The only proof axioms are propext, Classical.choice and Quot.sound.
The six Challenge checks are parallel audits, not six additional mathematical
results. The extra Math/ claims retain their explicit hypotheses and are not
selected for registration.

## Local checks

Install Elan, Git and Python 3.10 or later. Python 3.11+ is also supported.

    python -m pip install -r scripts/requirements-validation.txt
    python scripts/validate_repository.py --root . --check-hashes
    lake exe cache get
    lake build
    lake env lean Audit.lean
    lake env lean AuditChallenge.lean

Lean is pinned to 4.35.0. Mathlib is pinned to
56a005855ea17e0b0958f73ec801ae140b0a1679, whose toolchain matches exactly.
Fetching the locked dependency closure may use several GiB and requires network
access if not cached. Do not commit .lake, compiled artifacts or credentials.

On Windows, ./validar.ps1 repeats compilation and audits;
./validar.ps1 -ComparatorWindows additionally runs the explicitly unisolated
compatibility check. On Linux, bash validar.sh --comparator adds a sandboxed
Comparator run. The preliminary Python script is not Palomar's verifier.

## GitHub and Palomar

**Use this directory itself as the GitHub repository root.** Do not upload
the enclosing Paper2 folder or omit hidden .github files.
Spanish instructions are in [docs/GUIA_GITHUB_PALOMAR.md](docs/GUIA_GITHUB_PALOMAR.md).

After publishing a public snapshot, run the two manually triggered workflows:

- Lean checks (ordinary CI): local-style source, metadata, build and audit checks.
- Palomar full mechanical preflight: the official reusable workflow, mode full,
  execution_profile palomar-standard-v1. Its uses reference and pipeline_commit
  are pinned to the same upstream revision.

The responsible author/maintainer must truthfully confirm that relationship
when starting the full preflight. A passing ordinary job does not replace the
official mechanical report. New source or metadata requires a new commit.
scripts/resumen_envio.ps1 prints the Git repository and full commit when available;
it does not push, authenticate, create a request, or register the work.

Public repository publication, official preflight execution, Palomar protected
verification, editorial review and registration have not been completed while
preparing this directory. Local evidence cannot establish their future outcome.
Read [Palomar's submission guide](https://palomar-registry.org/how-to-submit)
and [agent protocol](https://submit.palomar-registry.org/llms.txt).

## Scope, provenance and licence

The selected risk theorem is finite and X=W. It does not establish causal
identification, general conditional expectations, matrix concentration,
shared-fold learning guarantees, normal CATT inference or learned augmented PAGs.
The supporting selection-DAG certificates do not prove that CPT is false.
The mathematical account separates proven implications from assumed hypotheses.

The author confirmed MIT for Paper2 Lean code and proofs. This directory
contains that development and its accompanying technical documentation.
Cited publications, separately distributed datasets/preprint and dependencies
retain their respective licences. No dataset or externally authored paper is
included as part of the repository source.

References:
- Lan et al. (2025), [A Meta-learner for Heterogeneous Effects in
  Difference-in-Differences](https://proceedings.mlr.press/v267/lan25a.html).
- Foster and Syrgkanis (2023), [Orthogonal Statistical
  Learning](https://arxiv.org/abs/1901.09036).

Formalization, source revision, AI assistance and agent review are disclosed in
formalization.yaml. Agent review is not human expert peer review or Palomar
editorial approval.
