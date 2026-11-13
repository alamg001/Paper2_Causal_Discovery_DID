module

public import Math.Theorem
public import Mathlib.Algebra.BigOperators.Ring.Finset

@[expose] public section

namespace ConjeturaLeanXYZ
open scoped BigOperators

noncomputable section

/-- A genuine probability law on a finite covariate space. -/
structure FiniteLaw (W : Type*) [Fintype W] where
  mass : W → ℝ
  nonneg : ∀ w, 0 ≤ mass w
  total : ∑ w, mass w = 1

/-- Exact unnormalized conditional expectation on any finite covariate cell. -/
theorem finite_cell_signal_bias {W : Type*} (s : Finset W)
    (mass p phat mu1 mu0 m : W → ℝ)
    (hden : ∀ w ∈ s, 1 - phat w ≠ 0) :
    (∑ w ∈ s, mass w * signalMean (p w) (phat w) (mu1 w) (mu0 w) (m w)) =
      (∑ w ∈ s, mass w * p w * (mu1 w - mu0 w)) +
      (∑ w ∈ s, mass w * nuisanceProduct (p w) (phat w) (mu0 w) (m w)) := by
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro w hw
  rw [conditional_signal_bias_identity (p w) (phat w) (mu1 w) (mu0 w) (m w) (hden w hw)]
  ring

def cellTreatedMass {W : Type*} (s : Finset W) (mass p : W → ℝ) : ℝ :=
  ∑ w ∈ s, mass w * p w

def cellCATT {W : Type*} (s : Finset W) (mass p mu1 mu0 : W → ℝ) : ℝ :=
  (∑ w ∈ s, mass w * p w * (mu1 w - mu0 w)) / cellTreatedMass s mass p

/-- Conditional CATT and bias over a cell, obtained by summation, not assumed.
The positive mass condition rules out empty treated conditional populations. -/
theorem finite_conditional_CATT_bias {W : Type*} [Fintype W]
    (law : FiniteLaw W) (s : Finset W) (p phat mu1 mu0 m : W → ℝ)
    (_hprob : ∀ w, 0 ≤ p w ∧ p w ≤ 1)
    (hden : ∀ w ∈ s, 1 - phat w ≠ 0)
    (_hpositive : 0 < cellTreatedMass s law.mass p) :
    (∑ w ∈ s, law.mass w * signalMean (p w) (phat w) (mu1 w) (mu0 w) (m w)) /
      cellTreatedMass s law.mass p =
    cellCATT s law.mass p mu1 mu0 +
      (∑ w ∈ s, law.mass w * nuisanceProduct (p w) (phat w) (mu0 w) (m w)) /
        cellTreatedMass s law.mass p := by
  rw [finite_cell_signal_bias s law.mass p phat mu1 mu0 m hden, add_div]
  rfl

def finiteRiskNumerator {W : Type*} (s : Finset W)
    (mass p signal theta : W → ℝ) : ℝ :=
  ∑ w ∈ s, mass w * (p w * theta w ^ 2 - 2 * theta w * signal w)

/-- The finite expectation/risk bridge, valid for any candidate theta. -/
theorem finite_risk_decomposition {W : Type*} (s : Finset W)
    (mass p signal tau theta bias : W → ℝ)
    (hsignal : ∀ w ∈ s, signal w = p w * tau w + bias w) :
    finiteRiskNumerator s mass p signal theta - finiteRiskNumerator s mass p signal tau =
      (∑ w ∈ s, mass w * p w * (theta w - tau w) ^ 2) -
        2 * (∑ w ∈ s, mass w * (theta w - tau w) * bias w) := by
  unfold finiteRiskNumerator
  rw [← Finset.sum_sub_distrib, Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro w hw
  rw [hsignal w hw]
  ring

/-- Full finite-W true excess identity; neither hbasic nor hbias is an input. -/
theorem finite_true_excess {W : Type*} [Fintype W]
    (law : FiniteLaw W) (p mu1 mu0 theta : W → ℝ)
    (_hprob : ∀ w, 0 ≤ p w ∧ p w ≤ 1)
    (hden : ∀ w, 1 - p w ≠ 0)
    (_hrho : 0 < cellTreatedMass Finset.univ law.mass p) :
    (finiteRiskNumerator Finset.univ law.mass p
      (fun w => signalMean (p w) (p w) (mu1 w) (mu0 w) (mu0 w)) theta -
     finiteRiskNumerator Finset.univ law.mass p
      (fun w => signalMean (p w) (p w) (mu1 w) (mu0 w) (mu0 w))
      (fun w => mu1 w - mu0 w)) / cellTreatedMass Finset.univ law.mass p =
    (∑ w, law.mass w * p w * (theta w - (mu1 w - mu0 w)) ^ 2) /
      cellTreatedMass Finset.univ law.mass p := by
  have h := finite_risk_decomposition Finset.univ law.mass p
    (fun w => signalMean (p w) (p w) (mu1 w) (mu0 w) (mu0 w))
    (fun w => mu1 w - mu0 w) theta (fun _ => 0)
    (by intro w _; simpa using signal_double_robust_m (p w) (p w) (mu1 w) (mu0 w) (hden w))
  simpa using congrArg (fun a => a / cellTreatedMass Finset.univ law.mass p) h

/-- Scalar last step of the explicit linear second-stage concentration theorem.
Matrix concentration and the high-probability event remain in the manuscript. -/
theorem linear_stage_error_from_concentration (q B u : ℝ)
    (hq : 0 ≤ q) (h : q ^ 2 / 2 ≤ q * (B + u)) :
    q ^ 2 ≤ 8 * B ^ 2 + 8 * u ^ 2 := by
  by_cases hz : q = 0
  · rw [hz]
    nlinarith [sq_nonneg B, sq_nonneg u]
  have hp : 0 < q := lt_of_le_of_ne hq (Ne.symm hz)
  have ha : q ≤ 2 * (B + u) := by
    by_contra hn
    have ht : 0 < q * (q / 2 - (B + u)) := mul_pos hp (by linarith)
    nlinarith
  have hb : 0 ≤ B + u := by linarith
  have hc := mul_nonneg (sub_nonneg.mpr ha)
    (show 0 ≤ 2 * (B + u) + q by linarith)
  nlinarith [sq_nonneg (B - u)]

end
end ConjeturaLeanXYZ
