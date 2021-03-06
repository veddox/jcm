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

const jcm_version = v"1.0"

using Dates,
    ArgParse,
    Logging,
    Random

const settings = Dict("species" => 16,              # The number of species that will be created
                      "worldsize" => 500,           # The extent from the center of the square world arena in meters
                      "runtime" => 500,             # The number of updates the simulation will run
                      "datafile" => "jcm_data.csv", # The name of the recorded data file
                      "datafreq" => 10,             # How long between data recordings?
                      "pathogens" => false,         # Include pathogens in the simulation?
                      "transmission" => 50,         # Pathogen infection radius
                      "neutral" => false,           # All species have identical trait values?
                      "verbosity" => "Info",        # The log level (Debug, Info, Warn, Error)
                      "seed" => 0)                  # The seed for the RNG (0 -> random)

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
        "--species", "-s"
        help = "the number of tree species to simulate"
        arg_type = Int
        default = settings["species"]
        "--worldsize", "-w"
        help = "the extent from the center of the square world arena in meters"
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
        "--transmission", "-i"
        help = "maximum pathogen infection radius"
        arg_type = Int
        default = settings["transmission"]
        "--neutral", "-n"
        help = "all species have identical trait values"
        action = :store_true
        "--verbosity", "-v"
        help = "set the log level (Debug, Info, Warn, Error)"
        arg_type = String
        default = settings["verbosity"]
        "--seed", "-r"
        help = "set the seed for the RNG (0 -> random seed)"
        arg_type = Int
        default = settings["seed"]
    end
    return parse_args(s)
end

"""
Initialise the random number generator.
"""
function initRNG()
    if settings["seed"] == 0
        settings["seed"] = abs(rand(Random.RandomDevice(), Int32))
    end
    Random.seed!(settings["seed"])
end

"""
Initialise the world with one mature tree from each species at a random location.
"""
function initworld()
    createspecies()
    for n in 1:settings["species"]
        ws = settings["worldsize"]
        xpos = rand(-ws:ws)
        ypos = rand(-ws:ws)
        sp = getspecies(n)
        settings["pathogens"] ? infection = Pathogen(n) : infection = nothing
        tree = Tree(nextid(), sp, convert(Int16, round(sp.max_age/2)),
                    sp.max_size, true, infection, (x=xpos, y=ypos))
        recordindividual(tree)
        planttree!(tree)
    end
end

let updatelog::String = "", update::Int=0
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
        datastring = "$update,$(tree.species.id),$(tree.uid),$(tree.age),$(tree.size)"
        datastring *= ",$(tree.mature ? "TRUE" : "FALSE"),$(tree.infection == nothing ? "FALSE" : "TRUE")"
        datastring *= ",$(tree.position.x),$(tree.position.y)"
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
    Initialise the data file and the logger.
    """
    global function initrecording()
        global_logger(ConsoleLogger(stdout, eval(
            Meta.parse("Logging.$(settings["verbosity"])"))))
        open(settings["datafile"], "w") do df
            time = Dates.format(Dates.now(), "dd/mm/yyy HH:MM")
            println(df, "# Janzen-Connell Model data file, created $time")
            println(df, "# settings = $settings")
            println(df, "update,species,uid,age,size,mature,infected,x,y")
        end
    end
end

"""
The main simulation function.
"""
function run(noinit::Bool=false)
    merge!(settings, parsecommandline())
    initRNG()
    initrecording()
    if !noinit #intended for use by test functions
        @info "Initialising the world"
        initworld()
    end
    recorddata()
    for u in 1:settings["runtime"]
        @info "UPDATE $u"
        record = u%settings["datafreq"] == 0
        record && setupdate(u)
        @info "Dispersal"
        disperse!()
        @info "Competition"
        compete!()
        if settings["pathogens"]
            @info "Infection"
            infect!()
        end
        @info "Growth"
        grow!() # includes data recording
        record && recorddata()
    end
end

if !isinteractive()
    @time run()
end

end
