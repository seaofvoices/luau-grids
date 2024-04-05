local Grid2D = require('./Grid2D')
local Grid3D = require('./Grid3D')

export type Grid2D<Cell> = Grid2D.Grid2D<Cell>
export type Grid3D<Cell> = Grid3D.Grid3D<Cell>

return {
    Grid2D = Grid2D,
    Grid3D = Grid3D,
}
