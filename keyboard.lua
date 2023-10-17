local group
local bg
local function drawBg()
    group = display.newGroup()
    bg = display.newRect(group, sw * 0.5, sh * 0.7, sw, sh * 0.8)
end

local buttons = {}
function buttons.init(x, y, defaultAsX)
    buttons.cache = buttons.cache or {}
    buttons.defaultX = defaultAsX and x or buttons.defaultX or x
    buttons.x = x or buttons.defaultX
    buttons.y = not x and buttons.y or y
    buttons.spaceX = sw * 0.02
    buttons.spaceY = sh * 0.02
    buttons.width = sw * 0.15
    buttons.height = sh * 0.1
    buttons.radius = sh / sw * 20
end

function buttons.calcX(trueCalc)
    local res = buttons.x + buttons.width + buttons.spaceX
    buttons.x = trueCalc and res or buttons.x
    return res
end

function buttons.calcY(trueCalc)
    local res = buttons.y + buttons.height + buttons.spaceY
    buttons.y = trueCalc and res or buttons.y
    return res
end

function buttons.applyLayout(layout)
    for _, v in ipairs(buttons.cache) do
        v.isVisible = v.layout and v.layout == layout
    end
end

function buttons.draw(options)
    local fontCoef = options.fontSize or 1.15
    local fontSize = fontSize * fontCoef

    local testText = display.newText {
        text = options.text,
        font = options.font,
        fontSize = fontSize,
    }
    testText.isVisible = false

    local width = options.width or buttons.width
    local maxWidth = width

    -- Если текст слишком большой, уменьшаем размер шрифта
    while testText.contentWidth > maxWidth do
        fontCoef = fontCoef - 0.1
        testText.size = fontSize * fontCoef
    end
    fontSize = fontSize * fontCoef

    testText:removeSelf()
    testText = nil

    local button = widget.newButton {
        x = options.x or buttons.x,
        y = options.y or buttons.y,
        label = options.text,
        font = options.font,
        fontSize = fontSize,
        labelColor = { default = options.textColor or { 1, 1, 1 } },
        shape = "roundedRect",
        fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
        width = width,
        height = options.height or buttons.height,
        radius = buttons.radius,
        onRelease = options.listener
    }
    button.anchorX = 0
    button.anchorY = 0
    (options.parent or group):insert(button)
    button.layout = options.layout
    table.insert(buttons.cache, button)
    return button
end

