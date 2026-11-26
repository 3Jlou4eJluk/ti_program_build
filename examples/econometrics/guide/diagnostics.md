# Regression diagnostics

Use `krdiag` for conditional moments, runs tests, and calculations from White and Dickey–Fuller regressions. [Installation](../README.md#install-on-the-calculator)

## Bias and conditional moments

Estimator bias is `E(betaHat) − beta`. In a linear model with full column rank and `E(e|X)=0`, OLS gives `E(betaHat|X)=beta` and hence `E(betaHat)=beta`.

For a joint distribution, pass a list of regressor values, a list of error values, and a matrix whose rows index regressors and columns index errors. Matrix entries may be nonnegative probabilities or frequencies. Here the regressor is equally likely to be 1 or 7. At either value, the error is equally likely to be −1 or 1.

```text
xv:={1,7}
ev:={-5,-1,1,5}
p:=[[0,1/4,1/4,0][0,1/4,1/4,0]]
krdiag\jcond(xv,ev,p,10^-10)
krdiag\jmom(xv,ev,p,10^-10)
krdiag\jvar(xv,ev,p,10^-10)
krdiag\biases(xv,ev,p,10^-10)
```

- `jcond` returns rows of `[x,P(x),E(e|x),Var(e|x)]`. Here the rows are `[1,1/2,0,1]` and `[7,1/2,0,1]`. A row for a zero-probability value has placeholders of zero for its conditional mean and variance.
- `jmom` returns `{sumP,E(x),E(e),Var(x),Var(e),Cov(x,e),E(xe),min Var(e|x),max Var(e|x)}`. Here the result is `{1,4,0,9,1,0,0,1,1}`.
- `jvar` returns `{Var(e),E[Var(e|x)],Var(E[e|x]),minVar,maxVar,hetero,meanZero}`. Here the result is `{1,1,0,1,1,0,1}`. The flag `hetero` equals 1 when `maxVar−minVar > tol`. The flag `meanZero` equals 1 when `abs(E(e|x)) ≤ tol` in every group with positive probability. Choose the absolute tolerance for the scale of the means and variances.
- `biases` returns two population slope shifts. The first is `E(xe)/E(x^2)` for regression through the origin. The second is `Cov(x,e)/Var(x)` for regression with an intercept. Here both are zero.

The example has zero conditional mean and a constant conditional variance of 1. Its unconditional error variance is also 1.

## Runs test

Pass residuals in observation order. The function excludes residuals for which `abs(e) ≤ tol`. A run is a contiguous block of one sign among the remaining residuals.

```text
e:={-5,-4.5,-1.2,-3,-5,1,5.5,5,3,4,2.1,8,-1.2,-2,-1,1,1.5,2,3,-1}
krdiag\runs(e,10^-10)
```

The output is `{nPlus,nMinus,R,E(R),Var(R),z,nZero}`. The example gives approximately `{11,9,5,10.9,4.63737,-2.73978,0}`.

If your exercise supplies lower and upper critical values `K1` and `K2` for the observed counts of signs, pass them directly:

```text
krdiag\rdecision(e,6,16,10^-10)
```

The function returns `-1` for `R ≤ K1`, `1` for `R ≥ K2`, and `0` between them. Too few runs suggest positive serial dependence, while too many suggest negative serial dependence. In this example, `R=5` gives `-1`.

### Exact runs test

```text
krdiag\rexact(e,0.05,10^-10)
```

The output is `{nPlus,nMinus,R,pLow,pHigh,pTwo,decision,nZero}`. Under the null, all sign sequences with the observed positive and negative counts are equally likely. The one-sided tails `pLow = P(R ≤ observed R)` and `pHigh = P(R ≥ observed R)` include the observed count. The two-sided p-value is `min(1,2*min(pLow,pHigh))`.

If `pTwo ≤ alpha`, the decision is `-1` for the smaller lower tail and `1` for the smaller upper tail. Otherwise it is `0`. The example gives `pLow ≈ 0.00488211`, `pHigh ≈ 0.99892832`, `pTwo ≈ 0.00976423`, and decision `-1`. Supply `0 < alpha < 1` and up to 200 nonzero residuals after applying the tolerance, with at least one residual of each sign. Invalid input returns `undef`.

## White test

1. Fit the original regression and save the residuals `e`.
2. Regress `e^2` on a constant, the original regressors, their squares, and pairwise products. Retain linearly independent columns.
3. Find the auxiliary `R^2` and let `m` be the count of independent nonconstant regressors. Under homoskedasticity, use a chi-square critical value with `m` degrees of freedom to test `LM = n*R^2`.

```text
krdiag\white(40,0.25,5,11.07)
```

The result is `{LM,m,reject}`. The example returns `{10,5,0}`. A rejection of homoskedasticity sets the last value to 1.

## Dickey–Fuller and augmented Dickey–Fuller tests

Fit a regression of the first difference on the lagged level. Choose the deterministic terms specified by the test:

```text
Delta(y_t)=gamma*y_(t-1)+u_t
Delta(y_t)=a+gamma*y_(t-1)+u_t
Delta(y_t)=a+b*t+gamma*y_(t-1)+u_t
```

For ADF, add lagged differences `Delta(y_(t-i))` to account for serial dependence. The null hypothesis of a unit root is `gamma=0`. Compare `tau=gamma/se(gamma)` with the lower-tail Dickey–Fuller critical value for the chosen specification. For a level regression written as `y_t=rho*y_(t-1)+u_t`, use `krdiag\dfstat(rho,se)` to calculate `(rho−1)/se`.

```text
krdiag\adftest(-0.35,0.10,-2.95)
```

The result is `{tau,reject}`. The example returns `{-3.5,1}` because `tau < crit`. To fit an ADF regression directly from observations, see `krextra\adf` in the [additional examples](course.md).
