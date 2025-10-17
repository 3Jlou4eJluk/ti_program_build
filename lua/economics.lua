-- Economics Calculator for TI-Nspire
-- GDP + CPI + Inflation

-- Global state
local state = {
    screen = "menu",
    selectedMenu = 1,
    selectedField = 1,
    inputs = {},
    result = nil,
    editBuffer = "",
    itemsOffset = 0
}

-- Screen dimensions
local sw, sh = 318, 212

-- Main menu
local mainMenu = {
    {title = "1. GDP & Deflator", screen = "gdp_menu"},
    {title = "2. CPI & Inflation", screen = "cpi_menu"}
}

-- GDP submenu
local gdpMenu = {
    {title = "1. GDP (nom. & real)", screen = "gdp_calc_items"},
    {title = "2. GDP Deflator", screen = "gdp_deflator"},
    {title = "3. Real GDP", screen = "gdp_real"},
    {title = "<- Back", screen = "menu"}
}

-- CPI submenu
local cpiMenu = {
    {title = "1. CPI (Laspeyres)", screen = "cpi_laspeyres_items"},
    {title = "2. Inflation", screen = "cpi_inflation"},
    {title = "<- Back", screen = "menu"}
}

--=====================================
-- GDP/CPI CALCULATIONS
--=====================================

local function calculateGDP(items)
    local nomGDP = 0
    local realGDP = 0

    for _, item in ipairs(items) do
        nomGDP = nomGDP + (item.pt * item.qt)
        realGDP = realGDP + (item.p0 * item.qt)
    end

    return nomGDP, realGDP
end

local function calculateDeflator(nomGDP, realGDP)
    if realGDP == 0 then return nil end
    return (nomGDP / realGDP) * 100
end

local function calculateLaspeyres(quantities, prices_base, prices_current)
    local sum_base, sum_current = 0, 0
    for i = 1, #quantities do
        sum_base = sum_base + (prices_base[i] * quantities[i])
        sum_current = sum_current + (prices_current[i] * quantities[i])
    end
    if sum_base == 0 then return nil, nil, nil end
    local cpi = (sum_current / sum_base) * 100
    return cpi, sum_base, sum_current
end

local function calculateInflation(cpi_current, cpi_previous)
    if cpi_previous == 0 then return nil end
    return ((cpi_current - cpi_previous) / cpi_previous) * 100
end

--=====================================
-- UI HELPERS
--=====================================

local function round(num, decimals)
    local mult = 10^(decimals or 2)
    return math.floor(num * mult + 0.5) / mult
end

local function drawText(gc, text, x, y, size, bold)
    gc:setFont("sansserif", bold and "b" or "r", size or 10)
    gc:setColorRGB(0, 0, 0)
    gc:drawString(text, x, y, "top")
end

local function drawTitle(gc, text)
    drawText(gc, text, 5, 5, 11, true)
    gc:drawLine(5, 20, sw - 5, 20)
end

local function drawInputField(gc, label, value, x, y, selected)
    drawText(gc, label .. ":", x, y, 9)
    local inputY = y + 12
    if selected then
        gc:setColorRGB(200, 220, 255)
        gc:fillRect(x, inputY, 100, 15)
    end
    gc:setColorRGB(0, 0, 0)
    gc:drawRect(x, inputY, 100, 15)
    local displayValue = (selected and state.editBuffer ~= "") and state.editBuffer or tostring(value or "")
    drawText(gc, displayValue, x + 3, inputY, 9)
end

local function drawMenu(gc, menuItems, selected, title)
    drawTitle(gc, title or "Menu")
    local y = 30
    for i, item in ipairs(menuItems) do
        if i == selected then
            gc:setColorRGB(200, 220, 255)
            gc:fillRect(5, y - 2, sw - 10, 16)
        end
        drawText(gc, item.title, 10, y, 9)
        y = y + 18
    end
    drawText(gc, "^v select, Enter open, ESC back", 5, sh - 15, 7)
end

local function drawResult(gc, lines, x, y, w, h)
    gc:setColorRGB(240, 255, 240)
    gc:fillRect(x, y, w, h)
    gc:setColorRGB(0, 0, 0)
    gc:drawRect(x, y, w, h)

    local ly = y + 5
    for _, line in ipairs(lines) do
        drawText(gc, line, x + 5, ly, 9)
        ly = ly + 14
    end
end

--=====================================
-- SCREENS: GDP
--=====================================

