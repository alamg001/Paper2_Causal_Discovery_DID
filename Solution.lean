module

public import Mathlib.Algebra.Order.BigOperators.Ring.Finset
public import Mathlib.Analysis.Real.Sqrt
public import Mathlib.Tactic.FieldSimp
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.Ring

/-!
# Finite-population orthogonal DiD risk

The formal result concerns a finite covariate W. Identification of mu1-mu0
as a causal contrast is external (consistency, no anticipation and CPT).
The learning hypothesis is excess population risk at the fitted nuisance;
neither the target squared-error bound nor a nuisance-bias bound is assumed.
It is deterministic conditional on fitted nuisances. No sample concentration,
infinite-measure statement, PAG learning or confidence interval is asserted.
-/

@[expose] public section
noncomputable section
open scoped BigOperators
namespace Paper2

/-- A probability distribution on a finite covariate population. -/
structure Law (W : Type*) [Fintype W] where
  mass : W → ℝ
  nonneg : ∀ w, 0 ≤ mass w
  total : ∑ w, mass w = 1

/-- Conditional mean of (D-phat)/(1-phat) times (DeltaY-m), given W. -/
def signal (p phat mu1 mu0 m : ℝ) : ℝ :=
  p * (mu1 - m) - (1-p) * phat / (1-phat) * (mu0-m)

/-- Exact conditional nuisance bias. -/
def bias (p phat mu0 m : ℝ) : ℝ := (m-mu0)*(phat-p)/(1-phat)

/-- Unnormalized orthogonal population risk, after conditioning on W. -/
def risk {W : Type*} [Fintype W] (mass p sig theta : W → ℝ) : ℝ :=
  ∑ w, mass w * (p w * theta w ^ 2 - 2 * theta w * sig w)

/-- Treated probability in a covariate cell. -/
def treatedMass {W : Type*} (s : Finset W) (mass p : W → ℝ) : ℝ :=
  ∑ w ∈ s, mass w * p w

/-- CATT in a cell, as the treated-weighted average of mu1-mu0.
Positive treatedMass is required whenever this conditional mean is used. -/
def catt {W : Type*} (s : Finset W) (mass p mu1 mu0 : W → ℝ) : ℝ :=
  (∑ w ∈ s, mass w * p w * (mu1 w-mu0 w)) / treatedMass s mass p

lemma signal_identity (p phat mu1 mu0 m : ℝ) (hd : 1-phat ≠ 0) :
    signal p phat mu1 mu0 m = p*(mu1-mu0) + bias p phat mu0 m := by
  unfold signal bias
  field_simp
  ring

/-- Finite conditional expectation bridge on any cell, including a fiber of
an arbitrary coarsening X(W). The last term is zero under either correct nuisance. -/
theorem finite_cell_CATT_bias {W : Type*} [Fintype W] (law : Law W)
    (s : Finset W) (p phat mu1 mu0 m : W → ℝ)
    (_hp : ∀ w, 0 ≤ p w ∧ p w ≤ 1)
    (_hr : 0 < treatedMass s law.mass p)
    (hd : ∀ w ∈ s, 1-phat w ≠ 0) :
    (∑ w ∈ s, law.mass w * signal (p w) (phat w) (mu1 w) (mu0 w) (m w)) /
        treatedMass s law.mass p =
    catt s law.mass p mu1 mu0 +
      (∑ w ∈ s, law.mass w * bias (p w) (phat w) (mu0 w) (m w)) /
        treatedMass s law.mass p := by
  have hs : (∑ w ∈ s, law.mass w * signal (p w) (phat w) (mu1 w) (mu0 w) (m w)) =
      (∑ w ∈ s, law.mass w*p w*(mu1 w-mu0 w)) +
      (∑ w ∈ s, law.mass w*bias (p w) (phat w) (mu0 w) (m w)) := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro w hw
    rw [signal_identity (p w) (phat w) (mu1 w) (mu0 w) (m w) (hd w hw)]
    ring
  rw [hs, add_div]
  rfl

