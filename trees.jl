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
    host::UInt8
    infectious::Bool
    infection_rate::Float16
    infection_radius::Int16
    lethality::Float16
end

#The default pathogen
Pathogen(host) = Pathogen(host, false, 0.8, 50, 0.1)

mutable struct Tree
    uid::Int64 #should be large enough - hopefully...
    species::Species
    age::Int16
    size::Int8
    mature::Bool
    infection::Union{Pathogen,Nothing}
    position::NamedTuple{(:x, :y), Tuple{Int16,Int16}}
end

# Store and administrate a running counter for tree UID values
let idcounter::Int64 = 0
    global function nextid()
        idcounter += 1
        return idcounter
    end

    global currentcounter() = idcounter
    global resetcounter() = idcounter = 0
end

#Create a seed
Tree(sp, xpos, ypos) = Tree(nextid(), sp, 0, 1, false, nothing, (x=xpos, y=ypos))

"""
Vary a number i randomly  by up to +/- p% (utility function)
"""
function vary(i::Number; p::Int=25)
    i == 0 && return 0
    v = (p/100) * i
    s = i/100
    if isinteger(i)
        s = 1
        v = round(typeof(i), v)
    end
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
                max_age = vary(s.max_age)
                max_size = vary(s.max_size)
                growth_rate = vary(s.growth_rate)
                seed_production = vary(s.seed_production)
                dispersal_distance = vary(s.dispersal_distance)
                pathogen_resistance = vary(s.pathogen_resistance)
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
