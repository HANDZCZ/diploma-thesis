-- add clases that are on figure to underlying image
function Figure(element)
    -- check if image exists
    if element.content[1].content[1].attributes == nil then
        return element
    end

    -- add clases
    for _, val in ipairs(element.attributes) do
        table.insert(element.content[1].content[1].attributes, val)
    end

    -- if caption is empty convert to plain image
    if #element.caption.long == 0 then
        return element.content
    end

    -- return modified element
    return element
end

return {
  {Figure = Figure}
}
