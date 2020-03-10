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
    # What to do once a tree has been planted
    function success()
        global forestlen += 1
        @debug "Planted a tree" tree.position.x tree.position.y
        compete!(cons) # Make sure it can grow here
    end
    if !isa(cons.car, Tree)
        # If we have an empty cons cell, plant the tree here
        cons.car = tree
        success()
    elseif tree.position.x < cons.car.position.x
        # If the next tree in the list is further east, insert a new cons cell
        newcons = Cons(tree,cons,cons.prev)
        cons.prev.cdr = newcons
        cons.prev = newcons
        cons = newcons
        success()
    else
        # If we're at the end of the list, append a new cons cell
        if cons.cdr == nothing
            cons.cdr = Cons(nothing,nothing,cons)
        end
        # Recurse down the list until we can plant the tree
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
        global forestlen -= 1
        @debug "Killed a tree" tree.position.x tree.position.y
        tree = nothing
    elseif cons.cdr == nothing
        @warn "Attempting to remove nonexistent tree."
    else
        killtree!(tree,cons.cdr)
    end
end

"""
Test whether two trees intersect. A positive return value indicates conflict.
0: no intersection; 1: the first tree is larger; 2: the second tree is larger
"""
function inconflict(tree1::Tree, tree2::Tree)::UInt8
    mindist = (tree1.size + tree2.size)/2
    dx = abs(tree1.position.x - tree2.position.x)
    dy = abs(tree1.position.y - tree2.position.y)
    if  dx >= mindist || dy >= mindist || hypot(dx,dy) >= mindist
        return 0
    else
        tree1.size > tree2.size ? 1 : 2
    end
end

"""
Check whether the tree in this cons cell conflicts with trees in the
vicinity and, if so, kill the smaller one.
"""
function compete!(cons::Cons)
    tree = cons.car
    # go right until we're sure we won't find any more conflicts
    next = cons.cdr
    while next != nothing && abs(next.car.position.x - tree.position.x) < (tree.size/2)+2^7
        conflict = inconflict(tree, next.car)
        if conflict == 2
            killtree!(tree, cons)
            return
        elseif conflict == 1
            killcell = next
            next = next.cdr
            killtree!(killcell.car, killcell)
        elseif conflict == 0
            next = next.cdr
        end
    end
    # then go left and repeat
    next = cons.prev
    while next != nothing && abs(next.car.position.x - tree.position.x) < (tree.size/2)+2^7
        conflict = inconflict(tree, next.car)
        if conflict == 2
            killtree!(tree, cons)
            return
        elseif conflict == 1
            killcell = next
            next = next.prev
            killtree!(killcell.car, killcell)
        elseif conflict == 0        
            next = next.prev
        end
    end
end

"""
Find the cons cell inhabited by this tree, then compete as above.
(wrapper function)
"""
function compete!(tree::Tree, cons::Cons=forest)
    if cons.car == tree
        compete!(cons)
    elseif cons.cdr == nothing
        @warn "Attempting to compete nonexistent tree."
    else
        compete!(tree,cons.cdr)
    end
end

"""
Produce seeds and disperse them in the landscape, planting them where possible
"""
function disperse!(tree::Tree)
    # Each tree produces multiple seeds
    for s in 1:tree.species.seed_production
        #TODO implement a proper dispersal kernel
        d = tree.species.dispersal_distance
        sx = tree.position.x + rand(-d:d)
        sy = tree.position.y + rand(-d:d)
        if sx >= -worldsize && sx <= worldsize &&
            sy >= -worldsize && sy <= worldsize
            planttree!(tree)
        end
    end
end

"""
All saplings grow until they reach maturity
"""
function grow!(cons::Cons=forest)
    if cons == nothing
        return
    else
        tree = cons.car
        if !tree.mature && tree.size < tree.species.max_size
            tree.size += tree.species.growth_rate
        elseif !tree.mature && tree.size >= tree.species.max_size
            tree.mature = true
        end
        grow!(cons.cdr)
    end
end
