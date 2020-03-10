###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

const worldsize = 1000

"""
A cons cell to implement a double linked list for the forest
(Boy, do I miss Lisp :-/ )
"""
mutable struct Cons
    car::Union{Tree,Nothing}
    cdr::Union{Cons,Nothing}
    prev::Union{Cons,Nothing}
end

# The first and last cons cells in the forest list, and the number of trees
const forest = Cons(nothing,nothing,nothing)
forestend = forest
forestlen = 0

"""
Insert a new tree object at the correct position in the forest list.
(Sorted by ascending x values.)
"""
function planttree!(tree::Tree,cons::Cons=forest)
    if !isa(cons.car, Tree)
        cons.car = tree
        global forestlen = forestlen+1
    elseif tree.position.x < cons.car.position.x
        newcons = Cons(tree,cons,cons.prev)
        cons.prev.cdr = newcons
        cons.prev = newcons
        global forestlen = forestlen+1
    else
        if cons.cdr == nothing
            cons.cdr = Cons(nothing,nothing,cons)
            global forestend = cons.cdr
        end
        planttree!(tree,cons.cdr)
    end
end
