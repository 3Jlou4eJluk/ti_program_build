# Building and debugging TI-Nspire documents

Use Luna to package TI-BASIC library XML or a Lua script into a `.tns` document. Then open the document and exercise it in TI OS. A successful Luna build confirms that the input was packaged. TI OS decides whether the library objects load and how the code runs. [Luna usage](https://github.com/ndless-nspire/Luna#usage)

## Encode a TI-BASIC library

Use the compact UTF-8 layout emitted by the [econometrics builder](../examples/econometrics/build.py). Start with its [`Document.xml`](../examples/econometrics/Document.xml), which uses a `<doc ver="1.0">` root and declares one problem. Create `Problem1.xml` alongside it with a `<prob>` root in the `urn:TI.Problem` namespace, library objects in `<sym>`, and a Notes page in `<card>`.

Each `<e>` gives the object name in `<n>`, a comma-separated parameter list in `<p>`, and the body in `<v>`.

- Use `t="6"` for `Func` → `EndFunc` and `t="7"` for `Prgm` → `EndPrgm`.
- Use `f="65536"` for public library objects and `f="196608"` for private ones. The econometrics generator sets `c="0"`. Follow its layout for new objects.
- Separate body lines with `&#13;` and prefix each line after the opener with `:`, including the closing line. Escape the contents of each source line before joining the lines. Encode `<`, `>`, and `&` as `&lt;`, `&gt;`, and `&amp;`.
- Use `→` to store a value and use `If condition Then` followed by `EndIf` for conditional blocks. Give functions a value with `Return`. Use `Disp` in programs for diagnostic output. [TI Program Editor guide](https://education.ti.com/-/media/36F9A2B4CF79415BB18DA61889A63621)

This `Problem1.xml` defines a public function that returns zero for negative input and the input itself otherwise.

```xml
<?xml version="1.0" encoding="UTF-8" ?><prob xmlns="urn:TI.Problem" ver="1.0"><sym><e t="6" f="65536" c="0"><n>clampzero</n><p>x</p><v>Func&#13;:If x&lt;0 Then&#13;:Return 0&#13;:EndIf&#13;:Return x&#13;:EndFunc</v></e></sym><card clay="0" h1="10000" h2="10000" w1="10000" w2="10000"><flag>0</flag><wdgt xmlns:np="urn:TI.Notepad" type="TI.Notepad" ver="1.0"><np:mFlags>0</np:mFlags><np:value>3</np:value><np:txt>tiny / MyLib</np:txt></wdgt></card></prob>
```

From the directory containing both XML files, invoke Luna from your `PATH` or use its full path.

```sh
luna Document.xml Problem1.xml tiny.tns
```

Copy `tiny.tns` into the calculator's `MyLib` folder and select **Doc → Refresh Libraries**. In a Calculator page, try `tiny\clampzero(-3)` and `tiny\clampzero(5)`. The expected results are `0` and `5`. [TI library installation and naming rules](https://education.ti.com/html/eguides/nspire/EG_Nspire/EN/content/m_libraries/lb_creating_libraries_and_library_objects.HTML)

## Debug on TI OS

1. Confirm the `.tns` filename matches the library prefix, the file is directly inside `MyLib`, and libraries have been refreshed since transfer. Test a known public object by its full name `library\function(arguments)`. [TI guide to using library objects](https://education.ti.com/html/eguides/nspire/EG_Nspire/EN/content/m_libraries/lb_using_library_objects.HTML)
2. If the library loads but one object is absent, reduce that object's body to a known result such as `Return 42`. Rebuild, replace the installed file, refresh, and call the object. Add back one block at a time. In the failing block, check carriage-return references, XML escaping, matching block delimiters, and local variables initialized before they are read. The Program Editor offers **Check Syntax & Store** when you can open the object there. [TI Program Editor guide](https://education.ti.com/-/media/36F9A2B4CF79415BB18DA61889A63621)
3. If the object loads but returns the wrong value, exercise the smallest input with a known answer. Return an intermediate value temporarily from a function or print it from a program. For a suite of checks, use a Lua test document that evaluates public library calls through `math.eval`. See [`krcheck.lua`](../examples/econometrics/tests/krcheck.lua).

## Verification and references

- The [econometrics example](../examples/econometrics/README.md) has a recorded run of **55/55** TI OS checks in Firebird on an emulated TI-Nspire CX without CAS, OS **4.5.5.79**. The CX II-T is the package target and still needs a run on that model. [Results](../examples/econometrics/tests/evidence/c-result1.png) · [OS version](../examples/econometrics/tests/evidence/os-version.png)
- The [other TI-BASIC libraries](../libs/), [reference XML examples](../examples/), and [Lua tools](../lua/) are legacy material. The econometrics result applies to its own check suite and setup.
- See [engineering notes and workarounds](engineering-notes.md) for the Leontief and Gomory debugging cases, and the [Russian-language archive](archive/ru/README.md) for the original notes.
