-- Adds a non-breaking space after words.
-- default words to add a non-breaking space after
local after = {"za", "ze", "pro", "si", "se", "ve", "na", "bez", "při", "že", "ho", "by", "po", "do", "ke", "jak", "je", "co", "či", "ale", "lze", "tzv.", "tj.", "např."};

-- helper function for constructing a Set
function Set (list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

-- get filter options from meta or use defaults
local after_set = {}
function Meta(m)
    local meta_after = m["non-breaking_space_after"]
    -- set after to custom words
    if meta_after ~= nil then
        after = meta_after;
        -- convert pandoc.MetaString to regular string
        for k, v in ipairs(meta_after) do
            after[k] = after[k][1].text
        end
    end

    -- create a Set for faster lookup
    after_set = Set(after)
end

-- checks if word should have non-breaking after it
function is_in_after(word)
    local lword = pandoc.text.lower(word)
    return after_set[lword] or false
end

function Inlines(inlines)
    -- go through all pairs of elements
    for i = #inlines - 1, 1, -1 do
        local curr = inlines[i]
        local next = inlines[i + 1]

        -- if it's an str followed by a space and should have a non-breaking space then replace the space
        if curr.tag == "Str" and is_in_after(curr.text) and next.tag == "Space" then
            inlines[i + 1] = pandoc.RawInline("latex", "~")
        end
    end

    return inlines
end

return {
  {Meta = Meta},
  {Inlines = Inlines}
}
