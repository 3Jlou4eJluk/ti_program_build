-- Exercise TI event handlers under Lua 5.1 at common handheld viewport sizes.
local width, height = 318, 212
local firstResultY = 42
local pixels, ink
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
        if x~=0 then
            for dy=y,y+h-1 do
                for dx=x,x+w-1 do pixels[dy*width+dx]=ink end
            end
        end
    end
}
dofile(assert(arg[1],"expected compiled handbook Lua path"))
local function paint()
    pixels={}
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

local function has(value, rowY)
    paint()
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
                if hit then return end
            end
        end
    end
    error("Missing rasterized text: "..value)
end

local function expectFirstResult(query, firstTitle)
    on.charIn(query)
    local ok, message = pcall(has, firstTitle, firstResultY)
    assert(ok, query.." | "..tostring(message))
    on.escapeKey()
end

has("Теория")
has("↑ ↓")
for _, query in ipairs({"uaita", "UAYTA", "uayta khi-kvadrat", "уайта хи-квадрат"}) do
    expectFirstResult(query, "Тест Уайта")
end
for _, query in ipairs({"smeschenie", "smeshchenie", "смещение"}) do
    expectFirstResult(query, "Смещение и состоятельность")
end
expectFirstResult("geteroskedastichnost", "Условная и безусловная")
for _, query in ipairs({"dzhini trapetsiy", "dzhini trapecii", "AUC GINI"}) do
    expectFirstResult(query, "Площадь и индекс Джини")
end
for _, query in ipairs({"Diki-Fullera", "dik fullera", "Dickey–Fuller", "diki styudenta", "diki stiudenta", "ADF unit root"}) do
    expectFirstResult(query, "Дики — Фуллер и ADF")
end
for _, query in ipairs({"метод рядов", "metod ryadov", "metod riadov"}) do
    expectFirstResult(query, "Метод рядов")
end
expectFirstResult("doveritelnyy OLS", "МНК, SE и доверительный")
expectFirstResult("уайта LM", "Тест Уайта")
expectFirstResult("2SLS algoritm", "Алгоритм 2МНК")
expectFirstResult("HC3", "Робастные ошибки HC0–HC3")
on.charIn("ДЖИНИ площадь трапеция")
has("Джини")
on.enterKey()
has("AUC")
on.arrowKey("right")
paint()
on.escapeKey()
on.escapeKey()
on.tabKey()
has("Практика")
on.charIn("roc")
has("Координаты ROC по прогнозам", firstResultY)
on.charIn("absentkeyword")
has("Совпадений нет")
on.escapeKey()
on.charIn("аб")
on.backspaceKey()
has("Поиск: а")
on.escapeKey()
on.charIn("Ёж Φαβγ χ² ᵀᵢ₀₁₋ₜⱼ −≈≠≥")
has("Ёж Φαβγ χ² ᵀᵢ₀₁₋ₜⱼ −≈≠≥")
on.escapeKey()
expectFirstResult("raschyot lm lineynoy", "Расчёт LM Уайта")
expectFirstResult("raschet lm lineinoi", "Расчёт LM Уайта")
on.tabKey()
for ch in ("uayta"):gmatch(".") do on.charIn(ch) end
has("Тест Уайта", firstResultY)
on.tabKey()
has("Поиск: uayta")
has("Расчёт LM Уайта", firstResultY)
on.enterKey()
has("Расчёт LM Уайта", 4)
on.charIn("c")
assert(copied=="krdiag\\white(40,0.25,5,11.070)",copied)
on.escapeKey(); on.escapeKey()
width=320
expectFirstResult("rexact", "Точный критерий серий")
on.charIn("krdiag\\rexact(")
has("Точный критерий серий", firstResultY)
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
assert(copied=="krdiag\\rexact({-2,-1,3,4},0.05,0)",copied)
has("Скопировано 1/1", height-15)
has("H помощь   C копия", height-31)
on.escapeKey(); on.escapeKey()
on.charIn("KREXTRA\\OLS(")
has("МНК по данным. Общий пример", firstResultY)
on.enterKey()
on.charIn("C")
assert(copied=="krextra\\ols(y,x)",copied)
on.charIn("c")
assert(copied=="krextra\\resid(y,x)",copied)
width,height=245,155
paint()
on.arrowKey("right")
paint()
local scrolledCard = pixels
on.charIn("H")
has("Слева от \\ — библиотека krextra.")
has("Справа от \\ — функция resid.")
on.arrowKey("right")
has("Перед Enter замените шаблоны")
on.charIn("h")
expectSameScreen(scrolledCard)
on.charIn("c")
assert(copied=="krextra\\olssum(y,x)",copied)
for i=1,25 do on.arrowKey("right"); paint() end
on.arrowKey("left"); paint()
on.escapeKey(); on.escapeKey()
print("PASS: bitmap Cyrillic, math and arrows, ranked search, Tab, copy, help, pagination and resize")
