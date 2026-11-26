-- Exercise TI event handlers under Lua 5.1 at common handheld viewport sizes.
local width, height = 318, 212
local firstResultY = 42
local pixels, ink, highlightedY
local testsDir = arg[0]:match("^.*/") or "./"
local bitmaps = dofile(testsDir.."../font.lua")
local charPattern = "[%z\1-\127\194-\244][\128-\191]*"
on = {}
local copied
clipboard = {addText=function(s) copied=s end}
platform = {window={
    width=function() return width end, height=function() return height end,
    invalidate=function() end
}}
local gc = {
    setColorRGB=function(self,r,g,b) ink=('%d,%d,%d'):format(r,g,b) end,
    fillRect=function(self,x,y,w,h)
        assert(x>=0 and y>=0 and w>0 and h>0 and x+w<=width and y+h<=height)
        if ink=="221,238,242" then highlightedY=y+1 end
        if x~=0 then
            for dy=y,y+h-1 do
                for dx=x,x+w-1 do pixels[dy*width+dx]=ink end
            end
        end
    end
}
dofile(assert(arg[1],"expected compiled handbook Lua path"))
local function paint()
    pixels, highlightedY={}, nil
    on.paint(gc)
end

local function expectSameScreen(previous)
    paint()
    for position, color in pairs(previous) do assert(pixels[position]==color) end
    for position, color in pairs(pixels) do assert(previous[position]==color) end
end

