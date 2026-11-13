# Mathematical account of the selected finite results

Paper2. Author and proposed responsible maintainer: Antonio Lam García.
Prepared on 8 November 2026, America/Lima.

This is an ordinary mathematical account of the two declarations selected in
`comparator.json`. It is a review aid, not a claim of new statistical
methodology, human peer review, public publication or Palomar registration.

## Definitions and interpretation

Let W be a finite type. `Paper2.Law W` supplies real weights a(w) ≥ 0 with
∑w a(w)=1. Let p, p̂, μ₁, μ₀, m and θ be real functions on W. Their
statistical interpretations are the true and fitted treatment propensities,
two group-specific means of an outcome difference, a fitted control mean, and
a candidate contrast. The Lean declarations quantify over numbers and
functions; they do not construct a sampled panel or infer a causal model.
Put τ(w)=μ₁(w)−μ₀(w). Both proof modules independently define

$$
s(w)=p(w)(\mu_1(w)-m(w))
 -(1-p(w))\frac{\widehat p(w)}{1-\widehat p(w)}(\mu_0(w)-m(w)),
$$

$$
q(w)=\frac{(m(w)-\mu_0(w))(\widehat p(w)-p(w))}{1-\widehat p(w)},
\qquad R(\theta)=\sum_w a(w)\{p(w)\theta(w)^2-2\theta(w)s(w)\}.
$$

These are `signal`, `bias` and `risk`. For a cell A ⊆ W,

$$
\rho_A=\sum_{w\in A}a(w)p(w),\qquad
\operatorname{CATT}_A=
\frac{\sum_{w\in A}a(w)p(w)\tau(w)}{\rho_A}
$$

are `treatedMass` and `catt`. The theorem requires positive treated mass when
this conditional mean is used. For A=W write ρ=∑w a(w)p(w). The normalized
risk is **L=R/ρ**. Lean's `risk` is R, not L; its learning hypothesis divides
the risk difference by ρ explicitly.

For a Bernoulli indicator D with propensity p and an outcome difference ΔY
having the specified group means, s(w) equals the conditional mean given W=w
of ψ=(D−p̂(W))/(1−p̂(W))·(ΔY−m(W)). Interpreting τ or its treated cell average
as a causal effect additionally requires consistency, absence of anticipation,
conditional parallel trends and an admissible adjustment set. The selected
declarations do not establish or learn those identification assumptions.

## The conditional cell identity

`Paper2.finite_cell_CATT_bias` assumes a finite W, a law, a cell A and the five
functions p, p̂, μ₁, μ₀, m. Its remaining hypotheses are 0≤p(w)≤1 everywhere,
ρA>0, and 1−p̂(w)≠0 on A. It proves

$$
\frac{\sum_{w\in A}a(w)s(w)}{\rho_A}
=\operatorname{CATT}_A+\frac{\sum_{w\in A}a(w)q(w)}{\rho_A}.
$$

The proof clears the nonzero denominator to establish
s(w)=p(w)τ(w)+q(w), multiplies by a(w), sums over A and distributes division
by ρA. The remainder vanishes if m=μ₀ or if p̂=p on the cell, giving the two
algebraic double-robustness branches. A can be a fiber of a coarsening X(W).
That observation concerns this cell identity, not a general coarsened version
of the next risk theorem.

## The finite product-risk bound

`Paper2.finite_orthogonal_product_bound` assumes a finite law, the six
functions p, p̂, μ₁, μ₀, m, θ, real numbers c and ε, and

$$
c>0,\quad c\le p(w)\le1-c,\quad
c\le\widehat p(w)\le1-c,\quad \rho>0,\quad
\frac{R(\theta)-R(\tau)}{\rho}\le\varepsilon.
$$

It proves

$$
\frac{\sum_w a(w)p(w)(\theta(w)-\tau(w))^2}{\rho}
\le 2\varepsilon+\frac4{\rho c^3}
\sqrt{\sum_w a(w)(m(w)-\mu_0(w))^4}
\sqrt{\sum_w a(w)(\widehat p(w)-p(w))^4}.
$$

The square roots are squared L⁴ errors under the law a. The target specializes
to **X=W finite**. The theorem assumes neither the final squared-error bound
nor an already bounded nuisance bias. Its explicit excess-risk learning
condition remains a genuine hypothesis, not a guarantee for an arbitrary fit.

For the proof put h=θ−τ and S=∑w a(w)p(w)h(w)². The signal identity gives

$$
R(\theta)-R(\tau)=S-2\sum_w a(w)h(w)q(w).
$$

Young's inequality and overlap yield, pointwise,

$$
2h(w)q(w)\le\frac{p(w)h(w)^2}{2}
+\frac2{c^3}(m(w)-\mu_0(w))^2(\widehat p(w)-p(w))^2.
$$

Summing with nonnegative weights and using the learning condition gives
S≤2ρε+4c⁻³∑w a(w)(m(w)−μ₀(w))²(p̂(w)−p(w))². Weighted Cauchy–Schwarz
bounds the mixed fourth-order sum by the product displayed above. Division
by ρ completes the proof. These steps are proved in `signal_identity`,
`risk_decomposition`, `pointwise_young` and `weighted_fourth`.

## Provenance, module structure and limits

The statistical motivation is the orthogonal convex-risk and doubly robust
CATT approach of Hui Lan, Haoge Chang, Eleanor Wiske Dillon and Vasilis
Syrgkanis, [A Meta-learner for Heterogeneous Effects in Difference-in-Differences](https://proceedings.mlr.press/v267/lan25a.html),
ICML 2025, PMLR 267, pp. 32420–32451. Paper2 adapts this line of work to the
finite statements above. It does not claim to invent doubly robust DiD,
formalize every result of that paper, or establish novelty by compilation.
Risk normalizations and learning hypotheses must be translated before
comparing constants across sources.

`Challenge.lean` and `Solution.lean` define the same ordinary objects and
selected theorem types. Both contain complete proofs and neither imports the
other. `Audit.lean` checks Math/Solution; `AuditChallenge.lean` checks Challenge
separately. Importing both proof modules together would conflict because
their names coincide. The comparator checks the selected declarations across
separate environments. The 26 declarations audited in Math/Solution and six
parallel Challenge declarations are not 32 different mathematical results.

The auxiliary `Math/` modules retain their explicit scalar and supplied-graph
hypotheses. They do not establish identification or learning of an augmented
counterfactual PAG. The selected claims also do not formalize general measure
spaces, concentration probabilities, shared-fold cross-fitting guarantees,
asymptotic normality, confidence bands or an empirical application. Local
Lean/NanoDa evidence and technical agent review do not replace Palomar's
protected verification, editorial review or registration, all still pending.
