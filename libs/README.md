# TI-BASIC library examples

These examples show how to package callable TI-BASIC functions and programs as TI-Nspire CAS libraries. Each library directory contains document settings in `Document.xml` and library objects in `Problem1.xml`.

- [`econ`](econ/README.md) calculates GDP, CPI, inflation and growth rates.
- [`gdp_other`](gdp_other/README.md) adds expenditure GDP, price indices, real income and purchasing power formulas.
- [`gdp_methods`](gdp_methods/README.md) displays a worked GDP accounting exercise in transliterated Russian.
- [`leontief`](leontief/README.md) computes sector output and checks productivity in a Leontief input-output model.
- [`gomory`](gomory/README.md) prints an integer programming example using a Gomory cutting-plane routine.

## Install a library

From the repository root, run `./scripts/build.sh <name>` after setting up Luna. Copy the resulting `build/<name>.tns` to the handheld's `MyLib` folder, then select **Doc > Refresh Libraries**. Open a Calculator page to call an object by its qualified name, such as `econ\cpi(150,100)`. [Repository build instructions](../README.md), [TI library instructions](https://education.ti.com/en/customer-support/knowledge-base/ti-nspire-family/product-usage/34192)
