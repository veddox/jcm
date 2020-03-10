# A brief test script for the JCM

include("jcm.jl")

tr1 = jcm.Tree(jcm.Species(1), 0, 0)
tr2 = jcm.Tree(jcm.Species(2), 5, 3)
tr3 = jcm.Tree(jcm.Species(3), 4, -1)

tr4 = jcm.Tree(jcm.Species(4), 4, 0)
tr4.size = 3

jcm.planttree!(tr1)
jcm.planttree!(tr2)
jcm.planttree!(tr3)
