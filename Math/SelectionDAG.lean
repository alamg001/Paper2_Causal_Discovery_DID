module

public import Math.Theorem

@[expose] public section

namespace ConjeturaLeanXYZ

/-- A DAG with a supplied natural-number topological ranking. -/
structure RankedDAG (V : Type) where
  arrow : V → V → Prop
  rank : V → ℕ
  increasing : ∀ a b, arrow a b → rank a < rank b

def RankedDAG.toMixed {V : Type} (G : RankedDAG V) : MixedGraph V where
  adj a b := G.arrow a b ∨ G.arrow b a
  collider a b c := G.arrow a b ∧ G.arrow c b
  ancestor a b := Relation.ReflTransGen G.arrow a b

def selectedDSeparated {V : Type} (G : RankedDAG V) (d q : V)
    (W S : Set V) : Prop := MSeparated G.toMixed d q (W ∪ S)

/-- General certificate: paths can differ across models. Selection is explicit.
Nonemptiness is part of the conclusion and the supplied class is never learned. -/
theorem supplied_DAG_class_no_adjustment {V : Type} (d q : V)
    (classOf : Set (RankedDAG V)) (admissible : Set (Set V)) (S : Set V)
    (hne : classOf.Nonempty) (ha : admissible.Nonempty)
    (_endpoints : ∀ W ∈ admissible, d ∉ W ∪ S ∧ q ∉ W ∪ S)
    (cert : ∀ G ∈ classOf, ∀ W ∈ admissible,
      ∃ path, ConnectingPath G.toMixed d q (W ∪ S) path) :
    classOf.Nonempty ∧ admissible.Nonempty ∧
      ¬ ∃ G ∈ classOf, ∃ W ∈ admissible, selectedDSeparated G d q W S := by
  refine ⟨hne, ha, ?_⟩
  rintro ⟨G,hG,W,hW,hs⟩
  exact hs (cert G hG W hW)

def selectionCollider : RankedDAG (Fin 3) where
  arrow a b := (a = 0 ∨ a = 1) ∧ b = 2
  rank a := a.val
  increasing := by
    intro a b h
    rcases h with ⟨h,rfl⟩
    rcases h with rfl | rfl <;> decide

/-- D -> S <- Q becomes connecting when S is selected. -/
theorem selection_collider_active :
    ConnectingPath selectionCollider.toMixed 0 1 ({2} : Set (Fin 3)) [0,2,1] := by
  simp [ConnectingPath, RankedDAG.toMixed, selectionCollider, AdjacentWalk,
    InteriorActive, Relation.ReflTransGen.refl]

end ConjeturaLeanXYZ
