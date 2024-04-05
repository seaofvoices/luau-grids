local Grid2D = require('../Grid2D')
local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local expect = jestGlobals.expect
local it = jestGlobals.it

it('gets the default cell value for all cells', function()
    local grid = Grid2D.new(10, 5, 'hello')

    for i = 1, 10 do
        for j = 1, 5 do
            expect(grid:get(i, j)).toEqual('hello')
        end
    end
end)

it('gets the default cell value from a function for all cells', function()
    local grid = Grid2D.new(10, 5, function(x, y)
        return tostring(x) .. '-' .. tostring(y)
    end)

    for i = 1, 10 do
        for j = 1, 5 do
            local value = tostring(i) .. '-' .. tostring(j)
            expect(grid:get(i, j)).toEqual(value)
        end
    end
end)

it('sets a new value in each cell for all cells', function()
    local grid = Grid2D.new(10, 5, 'hello')

    for i = 1, 10 do
        for j = 1, 5 do
            local newValue = tostring(i) .. '-' .. tostring(j)
            local previous = grid:set(i, j, newValue)
            expect(previous).toEqual('hello')
            expect(grid:get(i, j)).toEqual(newValue)
        end
    end
end)

it('sets a new value in each cell for all cells using the update fn', function()
    local grid = Grid2D.new(10, 5, 'hello')

    for i = 1, 10 do
        for j = 1, 5 do
            local newValue = tostring(i) .. '-' .. tostring(j)
            grid:update(i, j, function(_current)
                return newValue
            end)
            expect(grid:get(i, j)).toEqual(newValue)
        end
    end
end)

it('does not update a cell when update fn returns nil', function()
    local grid = Grid2D.new(10, 5, 'hello')

    for i = 1, 10 do
        for j = 1, 5 do
            grid:update(i, j, function(_current)
                return nil
            end)
            expect(grid:get(i, j)).toEqual('hello')
        end
    end
end)

it('iters on the grid cells', function()
    local width = 10
    local height = 5
    local grid = Grid2D.new(width, height, 'hello')

    for i = 1, width do
        for j = 1, height do
            local newValue = tostring(i) .. '-' .. tostring(j)
            grid:set(i, j, newValue)
        end
    end

    local i = 1
    local j = 1
    local called = 0

    for row, column, item in grid do
        called += 1
        local expectValue = tostring(i) .. '-' .. tostring(j)

        expect(row).toEqual(i)
        expect(column).toEqual(j)
        expect(item).toEqual(expectValue)
        j += 1
        if j > height then
            j = 1
            i += 1
        end
    end

    expect(called).toEqual(width * height)
end)

return nil
