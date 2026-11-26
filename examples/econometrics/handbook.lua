-- CARDS and BITMAPS are included at build time.
local sections = {
    {id = "theory", title = "Теория"},
    {id = "practice", title = "Практика"},
    {id = "guide", title = "Как решать"},
}
local sectionTitles = {}
for i, item in ipairs(sections) do sectionTitles[i] = item.title end
local sectionHint = "← → / Tab  "..table.concat(sectionTitles, " · ")
local section, query, selected, open, offset = 1, "", 1, false, 0
local matches, lines, lastWidth, maxOffset, pageSize = {}, {}, 0, 0, 6
local examples, copyIndex = {}, 0
local helping, cardOffset = false, 0
local libraryTopics = {
    krdiag = "диагностика регрессии",
    krextra = "регрессия, ошибки и тесты",
    krroc = "ROC, AUC и индекс Джини",
    krsys = "системы уравнений и 2МНК",
}
local charPattern = "[%z\1-\127\194-\244][\128-\191]*"
local glyphs = {}
local step = 16

-- Cache rectangles for each glyph, merging runs shared by consecutive rows.
for ch, bitmap in pairs(BITMAPS) do
    local glyph = {advance = 4}
    local previous = {}
    for y = 0, 13 do
        local mask = tonumber(bitmap:sub(2*y+1, 2*y+2), 16)
        local row, start = {}, nil
        for x = 0, 8 do
            local bit = 128 / 2^x
            if x < 8 and mask >= bit then
                mask = mask - bit
                start = start or x
            elseif start then
                local width = x - start
                local key = start*8 + width
                local rect = previous[key]
                if rect then
                    rect[4] = rect[4] + 1
                else
                    rect = {start, y, width, 1}
                    glyph[#glyph+1] = rect
                end
                row[key] = rect
                glyph.advance = math.max(glyph.advance, x+1)
                start = nil
            end
        end
        previous = row
    end
    glyphs[ch] = glyph
end

local function textWidth(s)
    local width = 0
    for ch in s:gmatch(charPattern) do
        width = width + (glyphs[ch] or glyphs["?"]).advance
    end
    return width
end

local function drawText(gc, s, x, y)
    for ch in s:gmatch(charPattern) do
        local glyph = glyphs[ch] or glyphs["?"]
        for _, rect in ipairs(glyph) do
            gc:fillRect(x+rect[1], y+rect[2], rect[3], rect[4])
        end
        x = x + glyph.advance
    end
end

local upper, lower = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ", "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
local latin = {"a", "b", "v", "g", "d", "e", "e", "zh", "z", "i", "i", "k", "l", "m", "n", "o", "p",
               "r", "s", "t", "u", "f", "h", "c", "ch", "sh", "sch", "", "y", "", "e", "iu", "ia"}
local translit = {}
for _, alphabet in ipairs({upper, lower}) do
    local i = 0
    for ch in alphabet:gmatch(charPattern) do
        i = i + 1
        translit[ch] = latin[i]
    end
end

local function spelling(s)
    return (s:gsub("['`]", ""):gsub("’", "")
        :gsub("shch", "sch"):gsub("kh", "h"):gsub("ts", "c")
        :gsub("[yj]o", "e"):gsub("[yj]u", "iu"):gsub("[yj]a", "ia")
        :gsub("j", "i"):gsub("([aeiouy])y", "%1i"):gsub("yi%f[^a-z]", "ii"))
end

local function indexText(s)
    -- Fold Cyrillic once. ASCII tags and calculator calls retain their spelling.
    return (s:lower():gsub("[\128-\255]+", function(part)
        return spelling((part:gsub(charPattern, translit)))
    end))
end

for i, card in ipairs(CARDS) do
    local title, tags = indexText(card.title), indexText(card.tags)
    card.index = title.."\n"..tags.."\n"..indexText(card.body)
    card.titleEnd, card.tagsEnd = #title, #title + #tags + 1
    card.order = i
end

local function searchRank(card, terms)
    local rank, titleWeight = 0, #terms + 1
    for _, term in ipairs(terms) do
        local at = card.index:find(term[1], 1, true)
        if term[2] and (not at or at > card.titleEnd) then
            local alias = card.index:find(term[2], 1, true)
            if alias and (not at or alias < at) then at = alias end
        end
        if not at then return nil end
        if at <= card.titleEnd then
            rank = rank + titleWeight
        elseif at <= card.tagsEnd then
            rank = rank + 1
        end
    end
    return rank
end

local function refresh()
    matches, selected, offset, open, helping = {}, 1, 0, false, false
    local terms = {}
    local sectionId = sections[section].id
    local input = query:gsub("[-/]", " "):gsub("–", " "):gsub("—", " ")
    for token in input:gmatch("%S+") do
        local exact = indexText(token)
        if exact == "" then exact = token end
        local alias = spelling(exact)
        terms[#terms+1] = {exact, alias ~= exact and alias ~= "" and alias or nil}
    end
    for _, card in ipairs(CARDS) do
        if card.section == sectionId then
            local rank = searchRank(card, terms)
            if rank then
                card.rank = rank
                matches[#matches+1] = card
            end
        end
    end
    if #terms > 0 then
        table.sort(matches, function(a, b)
            if a.rank == b.rank then return a.order < b.order end
            return a.rank > b.rank
        end)
    end
end
refresh()

local function wrap(txt, width)
    local result = {}
    local spaceWidth = textWidth(" ")
    for paragraph in (txt.."\n"):gmatch("(.-)\n") do
        local line, used = "", 0
        for word in paragraph:gmatch("%S+") do
            local wordWidth = textWidth(word)
            if used > 0 and used + spaceWidth + wordWidth <= width then
                line = line.." "..word
                used = used + spaceWidth + wordWidth
            else
                if line ~= "" then result[#result+1] = line end
                if wordWidth <= width then
                    line, used = word, wordWidth
                else
                    line, used = "", 0
                    for ch in word:gmatch(charPattern) do
                        local advance = (glyphs[ch] or glyphs["?"]).advance
                        if used > 0 and used + advance > width then
                            result[#result+1] = line
                            line, used = "", 0
                        end
                        line = line..ch
                        used = used + advance
                    end
                end
            end
        end
        result[#result+1] = line
    end
    return result
end

local function fit(s, width)
    if textWidth(s) <= width then return s end
    local result, used = "", textWidth("…")
    if used > width then return "" end
    for ch in s:gmatch(charPattern) do
        local advance = (glyphs[ch] or glyphs["?"]).advance
        if used + advance > width then break end
        result = result..ch
        used = used + advance
    end
    return result.."…"
end

local function redraw() platform.window:invalidate() end

local function toggleHelp()
    if helping then offset = cardOffset else cardOffset, offset = offset, 0 end
    helping, lastWidth = not helping, -1
    redraw()
end

local function helpText()
    local library, name = examples[math.max(1, copyIndex)]:match("^(%a+)\\(%w+)")
    local topic = libraryTopics[library]
    return "Слева от \\ — библиотека "..library..".\n"
        ..(topic and "Раздел — "..topic..".\n" or "")
        .."Справа от \\ — функция "..name..".\n\n"
        .."В карточке нажмите C.\n"
        .."Calculator → Ctrl+V → Enter\n"
        .."Перед Enter замените шаблоны своими данными."
end

function on.paint(gc)
    local w,h = platform.window:width(),platform.window:height()
    local item = matches[selected]
    gc:setColorRGB(255,255,255); gc:fillRect(0,0,w,h)
    gc:setColorRGB(26,58,78); gc:fillRect(0,0,w,22)
    gc:setColorRGB(255,255,255)
    local label = sections[section].title
    local title = helping and "Как выполнить вызов" or (open and item.title or label.."  ·  "..#matches)
    drawText(gc, fit(title, w-10), 5, 4)
    gc:setColorRGB(16,34,43)
    if open then
        if lastWidth ~= w then
            local body
            if helping then
                body = helpText()
            else
                local heading = item.scope
                if textWidth(item.title)>w-16 then heading = heading.." · "..item.title end
                body = heading.."\n"..item.body
            end
            lines = wrap(body, w-12)
            lastWidth = w
        end
        local footerHeight = (#examples>0 and not helping) and step or 0
        pageSize = math.max(1,math.floor((h-42-footerHeight)/step))
        maxOffset = math.max(0,#lines-pageSize)
        offset = math.max(0,math.min(maxOffset,offset))
        for j=1,pageSize do
            local line = lines[j+offset]
            if line then drawText(gc, line, 5, 23+(j-1)*step) end
        end
    else
        drawText(gc, fit("Поиск: "..query, w-10), 5, 23)
        local firstY, footerY = 25+step, h-15-step
        pageSize = math.max(1,math.floor((footerY-firstY)/step))
        local first = math.max(1,selected-pageSize+1)
        for j=first,math.min(#matches,first+pageSize-1) do
            local y = firstY+(j-first)*step
            if j==selected then gc:setColorRGB(221,238,242);gc:fillRect(0,y,w,step) end
            gc:setColorRGB(16,34,43)
            drawText(gc, fit(matches[j].title, w-10), 5, y+1)
        end
        if #matches==0 then drawText(gc, fit("Совпадений нет", w-10), 5, 26+step) end
    end
    gc:setColorRGB(45,73,84)
    local hint = open and ("← → листать   "..(offset+1).."/"..#lines)
                      or "↑ ↓ выбор   Enter открыть"
    if helping then
        hint = "Esc / H назад   "..hint
    elseif open and #examples>0 then
        drawText(gc, fit("H помощь   C копия   Esc назад", w-8), 4, h-15-step)
        if copyIndex>0 then
            hint = "Скопировано "..copyIndex.."/"..#examples.."  "..examples[copyIndex]
        end
    elseif open then
        hint = "Esc назад   "..hint
    else
        drawText(gc, fit(sectionHint, w-8), 4, h-15-step)
    end
    drawText(gc, fit(hint, w-8), 4, h-15)
end

local function switchSection(delta)
    section = (section-1+delta)%#sections+1
    refresh(); redraw()
end
function on.tabKey()
    switchSection(1)
end
function on.charIn(c)
    local key = c:lower()
    if open and key=="h" and #examples>0 then
        toggleHelp()
    elseif open and not helping and key=="c" and #examples>0 then
        copyIndex = copyIndex % #examples + 1
        clipboard.addText(examples[copyIndex])
        redraw()
    elseif not open and #query<128 then query=query..c; refresh(); redraw() end
end
function on.backspaceKey()
    if not open then query = query:gsub(charPattern.."$",""); refresh(); redraw() end
end
function on.enterKey()
    if open or not matches[selected] then return end
    open=true; offset=0; lastWidth=-1; examples={}; copyIndex=0
    for call in matches[selected].body:gmatch("kr%a+\\%w+%b()") do
        examples[#examples+1] = call
    end
    redraw()
end
function on.escapeKey()
    if helping then toggleHelp(); return end
    if open then open=false else query="";refresh() end
    redraw()
end
function on.arrowKey(key)
    if open then
        local delta = ({up=-1,down=1,left=-pageSize,right=pageSize})[key] or 0
        offset=math.max(0,math.min(maxOffset,offset+delta))
    else
        if key=="left" then switchSection(-1); return end
        if key=="right" then switchSection(1); return end
        selected=math.max(1,math.min(#matches,selected+(key=="down" and 1 or key=="up" and -1 or 0)))
    end
    redraw()
end
