local group
local bg
local function drawBg()
    group = display.newGroup()
    bg = display.newRect(group, sw * 0.5, sh * 0.75, sw, sh * 0.45)
end

local function drawButtons(text, onlyNums, listener)
    local minus, dot, numsTab, opsTab
    local mode = "nums"
    local nums = {}
    local numX, numY, numWidth, numHeight, numRadius = not onlyNums and bg.x * 0.16 or bg.x * 0.62, bg.contentBounds.yMin * 1.1, sw * 0.15, sh * 0.1, sw * 0.047
    for i = 0, 9 do
        local options = {
            x = numX,
            y = numY,
            label = i,
            fontSize = fontSize * 2,
            labelColor = { default = { 1, 1, 1 } },
            shape = "roundedRect",
            fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
            width = numWidth,
            height = numHeight,
            cornerRadius = numRadius,
            onRelease = function()
                text.text = text.text .. i
            end
        }
        if i == 0 then
            options.x = not onlyNums and bg.x * 0.5 or bg.x * 0.96
            options.y = bg.contentBounds.yMax * 0.95
            options.width = sw * 0.25
            options.height = sh * 0.08
        else
            if i % 3 == 0 then
                numX = not onlyNums and bg.x * 0.16 or bg.x * 0.62
                numY = numY + numHeight + sh * 0.02
            else
                numX = numX + numWidth + sw * 0.02
            end
        end
        nums[i] = widget.newButton(options)
        group:insert(nums[i])
    end
    local ops = { "!", "^", "%", "*", "/", "+", "-" }
    minus = widget.newButton{
        x = bg.x * 1.26,
        y = bg.contentBounds.yMin * 1.55,
        label = "-",
        fontSize = fontSize * 3,
        labelColor = {default = {1, 1, 1}},
        shape = "roundedRect",
        fillColor = {default = {rgb(85, 70, 195)}, over = {rgb(199, 8, 88)}},
        width = numWidth  * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            local c = text.text:sub(#text.text, #text.text)
            if table.contains({"+", "-", "*", "/", "^", "!"}, c) then return end
            text.text = text.text .. "-"
        end
    }
    group:insert(minus)
    local operators = {}
    numX, numY, numWidth, numHeight, numRadius = bg.x * 0.62, bg.contentBounds.yMin * 1.1,
        sw * 0.15, sh * 0.1, sw * 0.047
    for i, v in ipairs(ops) do
        local options = {
            x = numX,
            y = numY,
            label = v,
            fontSize = fontSize * 2,
            labelColor = { default = { 1, 1, 1 } },
            shape = "roundedRect",
            fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
            width = numWidth,
            height = numHeight,
            cornerRadius = numRadius,
            onRelease = function()
                local c = text.text:sub(#text.text, #text.text)
                if table.contains({ "+", "-", "*", "/", "^", "!" }, c) then return end
                text.text = text.text .. v
                if table.contains({ "+", "*", "/", "^", "!" }, text.text) then text.text = "" end
            end
        }
        if i == 0 then
            options.x = bg.x * 0.96
            options.y = bg.contentBounds.yMax * 0.95
            options.width = sw * 0.25
            options.height = sh * 0.08
        else
            if i % 3 == 0 then
                numX = bg.x * 0.62
                numY = numY + numHeight + sh * 0.02
            else
                numX = numX + numWidth + sw * 0.02
            end
        end
        operators[i] = widget.newButton(options)
        operators[i].isVisible = false
        group:insert(operators[i])
    end
    opsTab = widget.newButton {
        x = bg.x * 1.26,
        y = bg.contentBounds.yMin * 1.3,
        label = "+-*/!^",
        fontSize = fontSize,
        labelColor = { default = { 1, 1, 1 } },
        shape = "roundedRect",
        fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
        width = numWidth * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            for _, v in pairs(nums) do
                v.isVisible = false
            end
            dot.isVisible = false
            minus.isVisible = false
            opsTab.isVisible = false
            numsTab.isVisible = true
            for _, v in pairs(operators) do
                v.isVisible = true
            end
        end
    }
    numsTab = widget.newButton {
        x = bg.x * 1.26,
        y = bg.contentBounds.yMin * 1.7,
        label = "0-9",
        fontSize = fontSize,
        labelColor = { default = { 1, 1, 1 } },
        shape = "roundedRect",
        fillColor = { default = { rgb(85, 70, 195) }, over = { rgb(199, 8, 88) } },
        width = numWidth * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            for _, v in pairs(nums) do
                v.isVisible = true
            end
            dot.isVisible = true
            minus.isVisible = true
            numsTab.isVisible = false
            opsTab.isVisible = true
            for _, v in pairs(operators) do
                v.isVisible = false
            end
        end
    }
    numsTab.isVisible = false
    group:insert(minus)
    dot = widget.newButton{
        x = bg.x * 1.26,
        y = bg.contentBounds.yMin * 1.76,
        label = ".",
        fontSize = fontSize * 3,
        labelColor = {default = {1, 1, 1}},
        shape = "roundedRect",
        fillColor = {default = {rgb(85, 70, 195)}, over = {rgb(199, 8, 88)}},
        width = numWidth  * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            local len = text.text:len()
            if tonumber(text.text:sub(len, len)) and not text.text:find(".", 1, true) then
                text.text = text.text .. "."
            end
        end
    }
    group:insert(dot)
    local clear = widget.newButton{
        x = bg.x * 1.75,
        y = bg.contentBounds.yMin * 1.1,
        label = "C",
        fontSize = fontSize * 2,
        labelColor = {default = {1, 0, 0}},
        shape = "roundedRect",
        fillColor = {default = {rgb(85, 70, 195)}, over = {rgb(199, 8, 88)}},
        width = numWidth  * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            text.text = ""
        end
    }
    group:insert(clear)
    local delete = widget.newButton{
        x = bg.x * 1.75,
        y = bg.contentBounds.yMin * 1.33,
        label = "<",
        fontSize = fontSize * 2,
        labelColor = {default = {0.9, 0.2, 0.1}},
        shape = "roundedRect",
        fillColor = {default = {rgb(85, 70, 195)}, over = {rgb(199, 8, 88)}},
        width = numWidth  * 1.5,
        height = numHeight,
        cornerRadius = numRadius,
        onRelease = function()
            if text.text:len() > 0 then
                text.text = text.text:sub(1, -2)
            end
        end
    }
    group:insert(delete)
    local result = widget.newButton{
        x = bg.x * 1.75,
        y = bg.contentBounds.yMin * 1.65,
        label = "=",
        fontSize = fontSize * 3,
        labelColor = {default = {1, 1, 1}},
        shape = "roundedRect",
        fillColor = {default = {rgb(85, 70, 195)}, over = {rgb(199, 8, 88)}},
        width = numWidth * 1.5,
        height = numHeight * 2,
        cornerRadius = numRadius,
        onRelease = function()
            listener()
        end
    }
    group:insert(result)
    if onlyNums then
        dot.isVisible = false
        minus.isVisible = false
        clear.isVisible = false
        return
    end
end

local function kb(text, onlyNums, listener)
    if bg and bg.removeSelf then
        bg:removeSelf()
        bg = nil
    end
    if group and group.removeSelf then group:removeSelf() group = nil end
    drawBg()
    drawButtons(text, onlyNums, listener)
end

return kb