# Gomory cutting-plane example

`gomory` is a TI-Nspire CAS teaching program that prints the tableau steps for a small integer linear program. It displays the initial basis, the linear relaxation, fractional basic-variable cuts and the dual-simplex pivots after each cut.

## Build and run

From the repository root, run `./scripts/build.sh gomory`. Copy `build/gomory.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. [Library installation](../README.md)

In a Calculator page, maximize `x1+x2` subject to `2*x1+2*x2<=5`, with both variables nonnegative integers.

```text
gomory\gomory([[2,2,5][1,1,0]],1,[1,1],[1])
```

The relaxation has objective value 2.5, and the integer optimum is 2. See the [quick reference](QUICK_REFERENCE.md) for the matrix format and printed messages.

## Implementation

The source version is `3.0.5`. For each cut, the program chooses a row whose basic decision variable is marked integer and has the largest fractional right-hand side. It constructs the cut from the fractional parts of that row and applies dual simplex to the updated tableau.

The program is an educational trace for small examples with nonnegative variables and `<=` constraints. The argument flags encode continuous variables, `>=` constraints and equalities. The source applies the same fractional-part formula across variable types and uses a simplified feasibility phase. Verify solutions independently for those cases.

[TI-BASIC source](Problem1.xml) · [Changelog](CHANGELOG.md) · [Original Russian notes](README.ru.md)
