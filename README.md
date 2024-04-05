[![checks](https://github.com/seaofvoices/luau-grids/actions/workflows/test.yml/badge.svg)](https://github.com/seaofvoices/luau-grids/actions/workflows/test.yml)
![version](https://img.shields.io/github/package-json/v/seaofvoices/luau-grids)
[![GitHub top language](https://img.shields.io/github/languages/top/seaofvoices/luau-grids)](https://github.com/luau-lang/luau)
![license](https://img.shields.io/npm/l/luau-grids)
![npm](https://img.shields.io/npm/dt/luau-grids)

# luau-grids

A fully typed Luau library for handling grids (2D or 3D) of values.

## Installation

Add `luau-grids` in your dependencies:

```bash
yarn add luau-grids
```

Or if you are using `npm`:

```bash
npm install luau-grids
```

## Content

### Grid2D

Create a new 2D grid with a specified size and default cell value.

This class and its type are accessible from the module root:

```lua
-- note that the require may differ depending on your Lua environment
local grids = require('@pkg/luau-grids')

local Grid2D = grids.Grid2D
type Grid2D<Cell> = grids.Grid2D<Cell>
```

####  `Grid2D.new`

```lua
Grid2D.new<Cell>(
    sizeX: number,
    sizeY: number,
    defaultCell: Cell | (x: number, y: number) -> Cell
) -> Grid2D<Cell>
```

Creates a new 2D grid with the specified dimensions and default cell value.

```lua
local grid = Grid2D.new(3, 3, 0) -- 3x3 grid with default value 0
```

The `defaultCell` value can be an initializer function that gets called for every cell position in the grid that must return a non-`nil` value.

#### `Grid2D:get`

```lua
Grid2D:get(x: number, y: number) -> Cell?
```

Gets the value of the cell at the specified coordinates.

```lua
local value = grid:get(1, 1) -- Get value at position (1, 1)
```

#### `Grid2D:set`

```lua
Grid2D:set(x: number, y: number, value: Cell) -> Cell
```

Sets the value of the cell at the specified coordinates and returns the previous value.

```lua
grid:set(2, 2, 42) -- Set value 42 at position (2, 2)
```

#### `Grid2D:update`

```lua
Grid2D:update(x: number, y: number, fn: (value: Cell) -> Cell?) -> ()
```

Updates the value of the cell at the specified coordinates using the provided function.

```lua
-- Increment value at position (1, 1) by 1
grid:update(1, 1, function(value)
    return value + 1
end)
```

#### `Grid2D:size`

```lua
Grid2D:size() -> (number, number)
```

Returns the size of the 2D grid as a tuple (sizeX, sizeY).

```lua
local sizeX, sizeY = grid:size()
```

### Grid3D

Create a new 3D grid with a specified size and default cell value.

This class and its type are accessible from the module root:

```lua
-- note that the require may differ depending on your Lua environment
local grids = require('@pkg/luau-grids')

local Grid3D = grids.Grid3D
type Grid3D<Cell> = grids.Grid3D<Cell>
```

#### `Grid3D.new`

```lua
Grid3D.new<Cell>(
    sizeX: number,
    sizeY: number,
    sizeZ: number,
    defaultCell: Cell | (x: number, y: number, z: number) -> Cell
) -> Grid3D<Cell>
```

Creates a new 3D grid with the specified dimensions and default cell value.

```lua
local grid = Grid3D.new(3, 3, 3, "empty") -- 3x3x3 grid with default value "empty"
```

The `defaultCell` value can be an initializer function that gets called for every cell position in the grid that must return a non-`nil` value.

#### `Grid3D:get`

```lua
Grid3D:get(x: number, y: number, z: number) -> Cell?
```

Gets the value of the cell at the specified coordinates.

```lua
local value = grid:get(1, 1, 1) -- Get value at position (1, 1, 1)
```

#### `Grid3D:set`

```lua
Grid3D:set(x: number, y: number, z: number, value: Cell) -> Cell
```

Sets the value of the cell at the specified coordinates and returns the previous value.

```lua
grid:set(2, 2, 2, "occupied") -- Set value "occupied" at position (2, 2, 2)
```

#### `Grid3D:update`

```lua
Grid3D:update(x: number, y: number, z: number, fn: (value: Cell) -> Cell?) -> ()
```

Updates the value of the cell at the specified coordinates using the provided function.

```lua
grid:update(1, 1, 1, function(value) return value .. "_updated" end) -- Append "_updated" to value at position (1, 1, 1)
```

#### `Grid3D:size`

```lua
Grid3D:size() -> (number, number, number)
```

Returns the size of the 3D grid as a tuple (sizeX, sizeY, sizeZ).

```lua
local sizeX, sizeY, sizeZ = grid:size()
```

## Other Lua Environments Support

If you would like to use this library on a Lua environment, where it is currently incompatible, open an issue (or comment on an existing one) to request the appropriate modifications.

The library uses [darklua](https://github.com/seaofvoices/darklua) to process its code.

## License

This project is available under the MIT license. See [LICENSE.txt](LICENSE.txt) for details.