local function renderGDPCalcItems(gc)
    drawTitle(gc, "GDP - Number of Items")

    if not state.inputs.gdp_items_count then
        state.inputs.gdp_items_count = 2
    end

    drawText(gc, "Enter number of items (default: 2)", 10, 50, 9)
    drawText(gc, "Max: 5 items", 10, 65, 8)
    drawInputField(gc, "Items", state.inputs.gdp_items_count, 10, 90, true)

    drawText(gc, "Enter confirm, ESC back", 5, sh - 15, 7)
end

local function renderGDPCalc(gc)
    drawTitle(gc, "GDP (nominal & real)")

    if not state.inputs.gdp then
        state.inputs.gdp = {
            n = 2,
            items = {{p0=0, pt=0, qt=0}, {p0=0, pt=0, qt=0}}
        }
    end

    local inp = state.inputs.gdp
    local y = 30

    drawText(gc, "GDP_n = SUM(pt*qt), GDP_r = SUM(p0*qt)", 10, y, 8)
    y = y + 13
    drawText(gc, "p0=base price, pt=curr price, qt=curr qty", 10, y, 7)
    y = y + 15

    local maxShow = 3
    local startItem = state.itemsOffset + 1
    local endItem = math.min(startItem + maxShow - 1, inp.n)

    for i = startItem, endItem do
        local displayIdx = i - state.itemsOffset
        drawText(gc, "Item " .. i .. ":", 10, y, 9, true)
        y = y + 15

        drawInputField(gc, "p0", inp.items[i].p0, 10, y, state.selectedField == (i-1)*3 + 1)
        drawInputField(gc, "pt", inp.items[i].pt, 120, y, state.selectedField == (i-1)*3 + 2)
        drawInputField(gc, "qt", inp.items[i].qt, 230, y, state.selectedField == (i-1)*3 + 3)
        y = y + 35
    end

    if inp.n > maxShow then
        drawText(gc, "Items " .. startItem .. "-" .. endItem .. " of " .. inp.n .. " (<> scroll)", 10, y, 7)
    end

    drawText(gc, "Tab/^v nav, Enter calc, ESC back", 5, sh - 15, 7)

    if state.result then
        local lines = {
            "GDP nom: " .. round(state.result.nomGDP, 2),
            "GDP real: " .. round(state.result.realGDP, 2)
        }
        if state.result.deflator then
            table.insert(lines, "Deflator: " .. round(state.result.deflator, 2) .. "%")
        end
        drawResult(gc, lines, 10, 155, sw - 20, 50)
    end
end

local function calculateGDPCalc()
    local inp = state.inputs.gdp
    if not inp then return end

    local nomGDP, realGDP = calculateGDP(inp.items)
    local deflator = calculateDeflator(nomGDP, realGDP)

    state.result = {
        nomGDP = nomGDP,
        realGDP = realGDP,
        deflator = deflator
    }
end

local function renderGDPDeflator(gc)
    drawTitle(gc, "GDP Deflator")

    if not state.inputs.gdp_deflator then
        state.inputs.gdp_deflator = {nominal = 0, real = 0}
    end

    local inp = state.inputs.gdp_deflator

    drawText(gc, "Deflator = (GDP_nominal / GDP_real) * 100", 10, 30, 8)
    drawText(gc, "Measures price level changes in economy", 10, 43, 7)

    drawInputField(gc, "GDP nominal", inp.nominal, 10, 65, state.selectedField == 1)
    drawInputField(gc, "GDP real", inp.real, 10, 105, state.selectedField == 2)

    drawText(gc, "Tab/^v nav, Enter calc, ESC back", 5, sh - 15, 7)

    if state.result then
        drawResult(gc, {
            "GDP Deflator:",
            round(state.result, 2) .. "%"
        }, 10, 150, sw - 20, 40)
    end
end

local function calculateGDPDeflator()
    local inp = state.inputs.gdp_deflator
    if not inp then return end
    state.result = calculateDeflator(inp.nominal, inp.real)
end

