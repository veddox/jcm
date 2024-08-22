#!/usr/bin/env julia
####
#### Janzen-Connell Model
####
#### A simple forest ecosystem model to investigate the effect of pathogen-induced
#### density-dependent mortality on tree diversity. This file uses the Agents.jl
#### library. For a pure Julia implementation, see the folder `original`.
####
#### (c) 2024 Daniel Vedder <daniel.vedder@idiv.de>
####     Licensed under the terms of the MIT license.
####

module jcmagents

const jcm_version = v"2.0"

using Agents,
    Logging,
    Random

const settings = Dict("species" => 16,              # The number of species that will be created
                      "worldsize" => 500,           # The extent from the center of the square world arena in meters
                      "runtime" => 1000,            # The number of updates the simulation will run
                      "datafile" => "jcm_data.csv", # The name of the recorded data file
                      "datafreq" => 50,             # How long between data recordings?
                      "pathogens" => false,         # Include pathogens in the simulation?
                      "transmission" => 50,         # Pathogen infection radius
                      "neutral" => false,           # All species have identical trait values?
                      "verbosity" => Logging.Info,  # The log level (Debug, Info, Warn, Error)
                      "seed" => 0)                  # The seed for the RNG (0 -> random)

include("ecology.jl")

"""
Initialise the random number generator and logger.
"""
function inithelpers()
    if settings["seed"] == 0
        settings["seed"] = abs(rand(Random.RandomDevice(), Int32))
    end
    Random.seed!(settings["seed"])
    global_logger(ConsoleLogger(stdout, settings["verbosity"]))
end


#TODO create model object
#TODO initialise model world

#TODO data collection
#TODO data visualisation

if !isinteractive()
    @time run() #TODO
end

end
