module

public import Math.Lemmas

@[expose] public section

namespace ConjeturaLeanXYZ

-- This is the scalar REDUCTION of T2, not a formalization of conditional
-- expectation, Holder, or the probability of the learning event.
theorem product_bound_from_reduction (q b eps prod rho c : ℝ)
    (hbasic : q ^ 2 ≤ eps + 2 * q * b)
    (hbias : b ^ 2 ≤ prod / (rho * c ^ 3)) :
    q ^ 2 ≤ 2 * eps + 4 / (rho * c ^ 3) * prod := by
  have h := excess_risk_transport q b eps hbasic
  have hb := mul_le_mul_of_nonneg_left hbias (by norm_num : (0 : ℝ) ≤ 4)
  have heq : 4 * (prod / (rho * c ^ 3)) = 4 / (rho * c ^ 3) * prod := by ring
  rw [heq] at hb
  linarith

-- Finite paths are explicit; class membership, DAG d-separation, and the
-- projection preservation property are explicit inputs, not ad hoc axioms.
theorem path_certificates_imply_uniform_connection
    {V : Type} (d q : V) (classOf : Set (MixedGraph V))
    (admissible : Set (Set V))
    (cert : ∀ W ∈ admissible, ∃ path : List V,
      ∀ M ∈ classOf, ConnectingPath M d q W path) :
    ∀ M ∈ classOf, ∀ W ∈ admissible, MConnected M d q W := by
  intro M hM W hW
  obtain ⟨path, hp⟩ := cert W hW
  exact ⟨path, hp M hM⟩

theorem pag_cpt_no_graphical_adjustment
    {V H : Type} (d q : V) (classOf : Set (MixedGraph V))
    (admissible : Set (Set V)) (compatible : Set H)
    (projection : H → MixedGraph V)
    (dSeparated : H → Set V → Prop)
    (membership : ∀ h ∈ compatible, projection h ∈ classOf)
    (preservation : ∀ h ∈ compatible, ∀ W ∈ admissible,
      dSeparated h W → MSeparated (projection h) d q W)
    (certificate : ∀ W ∈ admissible, ∃ path : List V,
      ∀ M ∈ classOf, ConnectingPath M d q W path) :
    ¬ ∃ h ∈ compatible, ∃ W ∈ admissible, dSeparated h W := by
  intro hex
  obtain ⟨h, hh, W, hW, hs⟩ := hex
  have hc := path_certificates_imply_uniform_connection d q classOf
    admissible certificate (projection h) (membership h hh) W hW
  exact (preservation h hh W hW hs) hc

end ConjeturaLeanXYZ
