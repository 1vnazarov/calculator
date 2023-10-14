local group
local bg
local function drawBg()
    group = display.newGroup()
    bg = display.newRect(group, sw * 0.5, sh * 0.7, sw, sh * 0.8)
end

local buttons = {}
function buttons.init(x, y, xAsDefault)
    buttons.defaultX = xAsDefault and x or buttons.defaultX or x
    buttons.x = x or buttons.defaultX
    buttons.y = not x and buttons.y or y
    buttons.spaceX = sw * 0.02
    buttons.spaceY = sh * 0.02
    buttons.width = sw * 0.15
    buttons.height = sh * 0.1
    buttons.radius = sw * 0.05
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

function buttons.draw(options)
    local button = widget.newButton{
        x = options.x or buttons.x,
        y = options.y or buttons.y,
        label = options.text,
        fontSize = fontSize * (options.fontSize or 1.5),
        labelColor = { default = options.textColor or { 1, 1, 1 } },
        shape = "roundedRect",
        fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
        width = options.width or buttons.width,
        height = options.height or buttons.height,
        radius = buttons.radius,
        onRelease = options.listener
    }
    button.anchorX = 0
    button.anchorY = 0
    (options.parent or group):insert(button)
    return button
end

local function drawButtons(text, listener)
    buttons.init(bg.width * 0.01, bg.y * 0.65)
    for i = 0, 9 do
        buttons.draw {
            text = i,
            x = i == 0 and buttons.calcX(),
            y = i == 0 and buttons.calcY() * 1.622,
            listener = function()
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
        fontSize = 0.85
    }

    buttons.draw {
        text = ".",
        x = buttons.calcX() * 1.96,
        y = buttons.calcY() * 0.885,
        listener = function()
            local operand = text.text:match("[^%+%-*/%%]+$") -- Передавать бы сюда строчку, формирующуюся из таблицы операторов
            if operand and not operand:find("%.") then
                text.text = text.text .. "."
            end
        end
    }

    buttons.init(bg.width * 0.01, bg.y * 0.45, true)
    local ops = { "!", "^", "%", "*", "/", "+", "-" }
    for i, v in pairs(ops) do
        buttons.draw {
            text = v,
            listener = function()
                local c = text.text:sub(#text.text, #text.text)
                if table.contains({unpack(ops), "."}, c) then return end
                text.text = text.text .. v
                if table.contains(ops, text.text) then text.text = "" end
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
        listener = function()
            text.text = text.text .. "("
        end
    }

    buttons.draw {
        text = ")",
        x = buttons.calcX(true),
        y = buttons.calcY(true) * 0.64,
        listener = function()
            local c = text.text:sub(#text.text, #text.text)
            if not tonumber(c) and c ~= "!" then return end
            text.text = text.text .. ")"
        end
    }

    buttons.draw {
        x = buttons.calcX(true),
        y = buttons.calcY() * 0.545,
        text = "<",
        textColor = { 0.8, 0.4, 0.2 },
        width = buttons.width * 0.9,
        listener = function()
            if text.text:len() > 0 then
                text.text = text.text:sub(1, -2)
            end
        end
    }

    buttons.draw {
        text = "C",
        y = buttons.calcY() * 0.395,
        textColor = { 0.8, 0.4, 0.2 },
        width = buttons.width * 0.9,
        listener = function()
            text.text = ""
        end
    }

    local function validateFunc(func)
        local c = text.text:sub(#text.text, #text.text)
        if tonumber(c) or c == ")" then return end
        text.text = text.text .. func .. "("
    end

    buttons.draw {
        text = "pi",
        x = buttons.calcX() * 0.505,
        y = buttons.calcY() * 0.545,
        listener = function()
            text.text = text.text .. "pi"
        end
    }

    buttons.draw {
        text = "e",
        x = buttons.calcX() * 0.505,
        y = buttons.calcY() * 0.723,
        listener = function()
            text.text = text.text .. "e"
        end
    }

    buttons.draw {
        text = "=",
        x = buttons.calcX(true) * 0.835,
        y = buttons.calcY() * 0.72,
        width = buttons.width * 0.9,
        height = buttons.height * 2,
        listener = listener
    }
end

local function kb(text, listener)
    if bg and bg.removeSelf then
        bg:removeSelf()
        bg = nil
    end
    if group and group.removeSelf then group:removeSelf() group = nil end
    drawBg()
    drawButtons(text, listener)
end

return kb