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

include("trees.jl")
include("forest.jl")

function run(updates=1000)
    @warn "Not yet implemented."
    #TODO
end

end