local function renderRealGDP(gc)
    drawTitle(gc, "Real GDP")

    if not state.inputs.real_gdp then
        state.inputs.real_gdp = {nominal = 0, deflator = 100}
    end

    local inp = state.inputs.real_gdp

    drawText(gc, "GDP_real = (GDP_nominal / Deflator) * 100", 10, 30, 8)
    drawText(gc, "GDP adjusted for inflation", 10, 43, 7)

    drawInputField(gc, "GDP nominal", inp.nominal, 10, 65, state.selectedField == 1)
    drawInputField(gc, "Deflator (%)", inp.deflator, 10, 105, state.selectedField == 2)

    drawText(gc, "Tab/^v nav, Enter calc, ESC back", 5, sh - 15, 7)

    if state.result then
        drawResult(gc, {
            "Real GDP:",
            round(state.result, 2)
        }, 10, 150, sw - 20, 40)
    end
end

local function calculateRealGDP()
    local inp = state.inputs.real_gdp
    if not inp or inp.deflator == 0 then return end
    state.result = (inp.nominal / inp.deflator) * 100
end

--=====================================
-- SCREENS: CPI
--=====================================

local function renderLaspeyresItems(gc)
    drawTitle(gc, "CPI Laspeyres - Number of Items")

    if not state.inputs.laspeyres_items_count then
        state.inputs.laspeyres_items_count = 2
    end

    drawText(gc, "Enter number of items (default: 2)", 10, 50, 9)
    drawText(gc, "Max: 5 items", 10, 65, 8)
    drawInputField(gc, "Items", state.inputs.laspeyres_items_count, 10, 90, true)

    drawText(gc, "Enter confirm, ESC back", 5, sh - 15, 7)
end

local function renderLaspeyresBasket(gc)
    drawTitle(gc, "CPI Laspeyres - STEP 1: Basket")

    if not state.inputs.laspeyres then
        state.inputs.laspeyres = {n = 2, quantities = {0, 0}}
    end

    local inp = state.inputs.laspeyres
    local y = 30

    drawText(gc, "L = (SUM(pt*q) / SUM(p0*q)) * 100", 10, y, 8)
    y = y + 13
    drawText(gc, "q - fixed basket quantities", 10, y, 7)
    y = y + 20

    drawText(gc, "Number of items: " .. inp.n, 10, y, 9, true)
    y = y + 20

    for i = 1, inp.n do
        drawInputField(gc, "Item " .. i .. " qty", inp.quantities[i], 10, y, state.selectedField == i)
        y = y + 30
    end

    drawText(gc, "^v nav, Enter next step, ESC back", 5, sh - 15, 7)
end

local function renderLaspeyresStep2(gc)
    drawTitle(gc, "CPI Laspeyres - STEP 2: Base Year Prices")

    local inp = state.inputs.laspeyres
    if not inp or not inp.prices_base then
        return
    end

    local y = 30
    drawText(gc, "Enter base year prices (p0)", 10, y, 9)
    y = y + 20

    for i = 1, inp.n do
        drawInputField(gc, "Item " .. i .. " p0", inp.prices_base[i], 10, y, state.selectedField == i)
        y = y + 30
    end

    drawText(gc, "^v nav, Enter next step, ESC back", 5, sh - 15, 7)
end

local function renderLaspeyresStep3(gc)
    drawTitle(gc, "CPI Laspeyres - STEP 3: Current Year Prices")

    local inp = state.inputs.laspeyres
    if not inp or not inp.prices_current then
        return
    end

    local y = 30
    drawText(gc, "Enter current year prices (pt)", 10, y, 9)
    y = y + 20

    for i = 1, inp.n do
        drawInputField(gc, "Item " .. i .. " pt", inp.prices_current[i], 10, y, state.selectedField == i)
        y = y + 30
    end

    drawText(gc, "^v nav, Enter calc, ESC back", 5, sh - 15, 7)

    if state.result then
        local lines = {
            "RESULT:",
            "Base basket cost: " .. round(state.result.sum_base, 2),
            "Current basket cost: " .. round(state.result.sum_current, 2),
            "CPI = " .. round(state.result.cpi, 2) .. "%",
            "Basket price rose " .. round(state.result.cpi / 100, 2) .. "x"
        }
        drawResult(gc, lines, 10, 135, sw - 20, 70)
    end
end

local function calculateLaspeyresCalc()
    local inp = state.inputs.laspeyres
    if not inp or not inp.quantities or not inp.prices_base or not inp.prices_current then
        return
    end

    local cpi, sum_base, sum_current = calculateLaspeyres(inp.quantities, inp.prices_base, inp.prices_current)
    if cpi then
        state.result = {
            cpi = cpi,
            sum_base = sum_base,
            sum_current = sum_current
        }
    end
end

