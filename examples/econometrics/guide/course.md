# Additional econometrics examples

Use `krextra` when you have raw observations or fitted model results. It covers OLS, classical and heteroskedasticity-robust inference, residual diagnostics, binary predictions, and instrumental-variable diagnostics. [Installation](../README.md#install-on-the-calculator)

## Fit and check a regression

Open a Calculator page and store the response vector and design matrix. Insert `list►mat` from the Catalog or type `list@>mat` using a computer keyboard. [TI-Nspire reference guide](https://education.ti.com/-/media/5570054579E94ABA88612EAD9D0B4165)

```text
list►mat({2,1,4,3,6,8,6},1)→y
list►mat({1,-3,1,-2,1,-1,1,0,1,1,1,2,1,3},2)→x
```

The following calls use the example data. Results are rounded for display.

- `krextra\ols(y,x)` returns the coefficient column `[[4.285714][1]]`.
- `krextra\olssum(y,x)` returns `{7,2,9.428571,1.885714,0.748092,0.697710}`.
- `krextra\olstab(y,x,-1,0.05)` gives the slope's classical standard error `0.259513`, t-statistic `3.853373`, p-value `0.011960`, and 95% interval `[0.332901,1.667099]`.
- `krextra\olstab(y,x,3,0.05)` gives the slope's HC3 standard error `0.366576` and asymptotic 95% interval `[0.281524,1.718476]`.
- `krextra\ftest(262/7,66/7,1,5)` returns `{14.848485,1,5,0.011960}` for the F-statistic, numerator and denominator degrees of freedom, and p-value.
- `krextra\het(y,x,1)` returns `{1.853104,2,0.395916}` for White's statistic, degrees of freedom, and p-value.
- `krextra\dw(mat►list(krextra\resid(y,x)))` returns a Durbin–Watson statistic of `2.757576`.
- `krextra\bg(y,x,1)` returns `{2.437425,1,0.118471}` for the Breusch–Godfrey statistic, degrees of freedom, and p-value.
- `krextra\adf({1,2,1,3,2,4,2,5,4,3},1,1)` returns `{-1.099172,-0.488764,0.444666,8}` for the ADF statistic, lagged-level coefficient, standard error, and sample size after lagging.

Include a first column of ones for `olssum`, `het`, and `bg`. Use full-rank designs with columns on comparable scales for the normal equations. Preserve the observation order for Durbin–Watson, Breusch–Godfrey, and ADF. The small-sample HC, LM, and ADF examples illustrate the calculations. Use an ADF critical value for the chosen specification. [Regression diagnostics](diagnostics.md)

## Prediction, restrictions, and instrumental variables

- `krextra\predint(y,x,xnew,a)` returns a point prediction, the lower and upper limits for the conditional mean, and the lower and upper limits for one new observation. Supply a single-row matrix `xnew` and significance level `a`. The classical intervals assume independent, normal, homoskedastic errors and full column rank.
- `krextra\wald(y,x,r,target,hc)` tests one or more independent linear restrictions `Rβ=target`. With `hc=-1`, the output is `{F,q,n−k,p}`. With `hc` from 0 to 3, the output is `{W,q,0,p}` using the asymptotic chi-square distribution. The joint covariance of the restrictions must be nonsingular.
- `krextra\lrtest(llrest,llfull,q)` returns `{LR,q,p}` for two nested maximum-likelihood models fitted to the same data. The usual chi-square approximation assumes independent regular restrictions and an interior parameter value.
- `krextra\firstf(endog,base,omit)` returns the first-stage partial F-statistic, number of restrictions, residual degrees of freedom, p-value, and partial `R^2` for excluded instruments. Pass one endogenous regressor as a column matrix, included exogenous regressors as `base`, and excluded instruments as `omit`. Include a column of ones in `base` if the model has an intercept.
- `krextra\sargan(err,z,k)` returns `{J,L−k,p}` for the classical Sargan test. Pass structural 2SLS residuals computed using actual regressor values, the full set of `L` instruments with a first column of ones, and the number of structural coefficients `k`. The model must be overidentified and the errors homoskedastic. [2SLS and identification](systems.md)

## Binary predictions

- `krextra\binprob(1,0)` applies the logistic link inverse and returns `0.731059`. `krextra\binprob(1,1)` applies the standard normal CDF for probit and returns `0.841345`.
- `krextra\binary({1,0,0,1},{0.5,0.5,0.1,0.9},0.5)` returns `{2,1,1,0,1,0.5,2/3,0.75,0.8}`. Scores at or above the threshold are positive. [ROC and threshold selection](roc.md)
