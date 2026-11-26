# Lua document examples

These Lua samples run as interactive pages inside TI-Nspire documents. They show how to draw screens, handle calculator keys and package a Lua script as a `.tns` file.

## Build and open

From the repository root, run these commands after setting up Luna. [Repository build instructions](../README.md)

```bash
./scripts/build-lua.sh economics
./scripts/build-lua.sh econ_cheatsheet
```

Transfer either generated file from `build/` and open it as a document on the TI-Nspire.

## Economics calculator

[`economics.lua`](economics.lua) calculates nominal and real GDP, the GDP deflator, real GDP from a deflator, Laspeyres CPI and inflation. It also displays reference pages for GDP accounting, CPI formulas and neoclassical utility.

Use **↑** and **↓** to move through menus and **Enter** to select. In a calculation, use **Tab** or the up and down arrows to move between fields. **Enter** advances the form or calculates the result. **Esc** returns to the previous screen.

For a one-screen example, open **CPI & Inflation > Inflation**. Enter 110 in **CPI current (%)**, move to **CPI previous (%)** and enter 100. Press **Enter** to see 10%.

## Economics reference browser

[`econ_cheatsheet.lua`](econ_cheatsheet.lua) is a searchable collection of 35 economics questions and notes in transliterated Russian. Type a question number and press **Enter**, or press **Tab** from the main menu to browse the list. [Controls and search reference](CHEATSHEET_README.md)

## Write a Lua document

Save a script as `lua/<name>.lua` and run `./scripts/build-lua.sh <name>`. The samples draw with `on.paint(gc)` and handle keys through callbacks such as `on.enterKey()`. Open the generated file in TI-Nspire software or on the handheld. [TI-Nspire Lua scripting guide](https://education.ti.com/en/guidebook/details/en/59108CCE54484B76AF68879C217D47B2/ti-nspire_scripting-api-guide)

[Original Russian notes](README.ru.md)
