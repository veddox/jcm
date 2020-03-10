####
#### Janzen-Connell Model
####
#### A simple forest ecosystem model to investigate the effect of pathogen-
#### induced density-dependent mortality on tree diversity.
####
#### (c) 2020 Daniel Vedder <daniel.vedder@stud-mail.uni-wuerzburg.de>
####     Licensed under the terms of the MIT license.
####

module jcm

using Logging
global_logger(ConsoleLogger(stdout, Logging.Debug))

const nspecies = 16     # The number of species that will be created
const worldsize = 1000  # The width of the square world arena in meters

include("trees.jl")
include("forest.jl")

function initialise()
    @warn "Not yet implemented."
    #TODO begin with one mature tree of each species
end

function run(updates::UInt16=1000)
    @warn "Not yet complete."
    initialise()
    for u in 1:updates
        disperse!()
        compete!()
        grow!()
        #TODO pathogen spread
        #TODO record data
    end
end

end
