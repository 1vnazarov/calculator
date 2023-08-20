sw = display.contentWidth
sh = display.contentHeight

local box = native.newTextField(sw / 2, sh / 2, sw, sh / 5)

function string:replace(old, new)
    local b, e = self:find(old, 1, true)
    if not b then
       return self
    else
        return self:sub(1, b - 1) .. new .. self:sub(e + 1)
    end
end

function string:split(sep, plain)
    local b, res = 0, {}
    sep = sep or "%s+"

    if #sep == 0 then
        for i = 1, #self do
            res[#res + 1] = self:sub(i, i)
        end
        return res
    end

    while b <= #self do
        local e, e2 = self:find(sep, b, plain)
        if e then
            res[#res + 1] = self:sub(b, e - 1)
            b = e2 + 1
            if b > #self then
                res[#res + 1] = ""
            end
        else
            res[#res + 1] = self:sub(b)
            break
        end
    end
    return res
end

function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value or (type(v) == "table" and table.contains(v, value)) then
            return true
        end
    end
    return false
end

local m = require("parser")
box:addEventListener("userInput", function(event)
    if event.phase == "submitted" then
        print("RES:", m.calculate(event.target.text))
    end
end)