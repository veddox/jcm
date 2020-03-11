#!/usr/bin/env julia
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

const jcm_version = v"1.0-rc1"

using Dates
using ArgParse
using Logging
global_logger(ConsoleLogger(stdout, Logging.Debug))

#TODO move to a settings dict
const nspecies = 16     # The number of species that will be created
const worldsize = 1000  # The width of the square world arena in meters
const runtime = 10  # The number of updates the simulation will run
const datafile = "jcm_data.csv" # The name of the recorded data file
const datafreq = 1       # How long between data recordings?

include("trees.jl")
include("forest.jl")

"""
Set parameters from the commandline.
"""
function parsecommandline()
    s = ArgParseSettings(prog="jcm.jl", version="$jcm_version", add_help=true, add_version=true,
                         description="Investigate the Janzen-Connell effect in a forest model.",
                         epilog="Daniel Vedder, Ecosystem Modelling Group, University of Würzburg")
    @add_arg_table! s begin
        "--nspecies", "-n"
        help = "the number of tree species to simulate"
        arg_type = Int
        default = 16
        "--worldsize", "-w"
        help = "the width of the square simulation world in meters"
        arg_type = Int
        default = 1000
        "--runtime", "-t"
        help = "the number of updates the simulation will run"
        arg_type = Int
        default = 1000
        "--datafile", "-f"
        help = "the file to which simulation data is written"
        arg_type = String
        default = "jcm_data.csv"
        "--datafreq", "-d"
        help = "the frequency in updates with which data is recorded"
        arg_type = Int
        default = 50
        "--pathogens", "-p"
        help = "run a simulation with pathogens"
        action = :store_true
    end
    return parse_args(s)
end
        

"""
Initialise the world with one mature tree from each species at a random location.
"""
function initworld()
    createspecies()
    for n in nspecies
        xpos = convert(Int,rand(0:worldsize-1)-round(worldsize/2))
        ypos = convert(Int,rand(0:worldsize-1)-round(worldsize/2))
        sp = getspecies(n)
        tree = Tree(sp, convert(UInt16, round(sp.max_age/2)),
                    sp.max_size, true, (x=xpos, y=ypos))
        planttree!(tree)
    end
end

let updatelog::String = "", update=1
    """
    Save the data records of one individual in this turn.
    Called during `grow!()`
    """
    global function recordindividual(tree::Tree)
        datastring = update*","*tree.species.id*","*tree.age*","*tree.size
        datastring *= ","*tree.mature*","*tree.position.x*","*tree.position.y
        updatelog *= datastring * "\n"
    end
    
    """
    Write out a csv file with all necessary analysis data.
    """
    global function recorddata(next_update::UInt16)
        open(datafile, "a") do df
            print(df,updatelog)
        end
        updatelog = ""
        update = next_update
    end

    """
    Initialise the data file
    """
    global function initdatafile()
        open(datafile, "w") do df
            time = Dates.format(Dates.now(), "dd/mm/yyy HH:MM")
            println(df, "# Janzen-Connell Model data file, created $time")
            println(df, "Update,Species,Age,Size,Mature,X,Y")
        end
    end
end

"""
The main simulation function.
"""
function run(updates::Int=runtime)
    @warn "Incomplete implementation."
    parsecommandline()
    initdatafile()
    initworld()
    for u in 1:updates
        @info "UPDATE $u"
        disperse!()
        compete!()
        grow!()
        #TODO pathogen spread
        (u-1)%datafreq == 0 && recorddata(u+records)
    end
end

if !isinteractive()
    run()
end

end