local function renderInflation(gc)
    drawTitle(gc, "Inflation")

    if not state.inputs.inflation then
        state.inputs.inflation = {cpi_current = 0, cpi_previous = 0}
    end

    local inp = state.inputs.inflation

    drawText(gc, "pi = [(CPIt - CPIt-1) / CPIt-1] * 100%", 10, 30, 8)
    drawText(gc, "Rate of price change over time", 10, 43, 7)

    drawInputField(gc, "CPI current (%)", inp.cpi_current, 10, 65, state.selectedField == 1)
    drawInputField(gc, "CPI previous (%)", inp.cpi_previous, 10, 105, state.selectedField == 2)

    drawText(gc, "Tab/^v nav, Enter calc, ESC back", 5, sh - 15, 7)

    if state.result then
        local interpretation = state.result > 0 and "Inflation (price growth)" or
                             state.result < 0 and "Deflation (price drop)" or
                             "Price stability"
        drawResult(gc, {
            "Inflation: " .. round(state.result, 2) .. "%",
            interpretation
        }, 10, 150, sw - 20, 40)
    end
end

local function calculateInflationCalc()
    local inp = state.inputs.inflation
    if not inp then return end
    state.result = calculateInflation(inp.cpi_current, inp.cpi_previous)
end

--=====================================
-- MAIN RENDERING
--=====================================

function on.paint(gc)
    gc:setColorRGB(255, 255, 255)
    gc:fillRect(0, 0, sw, sh)

    if state.screen == "menu" then
        drawMenu(gc, mainMenu, state.selectedMenu, "Economics Calculator")
    elseif state.screen == "gdp_menu" then
        drawMenu(gc, gdpMenu, state.selectedMenu, "GDP & Deflator")
    elseif state.screen == "cpi_menu" then
        drawMenu(gc, cpiMenu, state.selectedMenu, "CPI & Inflation")
    elseif state.screen == "gdp_calc_items" then
        renderGDPCalcItems(gc)
    elseif state.screen == "gdp_calc" then
        renderGDPCalc(gc)
    elseif state.screen == "gdp_deflator" then
        renderGDPDeflator(gc)
    elseif state.screen == "gdp_real" then
        renderRealGDP(gc)
    elseif state.screen == "cpi_laspeyres_items" then
        renderLaspeyresItems(gc)
    elseif state.screen == "cpi_laspeyres_basket" then
        renderLaspeyresBasket(gc)
    elseif state.screen == "cpi_laspeyres_step2" then
        renderLaspeyresStep2(gc)
    elseif state.screen == "cpi_laspeyres_step3" then
        renderLaspeyresStep3(gc)
    elseif state.screen == "cpi_inflation" then
        renderInflation(gc)
    else
        drawTitle(gc, "In development")
        drawText(gc, "ESC to return", 10, 40, 9)
    end
end

--=====================================
-- EVENT HANDLERS
--=====================================

function on.resize(w, h)
    sw, sh = w, h
    platform.window:invalidate()
end

function on.arrowKey(key)
    local currentMenu = nil
    if state.screen == "menu" then currentMenu = mainMenu
    elseif state.screen == "gdp_menu" then currentMenu = gdpMenu
    elseif state.screen == "cpi_menu" then currentMenu = cpiMenu
    end

    if currentMenu then
        if key == "up" then
            state.selectedMenu = state.selectedMenu > 1 and state.selectedMenu - 1 or #currentMenu
        elseif key == "down" then
            state.selectedMenu = state.selectedMenu < #currentMenu and state.selectedMenu + 1 or 1
        end
        platform.window:invalidate()
    else
        -- Horizontal scrolling for items
        local totalItems = 0
        if state.screen == "gdp_calc" and state.inputs.gdp then
            totalItems = state.inputs.gdp.n
        end

        if totalItems > 3 and (key == "left" or key == "right") then
            if key == "left" then
                state.itemsOffset = math.max(0, state.itemsOffset - 1)
            elseif key == "right" then
                state.itemsOffset = math.min(totalItems - 3, state.itemsOffset + 1)
            end
            platform.window:invalidate()
            return
        end

        -- Field navigation
        local maxFields = 2
        if state.screen == "gdp_calc" and state.inputs.gdp then
            maxFields = state.inputs.gdp.n * 3
        elseif state.screen == "cpi_laspeyres_basket" and state.inputs.laspeyres then
            maxFields = state.inputs.laspeyres.n
        elseif state.screen == "cpi_laspeyres_step2" and state.inputs.laspeyres then
            maxFields = state.inputs.laspeyres.n
        elseif state.screen == "cpi_laspeyres_step3" and state.inputs.laspeyres then
            maxFields = state.inputs.laspeyres.n
        end

        if key == "up" then
            state.editBuffer = ""
            state.selectedField = state.selectedField > 1 and state.selectedField - 1 or maxFields
        elseif key == "down" then
            state.editBuffer = ""
            state.selectedField = state.selectedField < maxFields and state.selectedField + 1 or 1
        end
        platform.window:invalidate()
    end
