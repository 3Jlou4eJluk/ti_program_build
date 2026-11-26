# TI-Nspire engineering notes and workarounds

The Leontief and Gomory experiments show how to isolate TI-BASIC failures after packaging. The econometrics example adds a repeatable OS test document and a Lua workaround for rendering localized text. See the [build and debug guide](README.md) for the XML layout and the recorded test environment.

## A library builds but one object disappears

During Leontief development, Luna produced a `.tns` and TI OS loaded `version()`, but `is_productive()` was missing. The failing body had an `If` followed by a command block and `EndIf`, with no `Then`. Adding `Then` restored the block form. TI-BASIC also supports `If condition` followed by one statement. The block form closes with `EndIf`. [Original Leontief notes (Russian)](archive/ru/delta2.md) · [TI reference guide](https://education.ti.com/~/media/76E7A60885A64C9DB23E809CB5480BC5)

Keep a small public `version()` or `Return 42` function during debugging. When it loads and the edited object is absent, test the edited object's visibility and body in isolation. Restore its input parsing, loops, conditionals, and output in small steps. Check which addition first changes the result on TI OS. If you write the XML by hand, compare the failing `<v>` with the [generator's output](../examples/econometrics/build.py). The original advice about compact XML describes a serialization pattern that worked in those experiments. In particular, TI documents the `©` comment syntax, and several reference inputs contain line breaks between XML elements. [Original format notes (Russian)](archive/ru/delta.md) · [TI Program Editor syntax examples](https://education.ti.com/html/webhelp/nspire/3.2/SS/TI-NspireStudentSoftwareHelp_EN/Content/Programming/PR_Defining_a_Program_or_Function.htm)

## A new loop introduces a local variable

Gomory's LP relaxation display loaded with just the objective value and still loaded after adding a loop over the variables. Adding fractional-variable labels caused the failure. The loop used `frac`, which the initial `Local` list omitted. A later section also declared that name. The recorded fix added an explicit `Local frac` before the calculation in the new loop. For fresh code, declare temporaries with the other locals and trace every branch to make sure each variable is assigned before its first read. [Original Gomory loop notes (Russian)](archive/ru/delta4.md) · [TI Program Editor guide on local variables](https://education.ti.com/-/media/36F9A2B4CF79415BB18DA61889A63621)

Gomory's earlier display experiment failed after introducing `Pause` and loaded again when the command was removed. Use `Disp` to show intermediate values in a diagnostic program. For strings, concatenate with `&` in TI-BASIC and encode it as `&amp;` in XML. [Original Gomory development notes (Russian)](archive/ru/delta3.md)

## A resized simplex tableau returns incorrect results

An early Gomory cut implementation added one row and one column to a tableau. The cut occupied the old objective row, and the new slack column occupied the old right-hand-side column. Three changes made the data movement explicit.

1. Copy constraint rows separately. Insert the cut row, then move the objective row to the bottom.
2. Keep the new slack column separate from the old right-hand-side values. Copy those values to the new last column.
3. Recompute the last row and column with `rowDim()` and `colDim()` after resizing. Derive the dual-simplex pivot from the current objective row.

When extracting a basic variable from a floating-point unit column, check that exactly one entry is near one and every other entry is near zero. A column such as `[0.5, 1, 0.2]` fails that check. Test the reported objective and variable values together after adding a cut. [Original tableau debugging notes (Russian)](archive/ru/delta3.md) · [Gomory v3 algorithm notes](gomory_v3_algorithm.md)

## Localized Lua text and input

The econometrics handbook draws Cyrillic from a bundled bitmap font and normalizes Latin transliterations for search. The keyboard can then find a Russian term from a spelling such as `dispersiya`. Its Lua test document calls the installed TI-BASIC libraries through the TI math engine and compares each number with an expected value. The screenshots record rendering and search on TI OS alongside the numeric checks. [Handbook source](../examples/econometrics/handbook.lua) · [Search screenshot](../examples/econometrics/tests/evidence/search.png) · [Test source](../examples/econometrics/tests/krcheck.lua)
