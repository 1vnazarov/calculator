local m = {}

function m.calculate(expr)
    local tokens = {"+", "-", "*", "/", "^", "%", "!"}

    local function factorial(n)
        if n == 0 then
            return 1
        end
        return n * factorial(n - 1)
    end

    local function calc(left, operator, right)
        if operator == "!" then
            return factorial(left)
        elseif operator == "^" then
            return left ^ right
        elseif operator == "*" then
            return left * right
        elseif operator == "/" then
            return left / right
        elseif operator == "%" then
            return left % right
        elseif operator == "+" then
            return left + right
        elseif operator == "-" then
            return left - right
        end
    end

    local function parse(expr)
        local left, right = "", ""
        local operator
        local i = 0

        for s in expr:gmatch(".") do
            i = i + 1

            if table.contains(tokens, s) then
                if operator then
                    print(expr, left, operator, right, calc(left, operator, right), expr:sub(i))
                    -- 8^2+(7*5+(2*2))
                    expr = calc(left, operator, right) .. expr:sub(i)
                    return parse(expr)
                end
                operator = s
            end
            
            if tonumber(s) or s == "." then
                if not operator then
                    left = left .. s
                else
                    right = right .. s
                end
            end
        end
        return left, operator, right
    end

    local function brackets(expr)
        local sub = ""
        for s in expr:gmatch(".") do
            if s == "(" then
                sub = ""
            elseif s == ")" then
                return brackets(expr:replace("(" .. sub .. ")", m.calculate(sub)))
            else
                sub = sub .. s
            end
        end
        return expr
    end
    expr = brackets(expr)
    print(expr)
    return calc(parse(expr))
end
return m