end

function on.tabKey()
    state.editBuffer = ""
    on.arrowKey("down")
end

function on.enterKey()
    state.editBuffer = ""

    if state.screen == "menu" then
        state.screen = mainMenu[state.selectedMenu].screen
        state.selectedMenu = 1
        state.selectedField = 1
        state.result = nil
    elseif state.screen:find("_menu") then
        local targetScreen = nil
        if state.screen == "gdp_menu" then targetScreen = gdpMenu[state.selectedMenu].screen
        elseif state.screen == "cpi_menu" then targetScreen = cpiMenu[state.selectedMenu].screen
        end
        if targetScreen then
            state.screen = targetScreen
            state.selectedField = 1
            state.result = nil
        end
    elseif state.screen == "gdp_calc_items" then
        local n = state.inputs.gdp_items_count or 2
        if n == 0 or n > 5 then n = 2 end
        state.inputs.gdp = {n = n, items = {}}
        for i = 1, n do
            state.inputs.gdp.items[i] = {p0=0, pt=0, qt=0}
        end
        state.screen = "gdp_calc"
        state.selectedField = 1
        state.result = nil
    elseif state.screen == "cpi_laspeyres_items" then
        local n = state.inputs.laspeyres_items_count or 2
        if n == 0 or n > 5 then n = 2 end
        state.inputs.laspeyres = {n = n, quantities = {}}
        for i = 1, n do
            state.inputs.laspeyres.quantities[i] = 0
        end
        state.screen = "cpi_laspeyres_basket"
        state.selectedField = 1
        state.result = nil
    elseif state.screen == "cpi_laspeyres_basket" then
        local inp = state.inputs.laspeyres
        if inp then
            inp.prices_base = {}
            for i = 1, inp.n do
                inp.prices_base[i] = 0
            end
            state.screen = "cpi_laspeyres_step2"
            state.selectedField = 1
            state.result = nil
        end
    elseif state.screen == "cpi_laspeyres_step2" then
        local inp = state.inputs.laspeyres
        if inp then
            inp.prices_current = {}
            for i = 1, inp.n do
                inp.prices_current[i] = 0
            end
            state.screen = "cpi_laspeyres_step3"
            state.selectedField = 1
            state.result = nil
        end
    elseif state.screen == "cpi_laspeyres_step3" then
        calculateLaspeyresCalc()
    elseif state.screen == "gdp_calc" then
        calculateGDPCalc()
    elseif state.screen == "gdp_deflator" then
        calculateGDPDeflator()
    elseif state.screen == "gdp_real" then
        calculateRealGDP()
    elseif state.screen == "cpi_inflation" then
        calculateInflationCalc()
    end
    platform.window:invalidate()
end

function on.escapeKey()
    state.editBuffer = ""

    if state.screen ~= "menu" then
        if state.screen == "gdp_calc_items" then
            state.screen = "gdp_menu"
        elseif state.screen == "cpi_laspeyres_items" then
            state.screen = "cpi_menu"
        elseif state.screen == "cpi_laspeyres_basket" then
            state.screen = "cpi_laspeyres_items"
        elseif state.screen == "cpi_laspeyres_step2" then
            state.screen = "cpi_laspeyres_basket"
        elseif state.screen == "cpi_laspeyres_step3" then
            state.screen = "cpi_laspeyres_step2"
        elseif state.screen:find("gdp") then
            state.screen = state.screen == "gdp_menu" and "menu" or "gdp_menu"
        elseif state.screen:find("cpi") then
            state.screen = state.screen == "cpi_menu" and "menu" or "cpi_menu"
        else
            state.screen = "menu"
        end
        state.selectedMenu = 1
        state.selectedField = 1
        state.result = nil
        platform.window:invalidate()
    end
end

