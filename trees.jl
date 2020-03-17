###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

struct Species
    id::UInt8 # < 256
    max_age::Int16 # < 32768
    max_size::Int8 # < 128m
    growth_rate::Int8
    seed_production::Int16
    dispersal_distance::Int16
    pathogen_resistance::Float16
end

#The default species
Species(id) = Species(id, 150, 25, 2, 10, 200, 0)

mutable struct Pathogen
    infectious::Bool
    infection_rate::Float16
    infection_radius::Int16
    lethality::Float16
    host::UInt8
end

#The default pathogen
Pathogen(host) = Pathogen(false, 0.8, 50, 0.1, host)

mutable struct Tree
    #TODO individual ID?
    species::Species
    age::Int16
    size::Int8
    mature::Bool
    infection::Union{Pathogen,Nothing}
    position::NamedTuple{(:x, :y), Tuple{Int16,Int16}}
end

#Create a seed
Tree(sp, xpos, ypos) = Tree(sp, 0, 1, false, nothing, (x=xpos, y=ypos))

let species::Vector{Species} = Vector{Species}(undef,settings["nspecies"])

    """
    Initialise all species. If `default` is true, use the standard trait values,
    otherwise create variable species.
    """
    global function createspecies(default=true)
        !default && @error "Variable species are not yet implemented."
        for n in 1:settings["nspecies"]
            species[n] = Species(n)
        end
    end

    """
    Return the species object with this ID.
    """
    global function getspecies(id)
        return species[id]
    end

    #XXX Do I need a reset() function?    
end
