export type Grid3D<Cell> = {
    get: (self: Grid3D<Cell>, x: number, y: number, z: number) -> Cell?,
    set: (self: Grid3D<Cell>, x: number, y: number, z: number, value: Cell) -> Cell,
    update: (self: Grid3D<Cell>, x: number, y: number, z: number, fn: (value: Cell) -> Cell?) -> (),
    size: (self: Grid3D<Cell>) -> (number, number, number),
}

type Private<Cell> = {
    _sizeX: number,
    _sizeY: number,
    _sizeZ: number,
    _sizeYZ: number,
    _length: number,
    _data: { Cell },
}

type PrivateGrid3D<Cell> = Grid3D<Cell> & Private<Cell>

type Grid3DStatic = {
    new: <Cell>(
        sizeX: number,
        sizeY: number,
        sizeZ: number,
        defaultCell: Cell | (x: number, y: number, z: number) -> Cell
    ) -> Grid3D<Cell>,

    get: <Cell>(self: Grid3D<Cell>, x: number, y: number, z: number) -> Cell?,
    set: <Cell>(self: Grid3D<Cell>, x: number, y: number, z: number, value: Cell) -> Cell,
    update: <Cell>(
        self: Grid3D<Cell>,
        x: number,
        y: number,
        z: number,
        fn: (value: Cell) -> Cell?
    ) -> (),
    size: <Cell>(self: Grid3D<Cell>) -> (number, number, number),
}

local Grid3D: Grid3DStatic = {} :: any
local Grid3DMetatable = {
    __index = Grid3D,
    __iter = function<Cell>(self)
        local self: PrivateGrid3D<Cell> = self :: any
        local sizeY = self._sizeY
        local sizeZ = self._sizeZ
        local i = 0
        local x = 1
        local y = 1
        local z = 0
        local length = self._length

        local function nextItem(data): any
            if i >= length then
                return nil
            end
            i += 1
            z += 1
            if z > sizeZ then
                z = 1
                y += 1
                if y > sizeY then
                    y = 1
                    x += 1
                end
            end

            local item = data[i]
            return x, y, z, item
        end
        return nextItem, self._data
    end,
}

local function assertNumbers(x: unknown, y: unknown, z: unknown, names: { string })
    assert(type(x) == 'number', `parameter '{names[1]}' should be a number, received '{type(x)}'`)
    assert(type(y) == 'number', `parameter '{names[2]}' should be a number, received '{type(y)}'`)
    assert(type(z) == 'number', `parameter '{names[3]}' should be a number, received '{type(z)}'`)
end

local function assertBounds(
    x: unknown,
    y: unknown,
    z: unknown,
    names: { string },
    maxX: number,
    maxY: number,
    maxZ: number
)
    assertNumbers(x, y, z, names)
    local x = x :: number
    local y = y :: number
    local z = z :: number
    assert(
        x > 0 and x <= maxX,
        `parameter '{names[1]}' should be above 0 and below or equal to {maxX}, received {x}`
    )
    assert(
        y > 0 and y <= maxY,
        `parameter '{names[2]}' should be above 0 and below or equal to {maxY}, received {y}`
    )
    assert(
        z > 0 and z <= maxZ,
        `parameter '{names[3]}' should be above 0 and below or equal to {maxZ}, received {z}`
    )
end

function Grid3D.new<Cell>(
    sizeX: number,
    sizeY: number,
    sizeZ: number,
    defaultCell: Cell | (number, number, number) -> Cell
): Grid3D<Cell>
    if _G.DEV then
        assertNumbers(sizeX, sizeY, sizeZ, { 'sizeX', 'sizeY', 'sizeZ' })
        assert(sizeX > 0, `parameter 'sizeX' should be above 0, got {sizeX}`)
        assert(sizeY > 0, `parameter 'sizeY' should be above 0, got {sizeY}`)
        assert(sizeZ > 0, `parameter 'sizeZ' should be above 0, got {sizeZ}`)
    end

    local length = sizeX * sizeY * sizeZ
    local self: Private<Cell> = {
        _sizeX = sizeX,
        _sizeY = sizeY,
        _sizeZ = sizeZ,
        _sizeYZ = sizeY * sizeZ,
        _length = length,
        _data = table.create(length, defaultCell),
    }

    if type(defaultCell) == 'function' then
        local x = 1
        local y = 1
        local z = 0
        for i = 1, length do
            z += 1
            if z > sizeZ then
                z = 1
                y += 1
                if y > sizeY then
                    y = 1
                    x += 1
                end
            end

            self._data[i] = defaultCell(x, y, z)
        end
    end

    return setmetatable(self, Grid3DMetatable) :: any
end

function Grid3D:get<Cell>(x: number, y: number, z: number): Cell?
    local self: PrivateGrid3D<Cell> = self :: any

    if _G.DEV then
        assertNumbers(x, y, z, { 'x', 'y', 'z' })
    end

    if x > 0 and x <= self._sizeX and y > 0 and y <= self._sizeY and z > 0 and z <= self._sizeZ then
        local index = (x - 1) * self._sizeYZ + (y - 1) * self._sizeZ + z
        return self._data[index]
    end

    return nil
end

function Grid3D:set<Cell>(x: number, y: number, z: number, value: Cell): Cell
    local self: PrivateGrid3D<Cell> = self :: any

    if _G.DEV then
        assertBounds(x, y, z, { 'x', 'y', 'z' }, self._sizeX, self._sizeY, self._sizeZ)
    end

    local index = (x - 1) * self._sizeYZ + (y - 1) * self._sizeZ + z

    local previousValue = self._data[index]
    self._data[index] = value

    return previousValue
end

function Grid3D:update<Cell>(x: number, y: number, z: number, fn: (value: Cell) -> Cell?)
    local self: PrivateGrid3D<Cell> = self :: any

    if _G.DEV then
        assertBounds(x, y, z, { 'x', 'y', 'z' }, self._sizeX, self._sizeY, self._sizeZ)
    end

    local index = (x - 1) * self._sizeYZ + (y - 1) * self._sizeZ + z

    local currentValue = self._data[index]

    local nextValue = fn(currentValue)

    if nextValue ~= nil then
        self._data[index] = nextValue
    end
end

function Grid3D:size<Cell>(): (number, number, number)
    local self: PrivateGrid3D<Cell> = self :: any
    return self._sizeX, self._sizeY, self._sizeZ
end

return Grid3D
