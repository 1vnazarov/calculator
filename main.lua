sw = display.contentWidth
sh = display.contentHeight

local box = native.newTextField(sw / 2, sh / 2, sw, sh / 5)

--[[function string:split(sep, reg)
    local res = {}
    reg = reg and sep or string.format("([^%s]+)", sep)
    for v in self:gmatch(reg) do
        table.insert(res, v)
    end
    return res
end]]

function string:replace(old, new)
    local b, e = self:find(old, 1, true)
    if not b then
       return self
    else
        return self:sub(1, b - 1) .. new .. self:sub(e + 1)
    end
end

function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value or (type(v) == "table" and table.contains(v, value)) then
            return true
        end
    end
    return false
end

--[[function table.pop(tbl)
    return table.remove(tbl, 1)
end]]

local m = require("parser")
box:addEventListener("userInput", function(event)
    if event.phase == "submitted" then
        print(m.calculate(event.target.text))
    end
end)