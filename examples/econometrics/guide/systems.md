# Simultaneous equations and two-stage least squares

Use `krsys` to check identification and estimate two-stage least squares (2SLS). The library computes numerical ranks with Gaussian elimination. [Installation](../README.md#install-on-the-calculator)

## Check identification for one equation

Let `kex` be the number of predetermined variables excluded from the equation and `nrhs` be the number of right-hand-side endogenous variables.

```text
krsys\idord(kex,nrhs)
```

The result is `kex−nrhs`. A negative value fails the necessary order condition. Zero indicates exact identification by order, and a positive value indicates overidentification by order. Check rank before concluding that the equation is identified.

Form `M` from the coefficients on variables excluded from the equation, using the other equations as rows. For a system with `G` endogenous variables, the required rank `need` is typically `G−1`.

```text
krsys\mrank(M,10^(-10))
krsys\idrank(M,need,10^(-10))
krsys\idall(kex,nrhs,M,need,10^(-10))
```

`idrank` returns 1 if the rank is sufficient and 0 otherwise. `idall` returns one of four codes.

- `-1` means the order condition fails.
- `-2` means the order condition passes and the rank condition fails.
- `0` means exactly identified.
- `1` means overidentified.

## Check the full structural matrix

Write the system as `B*y + A*x = u` and pass the augmented matrix `H=[B|A]` with `G` rows to `krsys\idstruct(H,G,cm,mask,tol)`. The first `G` columns are the endogenous variables in equation order. Each equation must have a nonzero coefficient on its dependent variable. The remaining columns are predetermined variables.

- `cm=1` treats the last column as a common intercept and excludes it from the identification checks. `cm=0` includes every column of `A` in the checks.
- `mask=0` treats exact zeros as structural exclusions. To include a coefficient whose numerical value happens to be zero, pass a mask with the same size as `H`. Use 1 for included entries and 0 for excluded entries. Excluded coefficients must equal zero.
- `tol>0` sets the elimination tolerance. For coefficients of order one, use `10^(-10)`.

The first `G` result rows contain `[kex,nrhs,kex-nrhs,rank(M),G-1,code]`, using the same codes as `idall`. The last row contains `[nOrderFail,nRankFail,nExact,nOver,rank(B),systemCode]`. The rank failure count includes equations with code `-2`. The system code is 1 when every equation is identified and `B` has full rank, 0 when `B` is invertible and at least one equation fails, and −1 when `B` is singular. A singular `B` gives no unique reduced form. Invalid arguments return `undef`.

### Worked example with an intercept

```text
y1 = b12*y2 + b13*y3 + a
y2 = b23*y3 + a21*x1 + a22*x2 + a23*x3 + a24*x4
y3 = b31*y1 + a31*x1 + a34*x4
```

Here `y1,y2,y3` are endogenous and `x1` through `x4` are exogenous. Enter a numerical instance with columns `y1,y2,y3,x1,x2,x3,x4,c`. Move regression terms to the left to construct the matrix.

```text
h:=[[1,-2,-1,0,0,0,0,-2][0,1,-1,-1,-2,-3,-4,0][-1,0,1,-2,0,0,-1,0]]
krsys\idstruct(h,3,1,0,10^(-10))
krsys\idstruct(h,3,0,0,10^(-10))
```

With a common intercept, the last row is `[1,0,0,2,3,0]`. Equation 1 excludes four variables and has two endogenous regressors on the right. Equation 2 excludes zero variables and has one endogenous regressor on the right, so it fails the order condition. Equation 3 excludes `x2` and `x3` and has one endogenous regressor on the right.

The symbolic rank blocks for the three equations are shown below up to row and column sign changes, which preserve rank.

```text
M1=[[a21,a22,a23,a24][a31,0,0,a34]]
M2=[[1][-b31]]
M3=[[-b12,0,0][1,-a22,-a23]]
```

Using ones in place of the structurally nonzero coefficients gives a typical case. For fixed numerical coefficients, insert their actual values to establish the rank. For a symbolic system, state the conditions on nonzero minors.

```text
krsys\idall(4,2,[[1,1,1,1][1,0,0,1]],2,10^(-10))
krsys\idall(0,1,[[1][-1]],2,10^(-10))
krsys\idall(2,1,[[1,0,0][1,1,1]],2,10^(-10))
```

The three results are `1`, `-1`, and `1`.

If you treat `c=1` as a separate predetermined variable that appears only in the first equation, the last result row for `idstruct` is `[0,0,1,2,3,1]`. Equation 2 now has one excluded instrument and meets the order condition exactly. The determinant for its excluded variables `y1,c` is `a*b31` up to sign. With both coefficients nonzero, this equation is exactly identified. Equation 3 excludes `x2,x3,c`. Its minor in columns `y2,c` is nonzero for `a≠0`. Equation 1 remains overidentified under the rank conditions above. State which intercept convention you use when interpreting the result.

## Estimate two-stage least squares

Prepare three matrices with the same number of rows.

- `y` is an `n×1` response column.
- `X` contains the structural regressors.
- `Z` contains the exogenous regressors from `X` and the excluded instruments. Include a column of ones in both `X` and `Z` if the model contains an intercept.

Instruments must be exogenous with respect to the structural error and relevant to the endogenous regressors conditional on the other instruments. A first-stage F-statistic can help assess relevance. The data matrices alone cannot establish exogeneity. [First-stage F and Sargan tests](course.md#prediction-restrictions-and-instrumental-variables)

1. Regress each endogenous regressor on all columns of `Z`. Keep its fitted values and the included exogenous regressors as `Xhat=Pz*X`, where `Pz=Z(ZᵀZ)^(-1)Zᵀ`.
2. Regress `y` on `Xhat`. The resulting coefficients are `(XᵀPzX)^(-1)XᵀPz*y`.

```text
y:=[[2][3][5][7][8][10]]
X:=[[1,1][1,2][1,2][1,4][1,5][1,6]]
Z:=[[1,1][1,1.5][1,2.5][1,3.5][1,5][1,6.5]]
krsys\tsls(y,X,Z)
```

The example returns approximately `[[0.614754][1.565574]]`. View the projected regressors with `krsys\firststg(X,Z)`. Use `krsys\tslsfull(y,X,Z)` for columns `[coefficient, standard error, t]` from the classical homoskedastic covariance `s²(XᵀPzX)^(-1)`.

The number of instruments must be at least the number of regressors. Both `ZᵀZ` and `XᵀPzX` must be nonsingular. The library checks dimensions and an obvious shortage of instruments. TI OS reports an inversion error for singular matrices.
