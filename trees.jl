###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

struct Species
    id::UInt8
    max_age::UInt16
    max_size::UInt8
    growth_rate::UInt8
    seed_production::UInt16
    pathogen_resistance::Float16
end

mutable struct Tree
    species::Species
    age::UInt16
    size::UInt8
    mature::Bool
    position::NamedTuple{(:x, :y), Tuple{Int16,Int16}}
end

#The default species
Species(id) = Species(id, 500, 25, 1, 50, 0)

#Create a seed
Tree(sp, xpos, ypos) = Tree(sp, 0, 0, false, (x=xpos, y=ypos))
    
