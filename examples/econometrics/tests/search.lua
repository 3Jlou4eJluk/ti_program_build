local testsDir = arg[0]:match("^.*/") or "./"
local search = dofile(testsDir.."../search.lua")

local function card(title, tags, body, section)
    return {section = section or "theory", title = title, tags = tags, body = body}
end

local function expect(index, query, ...)
    local actual, expected = index:find(query), {...}
    assert(#actual == #expected, query..": expected "..#expected.." results, got "..#actual)
    for i, item in ipairs(expected) do
        assert(actual[i] == item, query..": expected "..item.title..", got "..actual[i].title)
    end
end

local title = card("Серии остатков", "", "Краткая справка.", "guide")
local tags = card("Точный критерий", "rexact krdiag\\rexact серии остатков",
                  ("Пояснение. "):rep(25).."Команда krdiag\\rexact(e,a,0).", "practice")
local reference = card("krdiag.tns", "MyLib API", "Упорядоченные серии остатков. krdiag\\rexact(e,a,0).", "file")
local index = search.build({reference, tags, title})
expect(index, "serii ostatkov", title, tags, reference)
expect(index, "ОСТАТКОВ СЕРИИ", title, tags, reference)
expect(index, "СЕРИИ serii ostatk", title, tags, reference)
expect(index, "SErii ostatk", title, tags, reference)
expect(index, "krdiag.tns", reference)
expect(index, "KRDIAG\\REXACT(", tags, reference)
expect(index, "REXACT", tags, reference)
expect(index, "объясните серии остатков подробно", title, tags, reference)
expect(index, "!!! – 🙂 ,")
local otherLibrary = card("Чужая команда", "rexact krother\\rexact", "", "practice")
expect(search.build({otherLibrary, reference, tags}), "KRDIAG\\REXACT", tags, reference)

local white = card("Тест Уайта", "", "Гетероскедастичность, χ² и расчёт χ-квадрат.")
local bias = card("Смещение", "", "Трапеций, доверительный интервал и Юлия.")
local aliases = search.build({white, bias})
for _, query in ipairs({"уайта", "uayta", "UAYTA", "uaita", "uayta khi-kvadrat",
                       "geteroskedastichnost", "raschyot"}) do
    expect(aliases, query, white)
end
for _, query in ipairs({"смещение", "smeschenie", "smeshchenie", "trapetsiy",
                       "trapecii", "doveritelnyy", "juliia"}) do
    expect(aliases, query, bias)
end

local short = card("Кратко", "", "focus note")
local long = card("Подробно", "", "focus "..("note "):rep(100))
expect(search.build({long, short}), "focus", short, long)

local common = card("Первый", "", "common common common common rare note")
local rare = card("Второй", "", "common rare rare rare rare note")
local filler = card("Третий", "", "common unrelated note note note note")
expect(search.build({common, rare, filler}), "common rare", rare, common, filler)

local repeated = card("Первый", "", ("alpha "):rep(9).."beta note")
local balanced = card("Второй", "", ("alpha "):rep(3)..("beta "):rep(3)..("note "):rep(5))
expect(search.build({repeated, balanced}), "alpha beta", balanced, repeated)

local first = card("Первый", "ёж ezh", "seed")
local second = card("Второй", "ёж ezh", "seed")
local tied = search.build({first, second})
expect(tied, "ёж ezh", first, second)
expect(tied, "seed absent", first, second)
expect(tied, "absent")
expect(tied, "")

print("PASS: BM25 field ranking, length and TF normalization, IDF, Cyrillic, transliteration and calculator names")
