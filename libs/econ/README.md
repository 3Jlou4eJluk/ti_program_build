# Economics formulas

`econ` is a TI-Nspire CAS library for GDP, price indices and growth rates. Its functions take numbers or TI-Nspire lists, depending on the calculation.

## Build and run

From the repository root, run `./scripts/build.sh econ`. Copy `build/econ.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. [Library installation](../README.md)

In a Calculator page, this calculates the CPI for a basket that went from 100 to 150 in cost.

```text
econ\cpi(150,100)
```

The result is 150, with the base period indexed to 100.

## Library objects

- `nominal_gdp(prices,quantities)` sums current prices times current quantities.
- `real_gdp(base_prices,quantities)` values current quantities at base-period prices.
- `gdp_deflator(nominal,real)` returns nominal GDP divided by real GDP, multiplied by 100.
- `basket_cost(prices,quantities)` values a basket at the supplied prices.
- `cpi(cost_current,cost_base)` returns the current basket cost divided by the base cost, multiplied by 100.
- `cpi_from_baskets(p_current,p_base,quantities)` computes the same index from two price lists and a fixed quantity list.
- `inflation_rate(cpi_current,cpi_previous)` returns the percentage change in CPI.
- `growth_rate(old_value,new_value)` returns the percentage change from the first value to the second.
- `version()` returns `"1.0.0"`. `help()` displays the function list.

Use equal-length lists for prices and quantities. The calculation functions return `undef` for unequal list lengths or a zero denominator.

[TI-BASIC source](Problem1.xml) · [Original Russian notes](README.ru.md)
