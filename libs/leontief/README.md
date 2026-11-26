# Leontief input-output model

`leontief` is a TI-Nspire CAS example for computing sector output and checking productivity in an input-output model. It uses a square technical-coefficient matrix `A` and demand written as a column matrix.

## Build and run

From the repository root, run `./scripts/build.sh leontief`. Copy `build/leontief.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. [Library installation](../README.md)

The following example computes the gross output required to meet final demand of 8 and 9 in two independent sectors.

```text
leontief\calc_prod([[0.2,0][0,0.1]],[[8][9]])
```

The result is a column matrix containing 10 and 10.

## Library objects

- `calc_prod(A,Y)` returns `(I-A)^(-1)*Y`. Use an invertible `I-A`.
- `show_prod(A,Y)` displays the same calculation step by step.
- `solve_output(A,deltaY)` displays the output change for a given change in final demand.
- `calc_output(Xij,Y,Ystar)` computes current output from row sums plus current demand, divides each flow column by the corresponding sector's current output and displays the gross output required to meet `Ystar`. Use nonzero current outputs.
- `is_productive(A)` returns 1 when every column sum is below 1 and 0 otherwise. For nonnegative coefficients, passing this test establishes productivity.
- `check_prod(A)` prints the column sums. If the column-sum test fails, it checks the leading principal minors of `I-A` using the Hawkins–Simon criterion for a nonnegative technical-coefficient matrix.
- `version()` returns `"1.0.0"`.

[TI-BASIC source](Problem1.xml) · [Original Russian notes](README.ru.md)
