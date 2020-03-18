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

"""
Vary a number i randomly  by up to +/- p% (utility function)
"""
function vary(i::Number; p::Int=25)
    i == 0 && return 0
    v = (p/100) * i
    isa(i, AbstractFloat) ? s = i/100 : s = 1
    n = i + rand(-v:s:v)
    return n
end

let species::Vector{Species} = Vector{Species}(undef,settings["species"])

    """
    Initialise all species. If `default` is true, use the standard trait values,
    otherwise create variable species.
    """
    global function createspecies()
        for n in 1:settings["species"]
            s = Species(n)
            if settings["neutral"]
                species[n] = s
            else
                max_age = convert(Int, round(vary(s.max_age)))
                max_size = convert(Int, round(vary(s.max_size)))
                growth_rate = convert(Int, round(vary(s.growth_rate)))
                seed_production = convert(Int, round(vary(s.seed_production)))
                dispersal_distance = convert(Int, round(vary(s.dispersal_distance)))
                pathogen_resistance = convert(Int, round(vary(s.pathogen_resistance)))
                species[n] = Species(n, max_age, max_size, growth_rate,
                                     seed_production, dispersal_distance, pathogen_resistance)
            end
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
