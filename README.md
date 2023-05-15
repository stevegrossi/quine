# Quine

Tools for parsing and working with propositional logic.

## Examples

### Evaluating propositions with given truth values

```elixir
Quine.evaluate("A^B", %{"A" => true, "B" => true})
#=> true

Quine.evaluate("A^B", %{"A" => true, "B" => false})
#=> false
```

### Detecting tautologies and contraditions

```elixir
Quine.tautology?("(A->B)<->(Bv~A)")
#=> true

Quine.tautology?("A->B")
#=> false

Quine.contradtion?("A^~A")
#=> true

Quine.contradtion?("A->B")
#=> false
```

### Detecting Logical Equivalence

```elixir
Quine.equivalent?("A->B", "~B->~A")
#=> true

Quine.equivalent?("A->B", "AvB")
#=> false
```

## Eventually...

- Derive proofs of conclusions from a set of assumptions, e.g. `Quine.prove(["A", "A->B"], "B")`
- take efficiency into account and return the most efficient proof
- derive logical truths (i.e. `A->A`, `B v ~B`) from 0 assumptions

## Addenda
### The 12 Rules of Logical Inference

#### Assumption

You can assume anything, but assumptions introduce a new scope. Nothing proven within an assumptions' scope can be used outside that scope. But, proving that something follows from an assuption lets you do things like the next rule:

#### -> Introduction

If you assume "X" and then prove "Y", you can now use "X -> Y" outside of the assumption's scope.

#### ^ Elimination

If you have "X ^ Y", then you're entitled to both "X" and "Y".

#### Repetition

If you have "X", then you're entitled to "X".

#### ^ Introduction

If you have "X" and you have "Y", you're entitled to "X ^ Y"

#### -> Elimination

If you have "X" and you have "X -> Y", then you're entitled to "Y".

#### <-> Introduction

If you have "X -> Y" and also "Y -> X", then you're entitled to "X <-> Y".

#### <-> Elimination

If you have "X <-> Y" and you have "X", then you're entitled to "Y", and if you have "Y" then you're entitled to "X".

#### ~ Introduction

This rule requires you to prove something within the scope of an assumption. If you assume "X" and you can prove both "Y" and "~Y", then you're entitled to "~X" outside the scope of that assumption.

#### ~ Elimination

Likewise, if you assume "~X" and you can prove both "Y" and "~Y", then you're entitled to "X" outside the scope of that assumption.

#### v Introduction

If you have "X", then you're entitled to "X v Y".

#### v Elimination

If you have "X v Y", "X -> Z", and "Y -> Z", then you're entitled to Z.
