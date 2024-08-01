#!/usr/bin/python3
##
## Janzen-Connell Model
## Set up and run the main experiment.
## (c) Daniel Vedder, MIT license
##

import os, sys

analyse = True
logging = True
runtime = 1000 #default: 500
datafreq = 50  #default: 10

def run_model(scenario="null", n=10, b=0):
    """
    Run the model with n repetitions in the given scenario:
    "null" - no pathogens, all species have identical trait values
    "nopat" - no pathogens, species trait values vary
    "lopat" - traits vary, pathogens with transmission = 40 
    "hipat" - traits vary, pathogens with transmission = 200
    """
    # Configure neutral/pathogen flags
    if scenario == "null": sc = " -n"
    elif scenario == "nopat": sc = ""
    elif scenario == "hipat" or scenario == "lopat": sc = " -p"
    else: raise Exception("Bad scenario "+scenario)
    # Configure transmission (infection radius)
    tr = ""
    if scenario == "hipat": tr = " -i 200"
    elif scenario == "lopat": tr = " -i 40"
    # Construct and run the simulation commands
    for i in range(b,b+n):
        print("Running replicate "+str(i)+" of the "+scenario+" scenario.")
        df = scenario+"_"+str(i)+".csv"
        if logging: log = df[:-4]+".log"
        cmd = "./jcm.jl -t "+str(runtime)+" -d "+str(datafreq)+" -f "+df+sc+tr
        if logging: cmd = cmd+" | tee "+log
        os.system(cmd)
        if analyse: os.system("./analyse.R "+df)

# Parse commandline args and run the experiment
if __name__=='__main__':
    scen, rep, br = "null", 10, 0
    # arg1: scenario (one of "null", "nopat", "lopat", "hipat")
    if len(sys.argv) >= 2:
        scen = sys.argv[1]
    # arg2: number of replicates (default: 10)
    if len(sys.argv) >= 3:
        rep = int(sys.argv[2])
    # arg3: numbering offset for replicates (when parallel processing)
    if len(sys.argv) >= 4:
        br = int(sys.argv[3])
    run_model(scen, rep, br)
