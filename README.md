# Janzen-Connell Model

## Background

The Janzen-Connell Effect explains how density-dependent mortality helps to
explain high plant diversity levels, especially in tropical rain forests. It 
postulates that high pathogen (or herbivore) pressure will lead to high seedling 
mortality in the vicinity of the mother plant, assuming that most pathogens are 
host-specific. Therefore, there will be a strong selection pressure for 
longer-range seed dispersal to ensure low population densities for each species. 
This prevents any one species from becoming dominant and thus enables stable high 
diversity levels.

*TODO citations*

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

## Source files

- `jcm.jl` The main module file. Import this to run the model.

- `trees.jl` Contains all classes and their default values.

- `forest.jl` Contains all process functions.

---
&copy; 2020 Daniel Vedder

*Licensed under the terms of the MIT license.*