local function drawButtons(text, listener)
    local function endsAsConsts()
        for _, v in ipairs { "pi", "e" } do
            if text.text:ends(v) then
                return #v
            end
        end
    end
    
    local funcs = { "sin", "cos", "tan", "ctg", "abs", "deg", "rad", "integral" }
    local function endsAsFuncs()
        for _, v in ipairs(funcs) do
            if text.text:ends(v .. "(") then
                return #v + 1
            end
        end
    end

    local function getLastChar()
        return text.text:sub(#text.text, #text.text)
    end

    local function checkBrackets()
        local openBraceCount = 0
        local closeBraceCount = 0
        for i = 1, #text.text do
            if text.text:sub(i, i) == "(" then
                openBraceCount = openBraceCount + 1
            end
            if text.text:sub(i, i) == ")" then
                closeBraceCount = closeBraceCount + 1
            end
        end
        return not (openBraceCount <= closeBraceCount)
    end

    buttons.init(bg.width * 0.01, bg.y * 0.65)
    for i = 0, 9 do
        buttons.draw {
            text = i,
            x = i == 0 and buttons.calcX(),
            y = i == 0 and buttons.calcY() * 1.622,
            layout = "numbers",
            listener = function()
                if endsAsConsts() or getLastChar() == ")" then
                    text.text = text.text .. "*"
                end
                text.text = text.text .. i
            end
        }
        if i % 3 == 0 then
            buttons.init()
            buttons.calcY(true)
        else
            buttons.calcX(true)
        end
    end

    buttons.draw {
        text = "funcs",
        x = buttons.calcX() * 0.07,
        y = buttons.calcY() * 0.885,
        layout = "numbers",
        listener = function()
            buttons.applyLayout("funcs")
        end
    }

    local ops = { "!", "^", "%", "*", "/", "+", "-" }
    buttons.draw {
        text = ".",
        x = buttons.calcX() * 1.96,
        y = buttons.calcY() * 0.885,
        layout = "numbers",
        listener = function()
            local operand = text.text:match("[" .. table.concat(ops, "%", 2) .. "]+$") -- Факториал не брать
            local c = getLastChar()
            if endsAsConsts() or not (operand and not operand:find("%.")) or c == ")" or c == "(" then return end
            text.text = text.text .. "."
        end
    }

    buttons.init(bg.width * 0.01, bg.y * 0.45, true)
    for i, v in pairs(ops) do
        buttons.draw {
            text = v,
            layout = "numbers",
            listener = function()
                local opsDot = table.copy(ops)
                opsDot[table.indexOf(opsDot, "-")] = "."
                local c = getLastChar()
                if table.contains(opsDot, c) or c == "-" then return end
                text.text = text.text .. v
                if table.contains(opsDot, text.text) then text.text = "" end
            end
        }
        if i % 4 == 0 then
            buttons.init()
            buttons.calcY(true)
        else
            buttons.calcX(true)
        end
    end

    buttons.draw {
        text = "(",
        x = buttons.calcX(),
        y = buttons.calcY(true) * 0.565,
        layout = "numbers",
        listener = function()
            local c = getLastChar()
            if c == "." then return end
            if tonumber(c) or endsAsConsts() then
                text.text = text.text .. "*"
            end
            text.text = text.text .. "("
        end
    }

    buttons.draw {
        text = ")",
        x = buttons.calcX(true),
        y = buttons.calcY(true) * 0.64,
        layout = "numbers",
        listener = function()
            local allowClose = table.copy(ops)
            table.remove(allowClose, table.indexOf(allowClose, "!"))
            local c = getLastChar()
            if not checkBrackets() or table.contains(allowClose, c) or c == "(" then return end
            text.text = text.text .. ")"
        end
    }

    buttons.draw {
        x = buttons.calcX(true),
        y = buttons.calcY() * 0.545,
        text = "<",
        textColor = { 0.8, 0.4, 0.2 },
        width = buttons.width * 0.9,
        layout = "numbers",
        listener = function()
            if text.text:len() > 0 then
                local index = endsAsConsts() or endsAsFuncs()
                text.text = text.text:sub(1, (-(index or 1)) - 1)
            end
        end
    }

    buttons.draw {
        text = "C",
        y = buttons.calcY() * 0.395,
        textColor = { 0.8, 0.4, 0.2 },
        width = buttons.width * 0.9,
        layout = "numbers",
        listener = function()
            text.text = ""
        end
    }

    local allowedForConsts = table.copy(ops)
    table.insert(allowedForConsts, "(")
    table.insert(allowedForConsts, ")")
    table.insert(allowedForConsts, ",")
    table.insert(allowedForConsts, "")
    buttons.draw {
        text = "pi",
        x = buttons.calcX() * 0.505,
        y = buttons.calcY() * 0.545,
        layout = "numbers",
        listener = function()
            local c = getLastChar()
            if not table.contains(allowedForConsts, c) and not endsAsConsts() and not tonumber(c) then return end
            if tonumber(c) or endsAsConsts() or c == ")" then
                text.text = text.text .. "*"
            end
            text.text = text.text .. "pi"
        end
    }

    buttons.draw {
        text = "e",
        x = buttons.calcX() * 0.505,
        y = buttons.calcY() * 0.723,
        layout = "numbers",
        listener = function()
            local c = getLastChar()
            if not table.contains(allowedForConsts, c) and not endsAsConsts() and not tonumber(c) then return end
            if tonumber(c) or endsAsConsts() or c == ")" then
                text.text = text.text .. "*"
            end
            text.text = text.text .. "e"
        end
    }

    buttons.draw {
        text = "=",
        x = buttons.calcX(true) * 0.835,
        y = buttons.calcY() * 0.72,
        width = buttons.width * 0.9,
        height = buttons.height * 2,
        layout = "numbers",
        listener = listener
    }

    buttons.init(bg.width * 0.01, bg.y * 0.45, true)
    for i, v in ipairs(funcs) do
        buttons.draw {
            text = v,
            layout = "funcs",
            fontSize = 0.9,
            listener = function()
                if tonumber(getLastChar()) or endsAsConsts() then
                    text.text = text.text .. "*"
                end
                text.text = text.text .. v .. "("
                buttons.applyLayout("numbers")
            end
        }
        if i % 4 == 0 then
            buttons.init()
            buttons.calcY(true)
        else
            buttons.calcX(true)
        end
    end

    --[[
        ИСПРАВИТЬ ВАЛИДАЦИЮ ИКСА И ЗАПЯТОЙ
    ]]

    buttons.draw {
        text = "X",
        x = buttons.calcX() * 3.825,
        y = buttons.calcY() * 0.465,
        layout = "funcs",
        fontSize = 0.9,
        listener = function()
            local c = getLastChar()
            if c == "(" or c == "," then
                text.text = text.text .. "x"
            end
            buttons.applyLayout("numbers")
        end
    }

    buttons.draw {
        text = ",",
        x = buttons.calcX() * 3.825,
        y = buttons.calcY() * 0.645,
        layout = "funcs",
        fontSize = 0.9,
        listener = function()
            local c = getLastChar()
            if c == "," or c == "(" then return end
            local operand = text.text:match("[^%d%.]+$")
            if operand and operand ~= ")" then return end
            text.text = text.text .. ","
            buttons.applyLayout("numbers")
        end
    }

    buttons.draw {
        text = "0-9",
        layout = "funcs",
        fontSize = 0.9,
        listener = function()
            buttons.applyLayout("numbers")
        end
    }

    buttons.applyLayout("numbers")
end

local function kb(text, listener)
    if bg and bg.removeSelf then
        bg:removeSelf()
        bg = nil
    end
    if group and group.removeSelf then
        group:removeSelf()
        group = nil
    end
    drawBg()
    drawButtons(text, listener)
end

return kb
