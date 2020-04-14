#!/usr/bin/python3
##
## Janzen-Connell Model
## Set up and run the main experiment.
## (c) Daniel Vedder, MIT license
##

import os, sys

runtime = 250 #default: 500
datafreq = 10 #default: 10

def run_model(scenario="null", n=10):
    """
    Run the model with n repetitions in the given scenario:
    "null" - no pathogens, all species have identical trait values
    "variance" - no pathogens, species trait values vary
    "pathogens" - full model: pathogens & variance
    """
    if scenario == "null": sc = " -n"
    elif scenario == "pathogens": sc = " -p"
    elif scenario == "variance": sc = ""
    else: raise Exception("Bad scenario "+scenario)
    for i in range(0,n):
        print("Running replicate "+str(i)+" of the "+scenario+" scenario.")
        df = scenario+"_"+str(i)
        cmd = "./jcm.jl -t "+str(runtime)+" -d "+str(datafreq)+" -f "+df+sc
        os.system(cmd)

if __name__=='__main__':
    scen, rep = "null", 10
    if len(sys.argv) >= 2:
        scen = sys.argv[1]
    if len(sys.argv) >= 3:
        rep = sys.argv[2]
    run_model(scen, rep)
