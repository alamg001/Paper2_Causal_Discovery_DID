module

public import Mathlib.Basic.Real.Basic
public import Mathlib.Data.Set.Basic

@[expose] public section

namespace ConjeturaLeanXYZ

noncomputable section

def controlWeight (p : ℝ) : ℝ := -p / (1 - p)

-- Algebraic conditional mean, after conditioning on W.
def signalMean (p phat mu1 mu0 m : ℝ) : ℝ :=
  p * (mu1 - m) - (1 - p) * phat / (1 - phat) * (mu0 - m)

def nuisanceProduct (p phat m0 m : ℝ) : ℝ :=
  (m - m0) * (phat - p) / (1 - phat)

-- Relations supplied by a graph model. Acyclicity, ancestral constraints,
-- and correctness of these relations are deliberately NOT hidden here.
structure MixedGraph (V : Type) where
  adj : V → V → Prop
  collider : V → V → V → Prop
  ancestor : V → V → Prop

def AdjacentWalk {V : Type} (M : MixedGraph V) : List V → Prop
  | a :: b :: rest => M.adj a b ∧ AdjacentWalk M (b :: rest)
  | _ => True

def InteriorActive {V : Type} (M : MixedGraph V) (W : Set V) : List V → Prop
  | a :: b :: c :: rest =>
      ((M.collider a b c → ∃ w, w ∈ W ∧ M.ancestor b w) ∧
       (¬ M.collider a b c → b ∉ W)) ∧ InteriorActive M W (b :: c :: rest)
  | _ => True

def ConnectingPath {V : Type} (M : MixedGraph V)
    (d q : V) (W : Set V) (path : List V) : Prop :=
  path.head? = some d ∧ path.getLast? = some q ∧
  2 ≤ path.length ∧ path.Nodup ∧ AdjacentWalk M path ∧ InteriorActive M W path

def MConnected {V : Type} (M : MixedGraph V) (d q : V) (W : Set V) : Prop :=
  ∃ path, ConnectingPath M d q W path

def MSeparated {V : Type} (M : MixedGraph V) (d q : V) (W : Set V) : Prop :=
  ¬ MConnected M d q W

end
end ConjeturaLeanXYZ
