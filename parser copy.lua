local m = {}

local tokens = {"+", "-", "*", "/", "^", "%"}
function m.calculate(expr)
    local left, right = "", ""
    local operator
    local sub = ""
    local i = 0

    local function calc(left, operator, right)
        if operator == "^" then
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

    for s in expr:gmatch(".") do
        i = i + 1
        if s == "(" then
            sub = ""
        elseif s == ")" then
            print(sub)
            m.calculate(sub)
        else
            sub = sub .. s
        end

        if table.contains(tokens, s) then
            if operator then
                expr = calc(left, operator, right) .. expr:sub(i)
                print(expr)
                return m.calculate(expr)
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

    return calc(left, operator, right)
end
return m