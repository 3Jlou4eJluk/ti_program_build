# ROC curves, AUC, and Gini

Use `krroc` to compute ROC area and Gini from a graph or from labeled scores. [Installation](../README.md#install-on-the-calculator)

## Build a ROC curve

1. Assign each observation a true label of `1` or `0` and a score that increases with confidence in class `1`.
2. Start with a threshold above the maximum score. The first point is `(0,0)` because no observations are classified as positive.
3. Visit the distinct scores from highest to lowest. At each threshold `c`, predict class `1` for every observation with `score ≥ c`. Include all observations tied at that score in the same step.
4. Plot the false positive rate `FPR = FP/(FP+TN)` horizontally and the true positive rate `TPR = TP/(TP+FN)` vertically. The last point is `(1,1)`.
5. Join consecutive points with straight lines. Sum the trapezoid areas `(FPR₂−FPR₁)·(TPR₂+TPR₁)/2` to get AUC. Vertical segments contribute zero. Gini is `2·AUC−1`.

## Calculate from a graph

Pass two equal-length lists of FPR and TPR coordinates. Start at `(0,0)`, end at `(1,1)`, and keep both vertices of each vertical segment. Each coordinate must be in `[0,1]` and nondecreasing.

For a step at `(0.3,0.3)`, the intervening vertices are `(0,0.3)`, `(0.3,0.3)`, and `(0.3,1)`. The area is `0.3·0.3 + 0.7·1 = 0.79` and Gini is `0.58`.

```text
krroc\auc({0,0,0.3,0.3,1},{0,0.3,0.3,1,1})
krroc\gini({0,0,0.3,0.3,1},{0,0.3,0.3,1,1})
```

For a step at `(0.4,0.4)`, the intervening vertices are `(0,0.4)`, `(0.4,0.4)`, and `(0.4,1)`. The area is `0.4·0.4 + 0.6·1 = 0.76` and Gini is `0.52`.

```text
krroc\auc({0,0,0.4,0.4,1},{0,0.4,0.4,1,1})
krroc\gini({0,0,0.4,0.4,1},{0,0.4,0.4,1,1})
```

## Calculate from predictions

Pass equal-length lists of labels and scores in observation order. Labels must include both classes. Scores must be finite real numbers. `roc` returns a matrix with columns `[FPR, TPR, threshold]`. Its first row uses the strict rule `score > max(scores)`. Subsequent rows use `score ≥ threshold`, one row per unique score in descending order.

```text
y:={1,0,0,1}
scores:={0.5,0.5,0.1,0.9}
krroc\roc(y,scores)
krroc\aucpred(y,scores)
krroc\ginipred(y,scores)
```

The matrix rows are `[0,0,0.9]`, `[0,0.5,0.9]`, `[0.5,1,0.5]`, and `[1,1,0.1]`. Two observations with different labels share the score `0.5`. The result is `AUC = 0.875` and `Gini = 0.75`. In the equivalent pairwise calculation, tied scores for a positive and a negative observation receive half credit.

## Step curves, grouped counts, and thresholds

- `krroc\steparea({0,.3,1},{.3,1})` returns `{.79,.58}` for the step curve. Give it `m+1` strictly increasing FPR boundaries from 0 to 1 and `m` nondecreasing segment heights. Use `auc` for curves with sloped segments.
- `krroc\groupauc({1,1,0},{0,1,1})` returns `{.875,.75}` from counts of positives and negatives by score group, highest score first.
- `krroc\cutoff({1,0,0,1},{.5,.5,.1,.9},3,1)` chooses a threshold to minimize classification cost. With a false positive costing 3 and a false negative costing 1, the result is `{.9,0,0,.5,1}` in the order `{threshold, strict, FPR, TPR, cost}`. The inclusive threshold `0.9` gives `FPR=0`, `TPR=0.5`, and a cost of 1.

For `cutoff`, the strict flag is `1` for the initial rule `score > max(scores)` and `0` for `score ≥ threshold`. Supply nonnegative costs with at least one positive value. If costs tie, the function chooses the stricter threshold.
