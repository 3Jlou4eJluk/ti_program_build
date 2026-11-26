# Gomory quick reference

Install the library using the [README](README.md), then call `gomory\gomory(mat,opt,intvars,ctypes)` from a Calculator page.

## Arguments

All matrix and flag inputs are TI-Nspire matrices. Use a one-row matrix for each flag argument.

- `mat` has one row per constraint followed by an objective row. A constraint row contains its decision-variable coefficients followed by the right-hand side. The objective row contains the objective coefficients followed by 0.
- `opt` is 1 for maximization or 0 for minimization.
- `intvars` has one entry per decision variable. Use 1 for integer and 0 for continuous.
- `ctypes` has one entry per constraint row. Use 1 for `<=`, −1 for `>=`, and 0 for equality.

For a problem with two integer variables and two upper-bound constraints, the flag matrices are `[1,1]` and `[1,1]`.

```text
gomory\gomory([[1,2,8][3,2,12][3,4,0]],1,[1,1],[1,1])
```

This maximizes `3*x1+4*x2` under the two constraints shown in the matrix. The optimum is 18 at `x1=2` and `x2=3`.

## Reading the trace

- `PHASE 1: Find feasible` and `PHASE 2: Optimize` report pivots leading to the solution under `LP SOLUTION`.
- `INTEGRALITY CHECK` displays values for the variables marked integer.
- `GOMORY CUT #` shows the source row, its fractional right-hand side and the cut coefficients.
- `DUAL SIMPLEX` displays pivots after adding the cut.
- `ANSWER` prints the objective, decision-variable values and cut count. Check these values against the original model.
- `max iter` or `Max cuts reached` indicates that the program hit a limit. The code caps each simplex phase at 30 iterations and the outer loop at 20 cuts.

## Other library objects

- `gomory\version()` returns `"3.0.5"`.
- `gomory\help()` displays the call signature and flag values. The help banner still says `3.0.0`.
- `gomory\gcd(a,b)`, `gomory\lcm2(a,b)`, `gomory\modabs(y,d)`, `gomory\getdenom(x)` and `gomory\findmu(beta,d)` are standalone helpers. The current cutting loop uses fractional parts directly.

[TI-BASIC source](Problem1.xml)
