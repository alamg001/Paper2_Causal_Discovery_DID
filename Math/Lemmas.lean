module

public import Math.Definitions
public import Mathlib.Tactic.FieldSimp
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.NormNum

@[expose] public section

namespace ConjeturaLeanXYZ

theorem scalar_squared_loss_self_bounding (r : ℝ) : (2 * r) ^ 2 = 4 * r ^ 2 := by
  ring

theorem control_weight_difference (p phat : ℝ)
    (hp : 1 - p ≠ 0) (hh : 1 - phat ≠ 0) :
    controlWeight phat - controlWeight p =
      (p - phat) / ((1 - phat) * (1 - p)) := by
  unfold controlWeight
  field_simp
  <;> ring

theorem conditional_signal_bias_identity (p phat mu1 mu0 m : ℝ)
    (hh : 1 - phat ≠ 0) :
    signalMean p phat mu1 mu0 m =
      p * (mu1 - mu0) + nuisanceProduct p phat mu0 m := by
  unfold signalMean nuisanceProduct
  field_simp
  <;> ring

theorem signal_double_robust_m (p phat mu1 mu0 : ℝ)
    (hh : 1 - phat ≠ 0) :
    signalMean p phat mu1 mu0 mu0 = p * (mu1 - mu0) := by
  rw [conditional_signal_bias_identity p phat mu1 mu0 mu0 hh]
  simp [nuisanceProduct]

theorem signal_double_robust_p (p mu1 mu0 m : ℝ)
    (hp : 1 - p ≠ 0) :
    signalMean p p mu1 mu0 m = p * (mu1 - mu0) := by
  rw [conditional_signal_bias_identity p p mu1 mu0 m hp]
  simp [nuisanceProduct]

theorem old_signal_counterexample :
    (1 : ℝ) + signalMean (1 / 2) (1 / 2) 2 1 1 ≠ 1 := by
  norm_num [signalMean]

-- Norm q, bias norm b, and excess epsilon are scalars. The statistical
-- derivation of hbasic is not claimed to be formalized by this lemma.
theorem excess_risk_transport (q b eps : ℝ)
    (hbasic : q ^ 2 ≤ eps + 2 * q * b) :
    q ^ 2 ≤ 2 * eps + 4 * b ^ 2 := by
  nlinarith [sq_nonneg (q - 2 * b)]

theorem cohort_normalization (rho x y : ℝ) (hr : rho ≠ 0)
    (h : x = rho * y) : y = x / rho := by
  rw [h]
  field_simp

theorem squared_normalized_quantity (x rho : ℝ) :
    (x / rho) ^ 2 = x ^ 2 / rho ^ 2 := by
  rw [div_pow]

theorem convex_two_cohort_pointwise (w u v : ℝ)
    (hw0 : 0 ≤ w) (hw1 : w ≤ 1) :
    (w * u + (1 - w) * v) ^ 2 ≤ w * u ^ 2 + (1 - w) * v ^ 2 := by
  have h : 0 ≤ w * (1 - w) * (u - v) ^ 2 :=
    mul_nonneg (mul_nonneg hw0 (sub_nonneg.mpr hw1)) (sq_nonneg (u - v))
  nlinarith

end ConjeturaLeanXYZ
