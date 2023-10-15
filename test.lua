local tests = {}
local m = require("parser")
local function add(expr, expected)
    table.insert(tests, {expr = expr, res = tostring(m.calculate(expr)), expected = tostring(expected)})
end

add("2+2", 4)
add("-2-2", -4)
add("0-2", -2)
add("pi*2", 3.14 * 2)
add("5!", 120)
add("sin(3.14)", math.sin(3.14))
add("5+(3-5)*3", -1)

return function()
    local passedTests = 0
    for _, v in ipairs(tests) do
        if v.res == v.expected then
            print("Test for " .. v.expr .. " is passed!")
            passedTests = passedTests + 1
        else
            print("Test failed! For " .. v.expr .. " expected " .. v.expected .. " but got " .. v.res)
        end
    end
    print(passedTests .. "/" .. #tests .. " tests are passed")
end