local function raster(value)
    local points, width = {}, 0
    for char in value:gmatch(charPattern) do
        local glyph, advance = assert(bitmaps[char], char), 4
        for row=0,13 do
            local mask = tonumber(glyph:sub(2*row+1,2*row+2),16)
            for col=0,7 do
                if math.floor(mask / 2^(7-col))%2==1 then
                    points[#points+1]={width+col,row}
                    advance=math.max(advance,col+2)
                end
            end
        end
        width=width+advance
    end
    return points, width
end

local function shows(value, rowY)
    local points, textWidth = raster(value)
    local first = points[1]
    for y=rowY or 0,rowY or height-14 do
        for x=0,width-textWidth do
            local color=pixels[(y+first[2])*width+x+first[1]]
            if color then
                local hit=true
                for _,point in ipairs(points) do
                    if pixels[(y+point[2])*width+x+point[1]]~=color then
                        hit=false
                        break
                    end
                end
                if hit then return true end
            end
        end
    end
    return false
end

local function has(value, rowY)
    paint()
    assert(shows(value,rowY), "Missing rasterized text: "..value)
end

local function selectResult(title, kind)
    for _=1,100 do
        paint()
        if not highlightedY then break end
        if shows(title,highlightedY) and (not kind or shows(kind,highlightedY)) then return end
        on.arrowKey("down")
    end
    error("Missing search result: "..title)
end

local function expectResult(query, title, kind)
    on.charIn(query)
    local ok, message = pcall(selectResult, title, kind)
    assert(ok, query.." | "..tostring(message))
    on.escapeKey()
end

has("Теория", 4)
has("← → / Tab", height-31)
has("Теория · Практика · Как решать", height-31)
has("↑ ↓ выбор   Enter открыть", height-15)
for _, query in ipairs({"uaita", "UAYTA", "uayta khi-kvadrat", "уайта хи-квадрат"}) do
    expectResult(query, "Тест Уайта", "Теория")
end
for _, query in ipairs({"smeschenie", "smeshchenie", "смещение"}) do
    expectResult(query, "Смещение и состоятельность")
end
expectResult("geteroskedastichnost", "Условная и безусловная")
for _, query in ipairs({"dzhini trapetsiy", "dzhini trapecii", "AUC GINI"}) do
    expectResult(query, "Площадь и индекс Джини")
end
for _, query in ipairs({"Diki-Fullera", "dik fullera", "Dickey–Fuller", "diki styudenta", "diki stiudenta", "ADF unit root"}) do
    expectResult(query, "Дики — Фуллер и ADF")
end
for _, query in ipairs({"метод рядов", "metod ryadov", "metod riadov"}) do
    expectResult(query, "Метод рядов")
end
expectResult("doveritelnyy OLS", "МНК, SE и доверительный")
expectResult("уайта LM", "Тест Уайта", "Теория")
expectResult("2SLS algoritm", "Алгоритм 2МНК")
expectResult("HC3", "Робастные ошибки HC0–HC3")
on.charIn("ДЖИНИ площадь трапеция")
selectResult("Площадь и индекс Джини")
on.enterKey()
has("Площадь и индекс Джини", 4)
on.arrowKey("right")
paint()
on.escapeKey()
on.escapeKey()

for ch in ("uayta"):gmatch(".") do on.charIn(ch) end
has("Общий поиск", 4)
has("Поиск: uayta", 23)
has("Фильтр · Все", height-31)
local allResults = pixels
on.escapeKey()
on.tabKey()
has("Практика", 4)
on.charIn("uayta")
expectSameScreen(allResults)
on.escapeKey()
on.arrowKey("right")
has("Как решать", 4)
on.charIn("uayta")
expectSameScreen(allResults)
on.arrowKey("down")
on.arrowKey("down")
paint()
local selectedResults, selectedY = pixels, highlightedY
assert(selectedY and selectedY>firstResultY)
on.enterKey()
has("Esc назад")
on.escapeKey()
expectSameScreen(selectedResults)
assert(highlightedY==selectedY)

on.tabKey()
has("Фильтр · Теория", height-31)
has("Теория", firstResultY)
on.arrowKey("right")
has("Фильтр · Решатели", height-31)
has("Решатель", firstResultY)
on.tabKey()
has("Фильтр · Как решать", height-31)
has("Тест Уайта по шагам", firstResultY)
has("Разбор", firstResultY)
on.arrowKey("left")
has("Фильтр · Решатели", height-31)
on.arrowKey("left")
on.arrowKey("left")
expectSameScreen(allResults)
on.tabKey()
on.charIn("x")
has("Фильтр · Все", height-31)
on.backspaceKey()
expectSameScreen(allResults)
on.escapeKey()
has("Как решать", 4)
on.arrowKey("left")
has("Практика", 4)

on.charIn("absentkeyword")
has("Совпадений нет")
on.enterKey()
has("Общий поиск", 4)
on.escapeKey()
on.charIn("аб")
on.backspaceKey()
has("Поиск: а")
on.backspaceKey()
has("Практика", 4)
on.charIn("Ёж Φαβγ χ² ᵀᵢ₀₁₋ₜⱼ −≈≠≥")
has("Ёж Φαβγ χ² ᵀᵢ₀₁₋ₜⱼ −≈≠≥")
on.escapeKey()
local walkthrough = "Серии остатков: от знаков к выводу"
expectResult("runs", "Серии остатков", "Разбор")
expectResult("серии остатков", "Серии остатков", "Разбор")
on.charIn("serii ostatkov")
selectResult("Серии остатков", "Разбор")
on.enterKey()
has(walkthrough, 4)
on.escapeKey(); on.escapeKey()
width=320
expectResult("rexact", "Точный критерий серий")
on.charIn("krdiag\\rexact(")
has("Точный критерий серий", firstResultY)
has("Решатель", firstResultY)
on.enterKey()
has("H помощь   C копия", height-31)
on.charIn("h")
has("Как выполнить вызов", 4)
has("Слева от \\ — библиотека krdiag.")
has("Раздел — диагностика регрессии.")
has("Справа от \\ — функция rexact.")
has("Calculator → Ctrl+V → Enter")
has("Перед Enter замените шаблоны")
has("Esc / H назад", height-15)
on.escapeKey()
has("Точный критерий серий", 4)
on.charIn("c")
assert(copied and copied:match("^krdiag\\rexact%b()$") and copied:find("%d"),copied)
has("Скопировано 1/", height-15)
has("H помощь   C копия", height-31)
on.escapeKey(); on.escapeKey()
on.charIn("KREXTRA\\OLS(")
has("Решатель", firstResultY)
on.enterKey()
on.charIn("C")
assert(copied and copied:match("^krextra\\ols%b()$") and copied:find("%d"),copied)
width,height=245,155
paint()
on.arrowKey("right")
paint()
local scrolledCard = pixels
on.charIn("H")
has("Слева от \\ — библиотека krextra.")
has("Справа от \\ — функция ols.")
on.arrowKey("right")
has("Перед Enter замените шаблоны")
on.charIn("h")
expectSameScreen(scrolledCard)
for i=1,25 do on.arrowKey("right"); paint() end
on.arrowKey("left"); paint()
on.escapeKey(); on.escapeKey()
has("Теория · Практика · Как решать", height-31)
print("PASS: bitmap Cyrillic, math and arrows, ranked search, three-section navigation, copy, help, pagination and resize")
