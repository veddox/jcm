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
Species(id) = Species(id, 200, 25, 2, 20, 200, 0)

mutable struct Tree
    species::Species
    age::Int16
    size::Int8
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

let species::Vector{Species} = Vector{Species}(undef,settings["nspecies"])

    """
    Initialise all species. If `default` is true, use the standard trait values,
    otherwise create variable species.
    """
    global function createspecies(default=true)
        !default && @error "Variable species are not yet implemented."
        for n in settings["nspecies"]
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
