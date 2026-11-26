# Econometrics for TI-Nspire CX II-T

[Русская версия](README.ru.md)

This example combines four TI-BASIC libraries for the non-CAS TI-Nspire CX II-T with a searchable Russian-language Lua handbook. The libraries export 45 calculation functions and four version helpers. The handbook has 24 theory cards and 29 practice cards with input formats, assumptions, and calculator calls.

## Install on the calculator

1. Extract `econometrics-cx-ii-t.zip` on your computer. Connect the handheld over USB and open [TI-Nspire CX II Connect](https://nspireconnect.ti.com/).
2. Copy the four `.tns` files from the archive's `MyLib` folder directly into `MyLib` on the calculator. Copy `krguide.tns` to a regular documents folder. If you are updating an existing installation, replace all five files.
3. Press **Doc** and choose **Refresh Libraries**. Open a **Calculator** page in a document and enter the call below. Use **Shift + ÷** to enter the backslash. [TI library instructions](https://education.ti.com/html/eguides/nspire/EG_Nspire/EN/content/m_libraries/lb_using_library_objects.HTML)

```text
krroc\gini({0,0,.3,.3,1},{0,.3,.3,1,1})
```

The result is `0.58` or `29/50`, depending on your display settings.

## Use the Lua handbook

Open `krguide.tns`. The handbook draws Cyrillic with bundled bitmap glyphs, including on a TI OS set to English. Type Russian search terms with the Latin keys. For example, use `smeshchenie` or `smeschenie` for «смещение» (bias), `dispersiya` for «дисперсия» (variance), and `dzhini` for «Джини» (Gini). Terms such as `roc`, `gini`, `white`, `2sls`, `adf`, and `ols` also work. Search matches the title, tags, and body, with multiple terms in any order.

- **Tab** switches between «Теория» (Theory) and «Практика» (Practice) and keeps the query.
- **↑ / ↓** moves through search results. **Enter** opens the selected card.
- **↑ / ↓** scrolls by line inside a card. **← / →** scrolls by page.
- **C** copies a calculator call from the open card to the TI clipboard. Press it again to copy the next call.
- **Esc** returns to the results. Press it again to clear the search. **Delete** removes the last character.

Use **Ctrl + V** to paste a call into a Calculator page. Replace placeholders with your own inputs. Enter lists in braces, use the TI matrix template for matrices, and use a decimal point in the examples.

## Worked examples

- **`krdiag`** covers conditional moments from a joint distribution, runs in ordered residuals, and White and Dickey–Fuller tests from regression results. [Regression diagnostics](guide/diagnostics.md)
- **`krroc`** computes AUC and Gini from an ROC curve or from labeled scores. `krroc\steparea({0,.3,1},{.3,1})` returns `{.79,.58}`. [ROC, AUC, and Gini](guide/roc.md)
- **`krsys`** checks identification by order and rank and estimates two-stage least squares. [Simultaneous equations and 2SLS](guide/systems.md)
- **`krextra`** works from observations for OLS, robust standard errors, hypothesis tests, regression diagnostics, and binary-response calculations. [Additional econometrics examples](guide/course.md)

The source checkout also includes Russian desktop exercises and solutions in `offline/drill.json`.

## Build from source

You need Python 3 and [Luna](https://github.com/ndless-nspire/Luna) (tested at revision `a9924a9a`). From `examples/econometrics` in the checkout, run:

```sh
python3 build.py --luna /path/to/Luna/luna
```

The build writes the five calculator files, `krcheck.tns`, and `econometrics-cx-ii-t.zip` to `build/`. TI-BASIC function sources are in `libs/`, card content is in `guide/*.json`, and the Lua event handlers are in `handbook.lua`.

## Run the UI checks with LuaJIT

Run the following from `examples/econometrics` in a fresh checkout with Python 3 and LuaJIT:

```sh
mkdir -p build
python3 build.py --guide-source > build/krguide.lua
luajit tests/guide.lua build/krguide.lua
```

These checks use stand-ins for the TI Lua drawing and clipboard APIs. They cover bitmap Cyrillic, math and arrows, search ranking in Cyrillic and Latin script, Tab navigation, copying, pagination, and viewport resizing.

## Check on TI OS

Build and copy `build/krcheck.tns` to a regular documents folder after installing the libraries. Open the document and press **Enter**. Use **← / →** to page through the check names. The document compares results from the TI math engine with known values.

A Firebird run on an emulated non-CAS **TI-Nspire CX** with **OS 4.5.5.79** passed **55/55** checks. The guide was also exercised there for Cyrillic rendering with English TI OS, Latin-key search, copy, Tab navigation, and scrolling. Verification on the target **CX II-T** remains open.

## Font attribution

The handbook's 12-pixel bitmap glyphs are rasterized from Noto Sans Mono Regular, copyright 2022 The Noto Project Authors. The bitmap data is distributed under the SIL Open Font License 1.1. [Font project](https://github.com/notofonts/latin-greek-cyrillic) · [License](LICENSE-NOTO-SANS-MONO.txt)