lemma risk_decomposition {W : Type*} [Fintype W]
    (mass p phat mu1 mu0 m theta : W → ℝ) (hd : ∀ w, 1-phat w ≠ 0) :
    risk mass p (fun w => signal (p w) (phat w) (mu1 w) (mu0 w) (m w)) theta -
      risk mass p (fun w => signal (p w) (phat w) (mu1 w) (mu0 w) (m w))
        (fun w => mu1 w-mu0 w) =
    (∑ w, mass w*p w*(theta w-(mu1 w-mu0 w))^2) -
      2*(∑ w, mass w*(theta w-(mu1 w-mu0 w))*bias (p w) (phat w) (mu0 w) (m w)) := by
  unfold risk
  rw [← Finset.sum_sub_distrib, Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro w _
  dsimp only
  rw [signal_identity (p w) (phat w) (mu1 w) (mu0 w) (m w) (hd w)]
  ring

lemma pointwise_young (p phat mu0 m h c : ℝ)
    (hc : 0 < c) (hp : c ≤ p) (hd : c ≤ 1-phat) :
    2*h*bias p phat mu0 m ≤
      p*h^2/2 + 2/c^3*((m-mu0)^2*(phat-p)^2) := by
  have hp0 : 0 < p := lt_of_lt_of_le hc hp
  have hd0 : 0 < 1-phat := lt_of_lt_of_le hc hd
  have hy : 2*h*bias p phat mu0 m ≤ p*h^2/2 + 2*(bias p phat mu0 m)^2/p := by
    apply (mul_le_mul_iff_right₀ hp0).mp
    field_simp
    nlinarith [sq_nonneg (p*h-2*bias p phat mu0 m)]
  have hq : (bias p phat mu0 m)^2 ≤ ((m-mu0)^2*(phat-p)^2)/c^2 := by
    have hsq : c^2 ≤ (1-phat)^2 := by nlinarith
    have hz := div_le_div_of_nonneg_left
      (mul_nonneg (sq_nonneg (m-mu0)) (sq_nonneg (phat-p))) (sq_pos_of_pos hc) hsq
    simpa [bias, div_pow, mul_pow] using hz
  have hdiv : (bias p phat mu0 m)^2/p ≤
      (((m-mu0)^2*(phat-p)^2)/c^2)/c :=
    le_trans (div_le_div_of_nonneg_right hq hp0.le)
      (div_le_div_of_nonneg_left
        (div_nonneg (mul_nonneg (sq_nonneg _) (sq_nonneg _)) (sq_nonneg c)) hc hp)
  have heq : 2*((((m-mu0)^2*(phat-p)^2)/c^2)/c) =
      2/c^3*((m-mu0)^2*(phat-p)^2) := by ring
  have hdiv2 := mul_le_mul_of_nonneg_left hdiv (show (0:ℝ) ≤ 2 by norm_num)
  rw [heq] at hdiv2
  calc
    _ ≤ p*h^2/2 + 2*(bias p phat mu0 m)^2/p := hy
    _ = p*h^2/2 + 2*((bias p phat mu0 m)^2/p) := by ring
    _ ≤ _ := by linarith only [hdiv2]

lemma weighted_fourth {W : Type*} [Fintype W] (law : Law W) (a b : W → ℝ) :
    (∑ w, law.mass w * a w ^ 2 * b w ^ 2) ≤
      Real.sqrt (∑ w, law.mass w * a w ^ 4) *
        Real.sqrt (∑ w, law.mass w * b w ^ 4) := by
  have ha : 0 ≤ ∑ w, law.mass w*a w^4 :=
    Finset.sum_nonneg (fun w _ => mul_nonneg (law.nonneg w) (by positivity))
  have hb : 0 ≤ ∑ w, law.mass w*b w^4 :=
    Finset.sum_nonneg (fun w _ => mul_nonneg (law.nonneg w) (by positivity))
  have hs := Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul Finset.univ
    (r := fun w => law.mass w*a w^2*b w^2)
    (f := fun w => law.mass w*a w^4) (g := fun w => law.mass w*b w^4)
    (fun w _ => mul_nonneg (law.nonneg w) (by positivity))
    (fun w _ => mul_nonneg (law.nonneg w) (by positivity))
    (by intro w _; exact le_of_eq (by ring))
  have hp : (Real.sqrt (∑ w, law.mass w*a w^4) *
      Real.sqrt (∑ w, law.mass w*b w^4))^2 =
      (∑ w, law.mass w*a w^4)*(∑ w, law.mass w*b w^4) := by
    rw [mul_pow, Real.sq_sqrt ha, Real.sq_sqrt hb]
  have hn := mul_nonneg (Real.sqrt_nonneg (∑ w, law.mass w*a w^4))
    (Real.sqrt_nonneg (∑ w, law.mass w*b w^4))
  nlinarith

/-- Finite-W product bound. The two square roots are squared L4 errors.
The risk learning assumption is explicit; the bias and risk bridges are derived.
This is the finite specialization X=W, rather than a general measure theorem. -/
theorem finite_orthogonal_product_bound {W : Type*} [Fintype W] (law : Law W)
    (p phat mu1 mu0 m theta : W → ℝ) (c eps : ℝ)
    (hc : 0 < c) (hp : ∀ w, c ≤ p w ∧ p w ≤ 1-c)
    (hphat : ∀ w, c ≤ phat w ∧ phat w ≤ 1-c)
    (hrho : 0 < ∑ w, law.mass w*p w)
    (hlearn : (risk law.mass p (fun w => signal (p w) (phat w) (mu1 w) (mu0 w) (m w)) theta -
       risk law.mass p (fun w => signal (p w) (phat w) (mu1 w) (mu0 w) (m w))
         (fun w => mu1 w-mu0 w)) / (∑ w, law.mass w*p w) ≤ eps) :
    (∑ w, law.mass w*p w*(theta w-(mu1 w-mu0 w))^2) / (∑ w, law.mass w*p w) ≤
      2*eps + 4/((∑ w, law.mass w*p w)*c^3) *
        (Real.sqrt (∑ w, law.mass w*(m w-mu0 w)^4) *
         Real.sqrt (∑ w, law.mass w*(phat w-p w)^4)) := by
  have hd : ∀ w, 1-phat w ≠ 0 := by
    intro w
    have h := (hphat w).2
    linarith
  rw [risk_decomposition law.mass p phat mu1 mu0 m theta hd] at hlearn
  have hlearning := (div_le_iff₀ hrho).mp hlearn
  have hy := Finset.sum_le_sum (s := (Finset.univ : Finset W))
    (fun w _ => mul_le_mul_of_nonneg_left
      (pointwise_young (p w) (phat w) (mu0 w) (m w)
        (theta w-(mu1 w-mu0 w)) c hc (hp w).1 (by have h := (hphat w).2; linarith))
      (law.nonneg w))
  simp_rw [mul_add] at hy
  rw [Finset.sum_add_distrib] at hy
  have he : (∑ w, law.mass w * (p w*(theta w-(mu1 w-mu0 w))^2/2)) =
      (∑ w, law.mass w*p w*(theta w-(mu1 w-mu0 w))^2)/2 := by
    simp_rw [div_eq_mul_inv, mul_assoc]
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro w _
    ring
  have hl : (∑ w, law.mass w*(2*(theta w-(mu1 w-mu0 w))*bias (p w) (phat w) (mu0 w) (m w))) =
      2*(∑ w, law.mass w*(theta w-(mu1 w-mu0 w))*bias (p w) (phat w) (mu0 w) (m w)) := by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro w _; ring
  have hm : (∑ w, law.mass w*(2/c^3*((m w-mu0 w)^2*(phat w-p w)^2))) =
      2/c^3*(∑ w, law.mass w*(m w-mu0 w)^2*(phat w-p w)^2) := by
    rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro w _; ring
  rw [he, hl, hm] at hy
  have hfourth := weighted_fourth law (fun w => m w-mu0 w) (fun w => phat w-p w)
  have hscaled := mul_le_mul_of_nonneg_left hfourth (show 0 ≤ 4/c^3 by positivity)
  apply (div_le_iff₀ hrho).mpr
  have hr : (2*eps + 4/((∑ w, law.mass w*p w)*c^3) *
      (Real.sqrt (∑ w, law.mass w*(m w-mu0 w)^4) *
       Real.sqrt (∑ w, law.mass w*(phat w-p w)^4))) * (∑ w, law.mass w*p w) =
      2*eps*(∑ w, law.mass w*p w) + 4/c^3 *
      (Real.sqrt (∑ w, law.mass w*(m w-mu0 w)^4) *
       Real.sqrt (∑ w, law.mass w*(phat w-p w)^4)) := by
    field_simp
  rw [hr]
  ring_nf at hlearning hy hscaled ⊢
  linarith only [hlearning, hy, hscaled]

end Paper2
end
