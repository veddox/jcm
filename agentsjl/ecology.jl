###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

"""
    Pathogen

A struct storing the variables for a species-specific pathogen.
"""
@kwdef struct Pathogen
    infectious::Bool = false
    infection_rate::Float16 = 0.8
    infection_radius::Int16 = 0
    lethality::Float16 = 0.05
end

"""
    Species

A struct storing all species-specific variables.
"""
@kwdef struct Species
    id::UInt8 # < 256
    max_age::Int16 = 150 # < 32768
    max_size::Int8 = 25 # < 128m
    growth_rate::Int8 = 2
    seed_production::Int16 = 10
    dispersal_distance::Int16 = 200
    pathogen_resistance::Float16 = 0
    pathogen::Pathogen = Pathogen()
end

"""
    Tree

The core agent type of the model, a single tropical tree.
"""
@agent struct Tree(ContinuousAgent{2,Float64})
    species::Species
    age::Int16
    size::Int8
    mature::Bool
    infected::Bool
end

"Initialise a tree based on its species (to be used during model initialisation)."
Tree(s::Species) = Tree(s, Int(round(s.max_age/2)), s.max_size, true, settings["pathogens"])

function updatetree!(tree:Tree, model::AgentBasedModel)
    #TODO dispersal
    #TODO competition
    #TODO infection
    #TODO growth
end
