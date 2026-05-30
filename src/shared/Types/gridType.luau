export type GridCell = {
    position: {number & number}, -- Será com vector3 no final
    occupied: boolean,
    occupant: Instance | nil,
}

export type Grid = {
    [string]: GridCell
}

return {}