# Janzen-Connell Model

*See `project.md` for more information.*

## Background

The Janzen-Connell Effect explains how density-dependent mortality helps to
explain high plant diversity levels, especially in tropical rain forests. It 
postulates that high pathogen (or herbivore) pressure will lead to high seedling 
mortality in the vicinity of the mother plant, assuming that most pathogens are 
host-specific. Therefore, there will be a strong selection pressure for 
longer-range seed dispersal to ensure low population densities for each species. 
This prevents any one species from becoming dominant and thus enables stable high 
diversity levels.

## Model description

- 16 tree species (0x1 - 0xf), 1km² world

- Tree traits:
  - species ID
  - dispersal kernel
  - growth rate
  - (max) age
  - (max) size
  - seed production
  - pathogen resistance
  - life stage (seed/sapling/mature)
  
- Pathogen traits:
  - infection rate
  - infection radius
  - host species
  - lethality

- Life history:
  - mature trees produce seeds
  - seeds disperse stochastically as per the dispersal kernel
  - seeds that leave the landscape or fall inside another tree's sphere of
  influence (SOI) die
  - seeds germinate and grow until they reach maturity (= `max size`)
  - saplings that conflict with a larger tree's SOI die
  - trees that reach `max age` die
  
- Epidemiology:
  - each pathogen may infect a defined number of species (default: 1)
  - an infected tree can infect conspecifics within the `infection radius`
  - the infection probability depends on the distance between the trees, 
  the pathogen's `infection rate`, and the healthy tree's `pathogen resistance`
  - the pathogen's `lethality` determines the percentage chance of death per
  round for infected trees
  
- Main experiment:
  - all species are functionally equivalent (-> equal trait values)
  - control: pathogens excluded; treatment: pathogens present
  - measure alpha/gamma diversity over time
  
- Extended experiment:
  - vary traits between species
  - allow traits to evolve
  - test more generalistic pathogens
  - possibly also coevolution

## Usage

Running the model requires [Julia 1.3](https://julialang.org/downloads/) with the 
[ArgParse](https://argparsejl.readthedocs.io/en/latest/argparse.html#) package.

```
usage: jcm.jl [-n NSPECIES] [-w WORLDSIZE] [-t RUNTIME] [-f DATAFILE]
              [-d DATAFREQ] [-p] [-v VERBOSITY] [-s SEED] [--version]
              [-h]

Investigate the Janzen-Connell effect in a forest model.

optional arguments:
  -n, --nspecies NSPECIES
                        the number of tree species to simulate (type:
                        Int64, default: 16)
  -w, --worldsize WORLDSIZE
                        the extent from the center of the square world
                        arena in meters (type: Int64, default: 500)
  -t, --runtime RUNTIME
                        the number of updates the simulation will run
                        (type: Int64, default: 500)
  -f, --datafile DATAFILE
                        the file to which simulation data is written
                        (default: "jcm_data.csv")
  -d, --datafreq DATAFREQ
                        the frequency in updates with which data is
                        recorded (type: Int64, default: 10)
  -p, --pathogens       run a simulation with pathogens
  -v, --verbosity VERBOSITY
                        set the log level (Debug, Info, Warn, Error)
                        (default: "Info")
  -s, --seed SEED       set the seed for the RNG (0 -> random seed)
                        (type: Int64, default: 0)
  --version             show version information and exit
  -h, --help            show this help message and exit

JCM 1.0.0-rc1, (c) 2020 Daniel Vedder
Ecosystem Modelling Group, University of Würzburg
```

The visualisation script `analyse.R` requires R with the packages `ggplot2`, `ggforce`, and `gganimate`.

## Source files

- `jcm.jl` The main module file. Import this to run the model.

- `trees.jl` Contains all classes and their default values.

- `forest.jl` Contains all process functions.

- `analyse.R` Visualise model output.

## References

1. Comita, L. S., Queenborough, S. A., Murphy, S. J., Eck, J. L., Xu, K., 
Krishnadas, M., Beckman, N., & Zhu, Y. (2014). Testing predictions of the 
Janzen–Connell hypothesis: A meta-analysis of experimental evidence for 
distance- and density-dependent seed and seedling survival. Journal of Ecology, 
102(4), 845–856. [https://doi.org/10.1111/1365-2745.12232](https://doi.org/10.1111/1365-2745.12232)

2. Connell, J. H. (1971). On the role of natural enemies in preventing 
competitive exclusion in some marine animals and in rain forest trees. 
In P. J. den Boer & G. R. Gradwell (Eds.), Dynamics of Population 
(pp. 298–312). Pudoc.

3. Janzen, D. H. (1970). Herbivores and the Number of Tree Species in 
Tropical Forests. The American Naturalist, 104(940), 501–528. 
[https://doi.org/10.1086/282687](https://doi.org/10.1086/282687)

---
&copy; 2020 Daniel Vedder

*Licensed under the terms of the MIT license.*
