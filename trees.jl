###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

struct Species
    id::UInt8
    max_age::UInt
    max_size::UInt
    growth_rate::UInt
    seed_production::UInt
    pathogen_resistance::Float16
end

mutable struct Tree
    species::Species
    age::UInt
    size::UInt
    mature::Bool
    position::NamedTuple{(:x, :y), Tuple{Int,Int}}
end

#The default species
Species(id) = Species(id, 500, 25, 1, 50, 0)

#Create a seed
Tree(sp, xpos, ypos) = Tree(sp, 0, 0, false, (x=xpos, y=ypos))
    
