# A brief test script for the JCM

include("jcm.jl")

function testplanting()
    tr1 = jcm.Tree(jcm.Species(1), 0, 0)
    tr2 = jcm.Tree(jcm.Species(2), 5, 3)
    tr3 = jcm.Tree(jcm.Species(3), 4, -1)
    jcm.planttree!(tr1)
    jcm.planttree!(tr2)
    jcm.planttree!(tr3)
    println(jcm.forest)
end

function testcompetition()
    # Expected outcome:
    # Update 1: tr2 & tr3 killed (overlapped by tr1)
    # Update 2: tr1 killed (overlapped by tr4)
    # Update 3: tr4 & tr5 survive
    tr1 = jcm.Tree(jcm.Species(1), 0, 0)
    tr2 = jcm.Tree(jcm.Species(2), -2, 3)
    tr3 = jcm.Tree(jcm.Species(3), 0, -2)
    tr4 = jcm.Tree(jcm.Species(4), 4, 7)
    tr5 = jcm.Tree(jcm.Species(5), 12, 27)
    tr1.size = 5
    tr2.size = 3
    tr3.size = 1
    tr4.size = 11
    tr5.size = 9
    jcm.planttree!(tr1)
    jcm.planttree!(tr2)
    jcm.planttree!(tr3)
    jcm.planttree!(tr4)
    jcm.planttree!(tr5)
    jcm.recordindividual(tr1)
    jcm.recordindividual(tr2)
    jcm.recordindividual(tr3)
    jcm.recordindividual(tr4)
    jcm.recordindividual(tr5)
    jcm.settings["verbosity"] = "Debug"
    jcm.settings["datafile"] = "jcm_test_data.csv"
    jcm.settings["datafreq"] = 1
    jcm.run(3, true)
    println(jcm.forest)
end
