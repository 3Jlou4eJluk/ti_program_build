# Three approaches to GDP

`gdp_methods` is a TI-Nspire CAS library that displays a worked GDP accounting exercise. The example follows wheat from a farm to a bakery and covers value added, spending and income. The calculator output uses transliterated Russian.

## Build and run

From the repository root, run `./scripts/build.sh gdp_methods`. Copy `build/gdp_methods.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. [Library installation](../README.md)

Run the worked calculation in a Calculator page.

```text
gdp_methods\calculate()
```

The program displays the same GDP of 190,000 from all three approaches. Each program takes zero arguments and prints prepared lesson text. For functions that take values from your own exercise, see [GDP and price index formulas](../gdp_other/README.md).

## Library objects

- `guide()` summarizes the accounting rules.
- `example()` displays the quantities, prices and wages used in the example.
- `calculate()` shows the arithmetic for each of the three approaches.
- `version()` returns `"1.0.0"`.

[TI-BASIC source](Problem1.xml) · [Original Russian notes](README.ru.md)
