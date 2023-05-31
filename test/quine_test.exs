defmodule QuineTest do
  use ExUnit.Case

  doctest Quine

  @tautologies [
    "Av~A",
    "A->A",
    "A<->A",
    "(A->B)<->(Bv~A)",
    "(PvQ)v(~P^~Q)"
  ]

  @contradictions [
    "A^~A",
    "A<->~A",
    "(PvQ)^(~P^~Q)"
  ]

  @contingencies [
    "AvB",
    "A^B",
    "A->B",
    "A<->B"
  ]

  describe "evaluate/2" do
    test "returns the truth-value of an expression given truth values of its sentences" do
      assert Quine.evaluate("A", %{"A" => true}) == true
      assert Quine.evaluate("A", %{"A" => false}) == false

      assert Quine.evaluate("~A", %{"A" => true}) == false
      assert Quine.evaluate("~A", %{"A" => false}) == true

      assert Quine.evaluate("AvB", %{"A" => true, "B" => true}) == true
      assert Quine.evaluate("AvB", %{"A" => true, "B" => false}) == true
      assert Quine.evaluate("AvB", %{"A" => false, "B" => true}) == true
      assert Quine.evaluate("AvB", %{"A" => false, "B" => false}) == false

      assert Quine.evaluate("A^B", %{"A" => true, "B" => true}) == true
      assert Quine.evaluate("A^B", %{"A" => true, "B" => false}) == false
      assert Quine.evaluate("A^B", %{"A" => false, "B" => true}) == false
      assert Quine.evaluate("A^B", %{"A" => false, "B" => false}) == false

      assert Quine.evaluate("A->B", %{"A" => true, "B" => true}) == true
      assert Quine.evaluate("A->B", %{"A" => true, "B" => false}) == false
      assert Quine.evaluate("A->B", %{"A" => false, "B" => true}) == true
      assert Quine.evaluate("A->B", %{"A" => false, "B" => false}) == true

      assert Quine.evaluate("A<->B", %{"A" => true, "B" => true}) == true
      assert Quine.evaluate("A<->B", %{"A" => true, "B" => false}) == false
      assert Quine.evaluate("A<->B", %{"A" => false, "B" => true}) == false
      assert Quine.evaluate("A<->B", %{"A" => false, "B" => false}) == true

      assert Quine.evaluate("~(~(~(A)))", %{"A" => true}) == false

      assert Quine.evaluate("~(A<->(Bv(C^D)))", %{
               "A" => true,
               "B" => true,
               "C" => true,
               "D" => true
             }) == false
    end

    test "errors for missing truth values" do
      assert_raise ArgumentError, "missing truth value for sentence 'B'", fn ->
        Quine.evaluate("A<->B", %{"A" => true})
      end
    end

    test "errors for non-boolean truth values" do
      assert_raise ArgumentError, "received non-boolean truth value for sentence 'A'", fn ->
        Quine.evaluate("A<->B", %{"A" => 1, "B" => 2})
      end
    end
  end

  describe "tautology?/1" do
    test "returns true if an expression is always true" do
      Enum.each(@tautologies, &assert(Quine.tautology?(&1)))
    end

    test "returns false for expressions that are only sometimes true" do
      Enum.each(@contingencies, &refute(Quine.tautology?(&1)))
    end

    test "returns false for contradictions" do
      Enum.each(@contradictions, &refute(Quine.tautology?(&1)))
    end
  end

  describe "contradiction?/1" do
    test "returns true for expressions that are never true" do
      Enum.each(@contradictions, &assert(Quine.contradiction?(&1)))
    end

    test "returns false for satisfiable expresions" do
      Enum.each(@contingencies, &refute(Quine.contradiction?(&1)))
    end

    test "returns false for tautologies" do
      Enum.each(@tautologies, &refute(Quine.contradiction?(&1)))
    end
  end

  describe "satisfiable?/1" do
    test "returns true for expressions that are always true" do
      Enum.each(@tautologies, &assert(Quine.satisfiable?(&1)))
    end

    test "returns true for expressions that are sometimes true" do
      Enum.each(@contingencies, &assert(Quine.satisfiable?(&1)))
    end

    test "returns false for expressions that are never true" do
      Enum.each(@contradictions, &refute(Quine.satisfiable?(&1)))
    end
  end

  describe "contingent?/1" do
    test "returns true for expressions that are only sometimes true" do
      Enum.each(@contingencies, &assert(Quine.contingent?(&1)))
    end

    test "returns false for expressions that are always true" do
      Enum.each(@tautologies, &refute(Quine.contingent?(&1)))
    end

    test "returns false for expressions that are never true" do
      Enum.each(@contradictions, &refute(Quine.contingent?(&1)))
    end
  end

  describe "equivalent?/2" do
    test "returns true if the given expressions have the same truth values" do
      assert Quine.equivalent?("A->B", "~B->~A")
      assert Quine.equivalent?("P->Q", "Qv~P")
      assert Quine.equivalent?("~(~A)", "A")
      assert Quine.equivalent?("AvB", "BvA")
      assert Quine.equivalent?("A^B", "B^A")

      # DeMorgan’s Laws
      assert Quine.equivalent?("~(PvQ)", "~P^~Q")
      assert Quine.equivalent?("~(P^Q)", "~Pv~Q")
    end

    test "returns false if the given expressions do not have the same truth values" do
      refute Quine.equivalent?("A->B", "AvB")
    end
  end

  describe "prove/2" do
    test "proves simple conjunctions" do
      assert Quine.prove(["A", "B"], "A^B") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"B", :premise},
                  3 => {"A^B", {:conjunction_introduction, [1, 2]}}
                }}

      assert Quine.prove(["A", "BvC"], "A^(BvC)") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"BvC", :premise},
                  3 => {"A^(BvC)", {:conjunction_introduction, [1, 2]}}
                }}
    end

    test "proves conjunctions with multiple steps" do
      assert Quine.prove(["A", "B", "C"], "(A^B)^C") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"B", :premise},
                  3 => {"C", :premise},
                  4 => {"A^B", {:conjunction_introduction, [1, 2]}},
                  5 => {"(A^B)^C", {:conjunction_introduction, [3, 4]}}
                }}
    end

    test "proves simple disjunctions" do
      assert Quine.prove(["A"], "AvB") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"AvB", {:disjunction_introduction, [1]}}
                }}

      assert Quine.prove(["~(A^B)"], "(~(A^B))v(C^D)") ==
               {:ok,
                %{
                  1 => {"~(A^B)", :premise},
                  2 => {"(~(A^B))v(C^D)", {:disjunction_introduction, [1]}}
                }}
    end

    test "proves disjunctions with multiple steps" do
      assert Quine.prove(["A"], "(AvB)vC") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"AvB", {:disjunction_introduction, [1]}},
                  3 => {"(AvB)vC", {:disjunction_introduction, [2]}}
                }}
    end

    test "proves sentences by implication elimination" do
      assert Quine.prove(["A", "A->B"], "B") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A->B", :premise},
                  3 => {"B", {:implication_elimination, [1, 2]}}
                }}

      assert Quine.prove(["~(A^B)", "~(A^B)->C"], "C") ==
               {:ok,
                %{
                  1 => {"~(A^B)", :premise},
                  2 => {"(~(A^B))->C", :premise},
                  3 => {"C", {:implication_elimination, [1, 2]}}
                }}
    end

    test "proves other statements by implication elimination" do
      assert Quine.prove(["A", "A->(BvC)"], "BvC") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A->(BvC)", :premise},
                  3 => {"BvC", {:implication_elimination, [1, 2]}}
                }}

      assert Quine.prove(["(BvC)", "(BvC)->A"], "A") ==
               {:ok,
                %{
                  1 => {"BvC", :premise},
                  2 => {"(BvC)->A", :premise},
                  3 => {"A", {:implication_elimination, [1, 2]}}
                }}
    end

    test "proves by implication elimination with other steps" do
      assert Quine.prove(["A", "B", "(A^B)->C"], "C") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"B", :premise},
                  3 => {"(A^B)->C", :premise},
                  4 => {"A^B", {:conjunction_introduction, [1, 2]}},
                  5 => {"C", {:implication_elimination, [3, 4]}}
                }}
    end

    test "proves by nested implication elimination" do
      assert Quine.prove(["A", "B", "C", "A->(B->(C->D))"], "D") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"B", :premise},
                  3 => {"C", :premise},
                  4 => {"A->(B->(C->D))", :premise},
                  5 => {"B->(C->D)", {:implication_elimination, [1, 4]}},
                  6 => {"C->D", {:implication_elimination, [2, 5]}},
                  7 => {"D", {:implication_elimination, [3, 6]}}
                }}
    end

    test "proves sentences by biconditional elimination" do
      assert Quine.prove(["A", "A<->B"], "B") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A<->B", :premise},
                  3 => {"B", {:biconditional_elimination, [1, 2]}}
                }}

      assert Quine.prove(["B", "A<->B"], "A") ==
               {:ok,
                %{
                  1 => {"B", :premise},
                  2 => {"A<->B", :premise},
                  3 => {"A", {:biconditional_elimination, [1, 2]}}
                }}
    end

    test "proves other statements by biconditional elimination" do
      assert Quine.prove(["~(B^C)", "(A<->D)<->~(B^C)"], "A<->D") ==
               {:ok,
                %{
                  1 => {"~(B^C)", :premise},
                  2 => {"(A<->D)<->(~(B^C))", :premise},
                  3 => {"A<->D", {:biconditional_elimination, [1, 2]}}
                }}
    end

    test "proves by biconditional elimination with other steps" do
      assert Quine.prove(["A", "A->B", "B<->C"], "C") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A->B", :premise},
                  3 => {"B<->C", :premise},
                  4 => {"B", {:implication_elimination, [1, 2]}},
                  5 => {"C", {:biconditional_elimination, [3, 4]}}
                }}
    end

    test "proves biconditionals inside other expressions" do
      assert Quine.prove(["A", "A->(B<->C)", "B"], "C") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A->(B<->C)", :premise},
                  3 => {"B", :premise},
                  4 => {"B<->C", {:implication_elimination, [1, 2]}},
                  5 => {"C", {:biconditional_elimination, [3, 4]}}
                }}
    end

    test "proves nested biconditionals" do
      assert Quine.prove(["A", "B", "C", "A<->(B<->(C<->D))"], "D") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"B", :premise},
                  3 => {"C", :premise},
                  4 => {"A<->(B<->(C<->D))", :premise},
                  5 => {"B<->(C<->D)", {:biconditional_elimination, [1, 4]}},
                  6 => {"C<->D", {:biconditional_elimination, [2, 5]}},
                  7 => {"D", {:biconditional_elimination, [3, 6]}}
                }}
    end

    # test nested biconditional?
    # find_biconditional_including/1 only looks 1 level deep

    test "proves by biconditional introduction" do
      assert Quine.prove(["A->B", "B->A"], "A<->B") ==
               {:ok,
                %{
                  1 => {"A->B", :premise},
                  2 => {"B->A", :premise},
                  3 => {"A<->B", {:biconditional_introduction, [1, 2]}}
                }}
    end

    test "proves by conjunction elimination" do
      assert Quine.prove(["A^B"], "A") ==
               {:ok,
                %{
                  1 => {"A^B", :premise},
                  2 => {"A", {:conjunction_elimination, [1]}}
                }}

      assert Quine.prove(["A^B"], "B") ==
               {:ok,
                %{
                  1 => {"A^B", :premise},
                  2 => {"B", {:conjunction_elimination, [1]}}
                }}
    end

    test "proves by conjunction elimination with other steps" do
      assert Quine.prove(["A", "A->(B^C)"], "C") ==
               {:ok,
                %{
                  1 => {"A", :premise},
                  2 => {"A->(B^C)", :premise},
                  3 => {"B^C", {:implication_elimination, [1, 2]}},
                  4 => {"C", {:conjunction_elimination, [3]}}
                }}
    end

    test "proves sentences by disjunction elimination" do
      assert Quine.prove(["AvB", "A->C", "B->C", "D->C"], "C") ==
               {:ok,
                %{
                  1 => {"AvB", :premise},
                  2 => {"A->C", :premise},
                  3 => {"B->C", :premise},
                  4 => {"D->C", :premise},
                  5 => {"C", {:disjunction_elimination, [1, 2, 3]}}
                }}
    end

    test "proves other statements by disjunction elimination" do
      assert Quine.prove(["AvB", "A->(~(C<->E))", "B->(~(C<->E))", "D->(~(C<->E))"], "~(C<->E)") ==
               {:ok,
                %{
                  1 => {"AvB", :premise},
                  2 => {"A->(~(C<->E))", :premise},
                  3 => {"B->(~(C<->E))", :premise},
                  4 => {"D->(~(C<->E))", :premise},
                  5 => {"~(C<->E)", {:disjunction_elimination, [1, 2, 3]}}
                }}
    end
  end
end
