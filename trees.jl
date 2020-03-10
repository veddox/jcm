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

mutable struct Tree
    species::Species
    age::UInt16
    size::UInt8
    mature::Bool
    position::NamedTuple{(:x, :y), Tuple{Int16,Int16}}
end

#The default species
Species(id) = Species(id, 500, 25, 2, 50, 200, 0)

#Create a seed
Tree(sp, xpos, ypos) = Tree(sp, 0, 1, false, (x=xpos, y=ypos))

"""
Produce seeds and disperse them in the landscape, planting them where possible
"""
function disperse!(tree::Tree)
    # Each tree produces multiple seeds
    for s in 1:tree.species.seed_production
        #TODO implement a proper dispersal kernel
        d = tree.species.dispersal_distance
        sx = tree.position.x + rand(-d:d)
        sy = tree.position.y + rand(-d:d)
        if sx >= -worldsize && sx <= worldsize &&
            sy >= -worldsize && sy <= worldsize
            planttree!(tree)
        end
    end
end

"""
All saplings grow until they reach maturity
"""
function grow!(cons::Cons=forest)
    if cons == nothing
        return
    else
        tree = cons.car
        if !tree.mature && tree.size < tree.species.max_size
            tree.size += tree.species.growth_rate
        elseif !tree.mature && tree.size >= tree.species.max_size
            tree.mature = true
        end
        grow!(cons.cdr)
    end
end
