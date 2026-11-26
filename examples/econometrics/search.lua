local utf8Char = "[%z\1-\127\194-\244][\128-\191]*"
local upper = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
local lower = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
local latin = {"a", "b", "v", "g", "d", "e", "e", "zh", "z", "i", "i", "k", "l", "m", "n", "o", "p",
               "r", "s", "t", "u", "f", "h", "c", "ch", "sh", "sch", "", "y", "", "e", "iu", "ia"}
local translit = {}
for _, alphabet in ipairs({upper, lower}) do
    local i = 0
    for ch in alphabet:gmatch(utf8Char) do
        i = i + 1
        translit[ch] = latin[i]
    end
end

local function spelling(s)
    return (s:gsub("shch", "sch"):gsub("kh", "h"):gsub("ts", "c")
        :gsub("[yj]o", "e"):gsub("[yj]u", "iu"):gsub("[yj]a", "ia")
        :gsub("j", "i"):gsub("([aeiouy])y", "%1i"):gsub("yi%f[^a-z]", "ii"))
end

local function transliterate(s)
    return spelling((s:gsub(utf8Char, function(ch) return translit[ch] or " " end)))
end

local wordPattern = "[a-z0-9_]+"
local separator = "[.\\]"
local function tokenize(s, visit)
    s = s:lower():gsub("['`]", ""):gsub("’", ""):gsub("[\128-\255]+", transliterate)
    for part in s:gmatch("[a-z0-9_.\\]+") do
        part = part:match("^[.\\]*(.-)[.\\]*$")
        if part:find(separator) and not part:find(separator..separator) then
            visit(part, true)
        else
            for word in part:gmatch(wordPattern) do visit(word) end
        end
    end
end

local function measure(value)
    local terms, length = {}, 0
    tokenize(value, function(term, compound)
        terms[term] = (terms[term] or 0) + 1
        if compound then
            for word in term:gmatch(wordPattern) do
                terms[word] = (terms[word] or 0) + 1
            end
        end
        length = length + 1
    end)
    return terms, length
end

local function firstPrefix(words, prefix)
    local first, last = 1, #words + 1
    while first < last do
        local middle = math.floor((first + last) / 2)
        if words[middle] < prefix then
            first = middle + 1
        else
            last = middle
        end
    end
    return first
end

local function mergePostings(hits, postings, weight)
    if not postings then return end
    for i = 1, #postings, 4 do
        local idHigh, idLow, tfHigh, tfLow = postings:byte(i, i + 3)
        local id, score = 256 * idHigh + idLow, weight * (256 * tfHigh + tfLow)
        hits[id] = math.max(hits[id] or 0, score)
    end
end

local function inverseFrequency(cardCount, frequency)
    return math.log(1 + (cardCount - frequency + 0.5) / (frequency + 0.5))
end

local function scoreTerm(index, forms, allowPrefix, totals, matches)
    local exact, prefix = {}, {}
    for word, weight in pairs(forms) do
        mergePostings(exact, index.postings[word], weight)
        if allowPrefix or #word > 1 then
            local first = firstPrefix(index.words, word)
            for i = first, #index.words do
                local term = index.words[i]
                if term:sub(1, #word) ~= word then break end
                if term ~= word then mergePostings(prefix, index.postings[term], weight) end
            end
        end
    end

    -- Alternate spellings and prefix expansions are evidence for one query term.
    local frequency, prefixFrequency = 0, 0
    for _ in pairs(exact) do frequency = frequency + 1 end
    for id in pairs(prefix) do
        if not exact[id] then prefixFrequency = prefixFrequency + 1 end
    end
    local idf = inverseFrequency(#index.cards, frequency)
    local prefixIdf = 0.65 * inverseFrequency(#index.cards, frequency + prefixFrequency)
    for id, tf in pairs(exact) do
        local score = math.max(tf * idf, (prefix[id] or 0) * prefixIdf)
        totals[id] = (totals[id] or 0) + score
        matches[id] = (matches[id] or 0) + 1
    end
    for id, tf in pairs(prefix) do
        if not exact[id] then
            totals[id] = (totals[id] or 0) + tf * prefixIdf
            matches[id] = (matches[id] or 0) + 1
        end
    end
end

local function find(index, query)
    local terms, groups = {}, {}
    tokenize(query, function(word, compound)
        local canonical = compound and word or spelling(word)
        if canonical == "" then return end
        local forms = groups[canonical]
        if not forms then
            forms = {[canonical] = 0.9}
            groups[canonical] = forms
            terms[#terms + 1] = canonical
        end
        forms[word] = 1
    end)
    table.sort(terms)

    local totals, matches, ranked, result = {}, {}, {}, {}
    for _, term in ipairs(terms) do
        scoreTerm(index, groups[term], #terms == 1, totals, matches)
    end
    for id, score in pairs(totals) do
        totals[id] = score * (0.6 + 0.4 * matches[id] / #terms)
        ranked[#ranked + 1] = id
    end
    table.sort(ranked, function(a, b)
        if totals[a] == totals[b] then return a < b end
        return totals[a] > totals[b]
    end)
    for i, id in ipairs(ranked) do result[i] = index.cards[id] end
    return result
end

local fields = {"title", "tags", "body"}
local weights = {8, 3.5, 1}
local b, k1 = 0.75, 1.2

local function build(cards)
    local documents, lengths, totalLengths = {}, {}, {0, 0, 0}
    for id, card in ipairs(cards) do
        local frequencies, sizes = {}, {}
        for field, name in ipairs(fields) do
            frequencies[field], sizes[field] = measure(card[name])
            totalLengths[field] = totalLengths[field] + sizes[field]
        end
        documents[id], lengths[id] = frequencies, sizes
    end

    local postings, words, averages = {}, {}, {}
    for field, length in ipairs(totalLengths) do
        averages[field] = length > 0 and length / #cards or 1
    end
    for id, frequencies in ipairs(documents) do
        local combined = {}
        for field, terms in ipairs(frequencies) do
            local factor = weights[field] / (1 - b + b * lengths[id][field] / averages[field])
            for term, tf in pairs(terms) do
                combined[term] = (combined[term] or 0) + factor * tf
            end
        end
        -- Store the card ID and saturated BM25F term frequency as two 16-bit values.
        -- Quantization removes the common scale factor (k1 + 1) / 65535.
        local idHigh, idLow = math.floor(id / 256), id % 256
        for term, tf in pairs(combined) do
            local list = postings[term]
            if not list then
                list = {}
                postings[term] = list
                words[#words + 1] = term
            end
            local scaled = math.floor(65535 * tf / (k1 + tf) + 0.5)
            list[#list + 1] = string.char(idHigh, idLow, math.floor(scaled / 256), scaled % 256)
        end
    end
    for term, list in pairs(postings) do postings[term] = table.concat(list) end
    table.sort(words)
    return {cards = cards, postings = postings, words = words, find = find}
end

return {build = build}
