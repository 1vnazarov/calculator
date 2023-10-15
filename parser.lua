local m = {}

function m.calculate(expr)
    expr = tostring(expr):gsub("%s+", "")
    if tonumber(expr) then
        return tonumber(expr)
    end
    if expr == "" then
        return expr
    end
    local consts = {
        pi = math.pi,
        e = math.exp(1)
    }

    local function replaceConstants(expr, vars) -- На самом деле, не только замена констант, но еще и переменных
        for name, value in pairs(vars or consts) do
            -- Проверяем, что перед и после имени константы нет букв
            local pattern = ("([^%a%d%.])"):rep(#name) .. name .. ("([^%a%d%.])"):rep(#name)
            expr = expr:gsub(pattern, function(left, right)
                local left_bracket, right_bracket = left:sub(-1), right:sub(1)
                if (left_bracket == "(" or left_bracket == "=") and right_bracket == ")" then
                    -- В найденном совпадении заменяем имя константы на ее значение
                    return left .. tostring(value) .. right
                else -- Отменяем замену, если вокруг имени есть скобки
                    return left .. name .. right
                end
            end)
    
            -- Обработка первого символа в выражении, если он является константой
            if expr:sub(1, #name) == name then
                expr = tostring(value) .. expr:sub(#name + 1)
            end
    
            -- Обработка последнего символа в выражении, если он является константой
            if expr:sub(-#name) == name then
                expr = expr:sub(1, #expr - #name) .. tostring(value)
            end
    
            -- Обработка вхождений констант в аргументах функций
            expr = expr:gsub("%b()", function(arg)
                local replaced = replaceConstants(arg:sub(2, #arg - 1)) -- Заменяем константы внутри скобок
                return "(" .. replaced .. ")" -- Возвращаем скобки вокруг замененного значения
            end)
        end
        return expr
    end

    local funcs = {
        sin = math.sin,
        cos = math.cos,
        tan = math.tan,
        ctg = function(x)
            return math.cos(x) / math.sin(x)
        end,
        abs = math.abs,
        deg = math.deg,
        integral = function(func, a, b, n)
            n = n or 100
            local h = (b - a) / n
            local k = 0
            local x = a + h
            local function f(x)
                return m.calculate(replaceConstants(func, {x = x}))
            end
            for _ = 1, n / 2 do
                k = k + 4 * f(x)
                x = x + 2 * h
            end
            x = a + 2 * h
            for _ = 1, n / 2 - 1 do
                k = k + 2 * f(x)
                x = x + 2 * h
            end
            return (h / 3) * (f(a) + f(b) + k)
        end
    }

    local function factorial(n)
        if n < 0 or math.floor(n) ~= n then
            return
        end
        local res = 1
        for i = 2, n do
            res = res * i
        end
        return res
    end

    local function parseNumber(expr)
        local number, rest = expr:match("^(-?%d+%.?%d*)(.*)")
        if number then
            return tonumber(number), rest
        end
    end

    local function parseFactorial(expr)
        local number, rest = parseNumber(expr)
        if not number then
            return
        end
        if rest:sub(1, 1) == "!" then
            return factorial(number), rest:sub(2)
        else
            return number, rest
        end
    end

    local function parseNegate(expr)
        if expr:sub(1, 1) == "-" then
            local number, rest = parseFactorial(expr:sub(2))
            if number then
                return -number, rest
            end
        else
            return parseFactorial(expr)
        end
    end

    local function parsePower(expr)
        local left, rest = parseNegate(expr)
        while rest:sub(1, 1) == "^" do
            local right
            right, rest = parseNegate(rest:sub(2))
            left = left ^ right
        end
        return left, rest
    end

    local function parseProduct(expr)
        local left, rest = parsePower(expr)
        while rest:match("^[%*/%%]") do
            local operator = rest:sub(1, 1)
            local right
            right, rest = parsePower(rest:sub(2))
            if operator == "*" then
                left = left * right
            elseif operator == "/" then
                left = left / right
            elseif operator == "%" then
                left = left % right
            end
        end
        return left, rest
    end

    local function parseSum(expr)
        local left, rest = parseProduct(expr)
        while rest:match("^[%+%-]") do
            local operator = rest:sub(1, 1)
            local right
            right, rest = parseProduct(rest:sub(2))
            if operator == "+" then
                left = left + right
            else
                left = left - right
            end
        end
        return left, rest
    end

    local function parse(expr)
        local result = parseSum(expr:gsub("%s+", ""))
        if not result then
            return
        end
        if tonumber(result) then
            return result
        end
        local calculated, rest = unpack(result)
        if rest ~= "" then
            return -- Если остался непрочитанный текст, выражение было недействительным
        end
        return calculated
    end

    local function calcFunctions(expr)
        local ignore = {
            integral = {1}
        }
        return expr:gsub("([%a_]+)(%b())", function(func, args)
            local argsTbl = {}
            local i = 0
            for arg in args:sub(2, -2):gmatch("([^,]+)") do
                i = i + 1
                table.insert(argsTbl, (ignore[func] and table.contains(ignore[func], i)) and arg or m.calculate(arg))
            end

            if funcs[func] then
                return funcs[func](unpack(argsTbl))
            else
                return func .. "(" .. args .. ")"
            end
        end)
    end
    
    expr = replaceConstants(expr)
    expr = calcFunctions(expr)
    return parse(expr) or expr
end

return m