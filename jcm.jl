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

const settings = Dict("nspecies" => 16,             # The number of species that will be created
                      "worldsize" => 1001,          # The width of the square world arena in meters
                      "runtime" => 1000,            # The number of updates the simulation will run
                      "datafile" => "jcm_data.csv", # The name of the recorded data file
                      "datafreq" => 10,             # How long between data recordings?
                      "pathogens" => false,         # Include pathogens in the simulation?
                      "verbosity" => "Debug")       # The log level (Debug, Info, Warn, Error)

include("trees.jl")
include("forest.jl")

"""
Set parameters from the commandline.
"""
function parsecommandline()
    s = ArgParseSettings(prog="jcm.jl", version="$jcm_version", add_help=true, add_version=true,
                         description="Investigate the Janzen-Connell effect in a forest model.",
                         epilog="JCM $jcm_version, (c) 2020 Daniel Vedder \n\nEcosystem Modelling Group, University of Würzburg")
    @add_arg_table! s begin
        "--nspecies", "-n"
        help = "the number of tree species to simulate"
        arg_type = Int
        default = settings["nspecies"]
        "--worldsize", "-w"
        help = "the width of the square simulation world in meters"
        arg_type = Int
        default = settings["worldsize"]
        "--runtime", "-t"
        help = "the number of updates the simulation will run"
        arg_type = Int
        default = settings["runtime"]
        "--datafile", "-f"
        help = "the file to which simulation data is written"
        arg_type = String
        default = settings["datafile"]
        "--datafreq", "-d"
        help = "the frequency in updates with which data is recorded"
        arg_type = Int
        default = settings["datafreq"]
        "--pathogens", "-p"
        help = "run a simulation with pathogens"
        action = :store_true
        "--verbosity", "-v"
        help = "set the log level (Debug, Info, Warn, Error)"
        arg_type = String
        default = settings["verbosity"]
    end
    return parse_args(s)
end
        

"""
Initialise the world with one mature tree from each species at a random location.
"""
function initworld()
    createspecies()
    for n in settings["nspecies"]
        halfworld = convert(Int,(settings["worldsize"]-1)/2)
        xpos = rand(-halfworld:halfworld)
        ypos = rand(-halfworld:halfworld)
        sp = getspecies(n)
        tree = Tree(sp, convert(UInt16, round(sp.max_age/2)),
                    sp.max_size, true, (x=xpos, y=ypos))
        planttree!(tree)
    end
end

let updatelog::String = "", update=1

    """
    Set the internal update counter to the current update number.
    (Needed by run())
    """
    global function setupdate(t)
        update = t
    end
    
    """
    Save the data records of one individual in this turn.
    Called during `grow!()`
    """
    global function recordindividual(tree::Tree)
        update < 0 && return # block unless we've reached a recording point
        datastring = update*","*tree.species.id*","*tree.age*","*tree.size
        datastring *= ","*tree.mature*","*tree.position.x*","*tree.position.y
        updatelog *= datastring * "\n"
    end
    
    """
    Write out a csv file with all necessary analysis data.
    """
    global function recorddata()
        open(settings["datafile"], "a") do df
            print(df,updatelog)
        end
        updatelog = ""
        update = -1 # block until the next recorded update
    end

    """
    Initialise the data file
    """
    global function initdatafile()
        open(settings["datafile"], "w") do df
            time = Dates.format(Dates.now(), "dd/mm/yyy HH:MM")
            println(df, "# Janzen-Connell Model data file, created $time")
            println(df, "Update,Species,Age,Size,Mature,X,Y")
        end
    end
end

"""
The main simulation function.
"""
function run(updates::Int=settings["runtime"])
    merge!(settings, parsecommandline())
    global_logger(ConsoleLogger(stdout, eval(
        Meta.parse("Logging.$(settings["verbosity"])"))))
    @debug "Debugging is on."
    @info "Info is on."
    @warn "This is a warning."
    @error "And here we stop."
    exit()
    initdatafile()
    initworld()
    for u in 1:updates
        @info "UPDATE $u"
        record = (u-1)%settings["datafreq"] == 0
        record && setupdate(u)
        disperse!()
        compete!()
        grow!()
        #TODO pathogen spread
        record && recorddata()
    end
end

if !isinteractive()
    run()
end

end
