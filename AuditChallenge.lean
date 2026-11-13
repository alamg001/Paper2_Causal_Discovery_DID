module

public import Challenge

/-!
# Independent audit of the proof-complete challenge module

This file imports `Challenge` without importing `Solution`. It verifies that
the two selected declarations are available from the challenge module and
prints their axioms for the validation logs.
-/

#check Paper2.finite_cell_CATT_bias
#check Paper2.finite_orthogonal_product_bound
#print axioms Paper2.signal_identity
#print axioms Paper2.finite_cell_CATT_bias
#print axioms Paper2.risk_decomposition
#print axioms Paper2.pointwise_young
#print axioms Paper2.weighted_fourth
#print axioms Paper2.finite_orthogonal_product_bound

def main : IO Unit := IO.println "Paper2 Challenge: complete proofs audited."
