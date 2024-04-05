local Grid3D = require('../Grid3D')
local jestGlobals = require('@pkg/@jsdotlua/jest-globals')

local expect = jestGlobals.expect
local it = jestGlobals.it

it('gets the default cell value for all cells', function()
    local grid = Grid3D.new(4, 5, 3, 'hello')

    for i = 1, 4 do
        for j = 1, 5 do
            for k = 1, 3 do
                expect(grid:get(i, j, k)).toEqual('hello')
            end
        end
    end
end)

it('gets the default cell value from a function for all cells', function()
    local grid = Grid3D.new(4, 5, 3, function(x, y, z)
        return tostring(x) .. '-' .. tostring(y) .. '-' .. tostring(z)
    end)

    for i = 1, 4 do
        for j = 1, 5 do
            for k = 1, 3 do
                local value = tostring(i) .. '-' .. tostring(j) .. '-' .. tostring(k)
                expect(grid:get(i, j, k)).toEqual(value)
            end
        end
    end
end)

it('sets a new value in each cell for all cells', function()
    local grid = Grid3D.new(4, 5, 3, 'hello')

    for i = 1, 4 do
        for j = 1, 5 do
            for k = 1, 3 do
                local newValue = tostring(i) .. '-' .. tostring(j) .. '-' .. tostring(k)
                local previous = grid:set(i, j, k, newValue)
                expect(previous).toEqual('hello')
                expect(grid:get(i, j, k)).toEqual(newValue)
            end
        end
    end
end)

it('sets a new value in each cell for all cells using the update fn', function()
    local grid = Grid3D.new(4, 5, 3, 'hello')

    for i = 1, 4 do
        for j = 1, 5 do
            for k = 1, 3 do
                local newValue = tostring(i) .. '-' .. tostring(j) .. '-' .. tostring(k)
                grid:update(i, j, k, function(_current)
                    return newValue
                end)
                expect(grid:get(i, j, k)).toEqual(newValue)
            end
        end
    end
end)

it('does not update a cell when update fn returns nil', function()
    local grid = Grid3D.new(4, 5, 3, 'hello')

    for i = 1, 4 do
        for j = 1, 5 do
            for k = 1, 3 do
                grid:update(i, j, k, function(_current)
                    return nil
                end)
                expect(grid:get(i, j, k)).toEqual('hello')
            end
        end
    end
end)

it('iters on the grid cells', function()
    local x = 10
    local y = 5
    local z = 5
    local grid = Grid3D.new(x, y, z, 'hello')

    for i = 1, x do
        for j = 1, y do
            for k = 1, z do
                local newValue = tostring(i) .. '-' .. tostring(j) .. '-' .. tostring(k)
                grid:set(i, j, k, newValue)
            end
        end
    end

    local i = 1
    local j = 1
    local k = 1
    local called = 0

    for row, column, depth, item in grid do
        called += 1
        local expectValue = tostring(i) .. '-' .. tostring(j) .. '-' .. tostring(k)

        expect(row).toEqual(i)
        expect(column).toEqual(j)
        expect(depth).toEqual(k)
        expect(item).toEqual(expectValue)

        k += 1
        if k > z then
            k = 1
            j += 1
            if j > y then
                j = 1
                i += 1
            end
        end
    end

    expect(called).toEqual(x * y * z)
end)

return nil
