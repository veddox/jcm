###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

const nspecies = 16     # The number of species that will be created
const worldsize = 1000  # The width of the square world arena in meters

"""
A cons cell to implement a double linked list for the forest
(Boy, do I miss Lisp :-/ )
"""
mutable struct Cons
    car::Union{Tree,Nothing}   # The Tree object held by this cell
    cdr::Union{Cons,Nothing}   # A pointer to the next cell down the line
    prev::Union{Cons,Nothing}  # A pointer to the previous cell
end

# The first cons cells in the forest list, and the number of trees
const forest = Cons(nothing,nothing,nothing)
forestlen = 0

"""
Insert a new tree object at the correct position in the forest list.
(Sorted by ascending x values.)
"""
function planttree!(tree::Tree,cons::Cons=forest)
    if !isa(cons.car, Tree)
        cons.car = tree
        global forestlen = forestlen+1
        @debug "Planted a tree" tree.position.x tree.position.y
    elseif tree.position.x < cons.car.position.x
        newcons = Cons(tree,cons,cons.prev)
        cons.prev.cdr = newcons
        cons.prev = newcons
        global forestlen = forestlen+1
        @debug "Planted a tree" tree.position.x tree.position.y
    else
        if cons.cdr == nothing
            cons.cdr = Cons(nothing,nothing,cons)
        end
        planttree!(tree,cons.cdr)
    end
end

"""
Remove a tree from the forest list.
(Don't let Idefix see this function :D )
"""
function killtree!(tree::Tree,cons::Cons=forest)
    if cons.car == tree
        if cons.prev != nothing #excise a cons cell from the list
            cons.prev.cdr = cons.cdr
            cons.cdr != nothing ? cons.cdr.prev = cons.prev : nothing
            cons = nothing
        else
            #removing the first tree is a bit more tricky, because the
            #first cons cell (global variable `forest`) mustn't be deleted
            if cons.cdr != nothing
                cons.car = cons.cdr.car
                cons.cdr.cdr != nothing ? cons.cdr.cdr.prev = cons : nothing
                cons.cdr = cons.cdr.cdr
            else
                cons.car = nothing
            end
        end
        #cleanup and decrease the tree count
        global forestlen = forestlen-1
        @debug "Killed a tree" tree.position.x tree.position.y
        tree = nothing
    elseif cons.cdr == nothing
        @warn "Attempting to remove nonexistent tree."
    else
        killtree!(tree,cons.cdr)
    end
end
