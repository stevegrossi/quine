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

- derive logical truths (i.e. `A->A`, `B v ~B`) from 0 assumptions

## Addenda
### The 12 Rules of Logical Inference

#### Assumption

You can assume anything, but assumptions introduce a new scope. Nothing proven within an assumptions' scope can be used outside that scope. But, proving that something follows from an assuption lets you apply some of the rules below.

#### Repetition

If you have "X", then you're entitled to "X". Perhaps useful to repeating assumptions when proving lemmas.

#### Implication Introduction

If you assume "X" and then prove "Y", you can now use "X -> Y" outside of the assumption's scope.

#### Implication Elimination

If you have "X" and you have "X -> Y", then you're entitled to "Y".

#### Disjunction Introduction

If you have "X", then you're entitled to "X v Y".

#### Disjunction Elimination

If you have "X v Y", "X -> Z", and "Y -> Z", then you're entitled to Z.

#### Conjunction Introduction

If you have "X" and you have "Y", you're entitled to "X ^ Y"

#### Conjunction Elimination

If you have "X ^ Y", then you're entitled to both "X" and "Y".

#### Biconditional Introduction

If you have "X -> Y" and also "Y -> X", then you're entitled to "X <-> Y".

#### Biconditional Elimination

If you have "X <-> Y" and you have "X", then you're entitled to "Y", and if you have "Y" then you're entitled to "X".

#### Negation Introduction

This rule requires you to prove something within the scope of an assumption. If you assume "X" and you can prove both "Y" and "~Y", then you're entitled to "~X" outside the scope of that assumption.

#### Negation Elimination

Likewise, if you assume "~X" and you can prove both "Y" and "~Y", then you're entitled to "X" outside the scope of that assumption.

### Strategies for Proving Kinds of Statements

- **any**: Negation Elimination, Implication Elimination, Disjunction Elimination, Conjunction Elimination, Biconditional Elimination
- **negation**: Negation Introduction, any
- **disjunction**: Disjunction Introduction, any
- **conjunction**: Conjunction Introduction, any
- **implication**: Implication Introduction, any
- **biconditional**: Biconditional Introduction, any

### TODO
- [ ] Enhance the remaining proof-by-elimination strategies to prove their own requirements
- [ ] Implement the proof-by-assumption strategies: implication introduction, negation introduction, and negation elimination
- [ ] Could things be simpler if sentences were tagged? e.g. `{:sentence, "A"}` instead of bare strings

### References

- [Mathematical Logic Through Python](https://www.logicthrupython.org/)
- https://people.cs.pitt.edu/~milos/courses/cs441/lectures/Class2.pdf
- [An online theorem prover](http://teachinglogic.liglab.fr/DN/index.php?formula=p+%26+%28q+%2B+r%29+%3C%3D%3E+%28p+%26+q%29+%2B+%28p+%26+r%29&action=Prove+Formula), the closest (and only) example I've been able to find of software that does what Quine sets out to do