-- Helper to get/set current field value
local function getCurrentFieldValue()
    local f = state.selectedField
    if state.screen == "gdp_calc_items" then
        return state.inputs.gdp_items_count or 2
    elseif state.screen == "cpi_laspeyres_items" then
        return state.inputs.laspeyres_items_count or 2
    elseif state.screen == "gdp_calc" and state.inputs.gdp then
        local itemIdx = math.floor((f - 1) / 3) + 1
        local fieldIdx = (f - 1) % 3 + 1
        if fieldIdx == 1 then return state.inputs.gdp.items[itemIdx].p0
        elseif fieldIdx == 2 then return state.inputs.gdp.items[itemIdx].pt
        else return state.inputs.gdp.items[itemIdx].qt end
    elseif state.screen == "gdp_deflator" and state.inputs.gdp_deflator then
        return f == 1 and state.inputs.gdp_deflator.nominal or state.inputs.gdp_deflator.real
    elseif state.screen == "gdp_real" and state.inputs.real_gdp then
        return f == 1 and state.inputs.real_gdp.nominal or state.inputs.real_gdp.deflator
    elseif state.screen == "cpi_laspeyres_basket" and state.inputs.laspeyres then
        return state.inputs.laspeyres.quantities[f] or 0
    elseif state.screen == "cpi_laspeyres_step2" and state.inputs.laspeyres then
        return state.inputs.laspeyres.prices_base[f] or 0
    elseif state.screen == "cpi_laspeyres_step3" and state.inputs.laspeyres then
        return state.inputs.laspeyres.prices_current[f] or 0
    elseif state.screen == "cpi_inflation" and state.inputs.inflation then
        return f == 1 and state.inputs.inflation.cpi_current or state.inputs.inflation.cpi_previous
    end
    return 0
end

local function setCurrentFieldValue(value)
    local f = state.selectedField
    if state.screen == "gdp_calc_items" then
        state.inputs.gdp_items_count = tonumber(value) or 2
    elseif state.screen == "cpi_laspeyres_items" then
        state.inputs.laspeyres_items_count = tonumber(value) or 2
    elseif state.screen == "gdp_calc" and state.inputs.gdp then
        local itemIdx = math.floor((f - 1) / 3) + 1
        local fieldIdx = (f - 1) % 3 + 1
        if fieldIdx == 1 then state.inputs.gdp.items[itemIdx].p0 = value
        elseif fieldIdx == 2 then state.inputs.gdp.items[itemIdx].pt = value
        else state.inputs.gdp.items[itemIdx].qt = value end
    elseif state.screen == "gdp_deflator" and state.inputs.gdp_deflator then
        if f == 1 then state.inputs.gdp_deflator.nominal = value
        else state.inputs.gdp_deflator.real = value end
    elseif state.screen == "gdp_real" and state.inputs.real_gdp then
        if f == 1 then state.inputs.real_gdp.nominal = value
        else state.inputs.real_gdp.deflator = value end
    elseif state.screen == "cpi_laspeyres_basket" and state.inputs.laspeyres then
        state.inputs.laspeyres.quantities[f] = value
    elseif state.screen == "cpi_laspeyres_step2" and state.inputs.laspeyres then
        state.inputs.laspeyres.prices_base[f] = value
    elseif state.screen == "cpi_laspeyres_step3" and state.inputs.laspeyres then
        state.inputs.laspeyres.prices_current[f] = value
    elseif state.screen == "cpi_inflation" and state.inputs.inflation then
        if f == 1 then state.inputs.inflation.cpi_current = value
        else state.inputs.inflation.cpi_previous = value end
    end
end

function on.charIn(char)
    if state.screen:find("_menu") or state.screen == "menu" then return end

    if tonumber(char) or char == "." or char == "-" then
        if state.editBuffer == "" then
            local current = getCurrentFieldValue()
            state.editBuffer = (current == 0) and "" or tostring(current)
        end

        state.editBuffer = state.editBuffer .. char

        local newValue = tonumber(state.editBuffer)
        if newValue then
            setCurrentFieldValue(newValue)
        end
        platform.window:invalidate()
    end
end

function on.backspaceKey()
    if state.screen:find("_menu") or state.screen == "menu" then return end

    if state.editBuffer ~= "" then
        state.editBuffer = state.editBuffer:sub(1, -2)
        local newValue = tonumber(state.editBuffer) or 0
        setCurrentFieldValue(newValue)
        platform.window:invalidate()
    end
end
