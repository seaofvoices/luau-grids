export type Grid2D<Cell> = {
    get: (self: Grid2D<Cell>, x: number, y: number) -> Cell?,
    set: (self: Grid2D<Cell>, x: number, y: number, value: Cell) -> Cell,
    update: (self: Grid2D<Cell>, x: number, y: number, fn: (value: Cell) -> Cell?) -> (),
    size: (self: Grid2D<Cell>) -> (number, number),
    width: (self: Grid2D<Cell>) -> number,
    height: (self: Grid2D<Cell>) -> number,
}

type Private<Cell> = {
    _sizeX: number,
    _sizeY: number,
    _length: number,
    _data: { Cell },
}

type PrivateGrid2D<Cell> = Grid2D<Cell> & Private<Cell>

type Grid2DStatic = {
    new: <Cell>(
        sizeX: number,
        sizeY: number,
        defaultCell: Cell | (x: number, y: number) -> Cell
    ) -> Grid2D<Cell>,

    get: <Cell>(self: Grid2D<Cell>, x: number, y: number) -> Cell?,
    set: <Cell>(self: Grid2D<Cell>, x: number, y: number, value: Cell) -> Cell,
    update: <Cell>(self: Grid2D<Cell>, x: number, y: number, fn: (value: Cell) -> Cell?) -> (),
    size: <Cell>(self: Grid2D<Cell>) -> (number, number),
    width: <Cell>(self: Grid2D<Cell>) -> number,
    height: <Cell>(self: Grid2D<Cell>) -> number,
}

local Grid2D: Grid2DStatic = {} :: any
local Grid2DMetatable = {
    __index = Grid2D,
    __iter = function<Cell>(self: PrivateGrid2D<Cell>)
        local sizeY = self._sizeY
        local i = 0
        local length = self._length

        local function nextItem(data): (number?, number?, Cell?)
            if i >= length then
                return nil
            end

            local x = 1 + math.floor(i / sizeY)
            local y = 1 + i % sizeY
            i += 1
            local item = data[i]
            return x, y, item
        end
        return nextItem, self._data
    end,
}

local function assertNumbers(x: unknown, y: unknown, names: { string })
    assert(type(x) == 'number', `parameter '{names[1]}' should be a number, received '{type(x)}'`)
    assert(type(y) == 'number', `parameter '{names[2]}' should be a number, received '{type(y)}'`)
end

local function assertBounds(x: unknown, y: unknown, names: { string }, maxX: number, maxY: number)
    assertNumbers(x, y, names)
    local x = x :: number
    local y = y :: number
    assert(
        x > 0 and x <= maxX,
        `parameter '{names[1]}' should be above 0 and below or equal to {maxX}, received {x}`
    )
    assert(
        y > 0 and y <= maxY,
        `parameter '{names[2]}' should be above 0 and below or equal to {maxY}, received {y}`
    )
end

function Grid2D.new<Cell>(
    sizeX: number,
    sizeY: number,
    defaultCell: Cell | (number, number) -> Cell
): Grid2D<Cell>
    if _G.DEV then
        assertNumbers(sizeX, sizeY, { 'sizeX', 'sizeY' })
        assert(sizeX > 0, `parameter 'sizeX' should be above 0, got {sizeX}`)
        assert(sizeY > 0, `parameter 'sizeY' should be above 0, got {sizeY}`)
    end

    local length = sizeX * sizeY
    local self: Private<Cell> = {
        _sizeX = sizeX,
        _sizeY = sizeY,
        _length = length,
        _data = table.create(length, defaultCell),
    }

    if type(defaultCell) == 'function' then
        for i = 1, length do
            local x = math.ceil(i / sizeY)
            local y = 1 + (i - 1) % sizeY
            self._data[i] = defaultCell(x, y)
        end
    end

    return setmetatable(self, Grid2DMetatable) :: any
end

function Grid2D:get<Cell>(x: number, y: number): Cell?
    local self: PrivateGrid2D<Cell> = self :: any

    if _G.DEV then
        assertBounds(x, y, { 'x', 'y' }, self._sizeX, self._sizeY)
    end

    if x > 0 and x <= self._sizeX and y > 0 and y <= self._sizeY then
        local index = (x - 1) * self._sizeY + y
        return self._data[index]
    end

    return nil
end

function Grid2D:set<Cell>(x: number, y: number, value: Cell): Cell
    local self: PrivateGrid2D<Cell> = self :: any

    if _G.DEV then
        assertBounds(x, y, { 'x', 'y' }, self._sizeX, self._sizeY)
    end

    local index = (x - 1) * self._sizeY + y

    local previousValue = self._data[index]
    self._data[index] = value

    return previousValue
end

function Grid2D:update<Cell>(x: number, y: number, fn: (value: Cell) -> Cell?)
    local self: PrivateGrid2D<Cell> = self :: any

    if _G.DEV then
        assertBounds(x, y, { 'x', 'y' }, self._sizeX, self._sizeY)
    end

    local index = (x - 1) * self._sizeY + y

    local currentValue = self._data[index]

    local nextValue = fn(currentValue)

    if nextValue ~= nil then
        self._data[index] = nextValue
    end
end

function Grid2D:size<Cell>(): (number, number)
    local self: PrivateGrid2D<Cell> = self :: any
    return self._sizeX, self._sizeY
end

function Grid2D:width<Cell>(): number
    local self: PrivateGrid2D<Cell> = self :: any
    return self._sizeX
end

function Grid2D:height<Cell>(): number
    local self: PrivateGrid2D<Cell> = self :: any
    return self._sizeY
end

return Grid2D
