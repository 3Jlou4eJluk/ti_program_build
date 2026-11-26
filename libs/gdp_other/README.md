# GDP and price index formulas

`gdp_other` is a TI-Nspire CAS library for quick calculations involving national accounts, price indices, real income and purchasing power.

## Build and run

From the repository root, run `./scripts/build.sh gdp_other`. Copy `build/gdp_other.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. [Library installation](../README.md)

In a Calculator page, enter household consumption, investment, government spending, exports and imports in that order.

```text
gdp_other\gdp_r(115,15,0,75,15)
```

The result is 190.

## Library objects

- `gdp_r(c,i,g,x,m)` computes expenditure GDP as `c+i+g+x-m`.
- `ds(vyp,pp)` subtracts intermediate consumption from gross output to get value added.
- `profit(vyr,syr,zp)` subtracts input costs and wages from sales revenue.
- `cpi(pn,p0,q)` computes the Laspeyres price index from current prices, base prices and fixed quantities.
- `infl(cpi1,cpi0)` computes the percentage change from the earlier CPI to the current CPI.
- `defl(nom,real)` computes the GDP deflator as `100*nom/real`.
- `rgdp(nom,def)` recovers real GDP from nominal GDP and a deflator on a base-100 scale.
- `fisher(lasp,paas)` takes the geometric mean of the Laspeyres and Paasche indices.
- `rinc(nom,cpi)` divides nominal income by `cpi/100`.
- `pp(cpi)` returns purchasing power relative to the base period as `100/cpi`.
- `version()` returns `"1.0.0"`.

Use equal-length price and quantity lists and supply nonzero denominators.

[TI-BASIC source](Problem1.xml) · [Original Russian notes](README.ru.md)
