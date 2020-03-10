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
    dispersal_distance::UInt16
    pathogen_resistance::Float16
end

#The default species
Species(id) = Species(id, 500, 25, 2, 50, 200, 0)

mutable struct Tree
    species::Species
    age::UInt16
    size::UInt8
    mature::Bool
    position::NamedTuple{(:x, :y), Tuple{Int16,Int16}}
end

#Create a seed
Tree(sp, xpos, ypos) = Tree(sp, 0, 1, false, (x=xpos, y=ypos))

mutable struct Pathogen
    infection_rate::Float16
    infection_radius::UInt16
    lethality::Float16
    host::UInt8
end

#The default pathogen
Pathogen(host) = Pathogen(0.5, 100, 0.1, host)
