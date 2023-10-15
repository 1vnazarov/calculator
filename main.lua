sw = display.contentWidth
sh = display.contentHeight
fontSize = math.min(sw, sh) / 15

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

function table.copy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function rgb(r, g, b)
    return r / 255, g / 255, b / 255
end

widget = require("widget")
local m = require("parser")
local kb = require("keyboard")
local test = require("test")
test()

local box = native.newTextBox(sw / 2, sh / 10, sw / 1.1, sh / 5)
box.isEditable = true
box.size = fontSize * 1.5
kb(box, function()
    box.text = tostring(m.calculate(box.text))
end)
