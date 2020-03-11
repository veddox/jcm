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

using Dates
using Logging
global_logger(ConsoleLogger(stdout, Logging.Debug))

const nspecies = 16     # The number of species that will be created
const worldsize = 1000  # The width of the square world arena in meters
const runlength = 1000  # The number of updates the simulation will run
const datafile = "jcm_data.csv" # The name of the recorded data file

include("trees.jl")
include("forest.jl")

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


let updatelog::String = ""
    """
    Save the data records of one individual in this turn.
    Called during `grow!()`
    """
    function recordindividual(tree::Tree)
        datastring = tree.species.id*","*tree.age*","*tree.size*","*tree.mature*","*tree.position.x*","*tree.position.y
        updatelog *= datastring * "\n"
    end
    
    """
    Write out a csv file with all necessary analysis data.
    """
    function recorddata(dfile::String=datafile)
        open(dfile, "a") do df
            print(df,updatelog)
        end
        updatelog = ""
    end

    """
    Initialise the data file
    """
    function initdatafile(dfile::String=datafile)
        open(dfile, "w") do df
            time = Dates.format(Dates.now(), "dd/mm/yyy HH:MM")
            println(df, "# Janzen-Connell Model data file, created $time")
            println(df, "Species,Age,Size,Mature,X,Y")
        end
    end
end

"""
The main simulation function.
"""
function run(updates::UInt16=runlength)
    @warn "Incomplete implementation."
    #TODO load settings
    initdatafile()
    initworld()
    for u in 1:updates
        @inform "UPDATE $u"
        disperse!()
        compete!()
        grow!()
        #TODO pathogen spread
        #TODO record data
    end
end

end
