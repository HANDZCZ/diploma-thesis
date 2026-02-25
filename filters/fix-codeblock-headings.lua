-- adds `\Needspace` before `Heading` if it is followed by `CodeBlock`
-- fixes heading being left on one page and codeblock at the next
function Pandoc(doc)
    for i = #doc.blocks - 1, 1, -1 do
        local curr = doc.blocks[i]
        local next = doc.blocks[i + 1]

        -- if there is a heading followed by codeblock insert needspace
        if (curr.tag == "Header") and (next.tag == "CodeBlock") then
            table.insert(doc.blocks, i, pandoc.RawInline("latex", "\\Needspace{8\\baselineskip}"))
        end
    end

    return doc
end
