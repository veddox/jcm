###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

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
forestlen = 0 #XXX do I actually need this?

"""
Insert a new tree object at the correct position in the forest list.
(Sorted by ascending x values.)
"""
function planttree!(tree::Tree,cons::Cons=forest)
    while cons != nothing
        if !isa(cons.car, Tree)
            # If we have an empty cons cell, plant the tree here
            cons.car = tree
            global forestlen += 1
            @debug "Planted tree @$(tree.position.x)/$(tree.position.y)"
            return
        elseif tree.position.x < cons.car.position.x
            # If the next tree in the list is further east, insert a new cons cell
            if cons.prev != nothing #inserting in the middle
                newcons = Cons(tree,cons,cons.prev)                
                cons.prev.cdr = newcons
                cons.prev = newcons
            else #if we're inserting before the first cell
                newcons = Cons(cons.car, cons.cdr, cons)
                cons.car = tree
                cons.cdr = newcons
            end
            global forestlen += 1
            @debug "Planted tree @$(tree.position.x)/$(tree.position.y)"
            return
        elseif cons.cdr == nothing
            # If we're at the end of the list, append a new cons cell
            cons.cdr = Cons(nothing,nothing,cons)
        end
        cons = cons.cdr
    end
end

"""
Remove a tree from the forest list.
(Don't let Idefix see this function :D )
"""
function killtree!(tree::Tree,cons::Cons=forest,reason::String="malice aforethought")
    while cons != nothing
        if cons.car == tree
            if cons.prev != nothing #excise a cons cell from the list
                cons.prev.cdr = cons.cdr
                cons.cdr != nothing && (cons.cdr.prev = cons.prev)
                cons = nothing
            else
                #removing the first tree is a bit more tricky, because the
                #first cons cell (global variable `forest`) mustn't be deleted
                if cons.cdr != nothing
                    cons.car = cons.cdr.car
                    cons.cdr.cdr != nothing && (cons.cdr.cdr.prev = cons)
                    cons.cdr = cons.cdr.cdr
                else
                    cons.car = nothing
                end
            end
            #cleanup and decrease the tree count
            global forestlen -= 1
            @debug "Killed tree @$(tree.position.x)/$(tree.position.y) because of $(reason)"
            tree = nothing
            return
        end
        cons = cons.cdr
    end
    @warn "Attempted to remove nonexistent tree."
end

"""
Produce seeds and disperse them in the landscape, planting them where possible
"""
function disperse!(cons::Cons=forest)
    i::Int16 = 1
    while cons != nothing
        tree = cons.car
        if !tree.mature
            i += 1
            cons = cons.cdr
            continue
        end
        @debug "Reproducing tree $i"
        dx = tree.species.dispersal_distance
        # Each tree produces multiple seeds
        for s in 1:tree.species.seed_production
            #TODO implement a proper dispersal kernel
            # Find a random location in a circle around the tree
            sx = tree.position.x + rand(-dx:dx)
            dy = convert(Int16, round(sqrt(abs(dx^2-(sx-tree.position.x)^2))))
            sy = tree.position.y + rand(-dy:dy)
            if sx >= -settings["worldsize"] && sx <= settings["worldsize"] &&
                sy >= -settings["worldsize"] && sy <= settings["worldsize"]
                seed = Tree(tree.species, sx, sy)
                planttree!(seed)
            end
        end
        i += 1
        cons = cons.cdr
    end
end

"""
Test whether the trees in two cons cells intersect, and if so, kill the
smaller tree. The integer return value indicates the outcome:
0 - no intersection (no tree killed)
1 - the first tree is larger (second tree killed)
2 - the second tree is larger (first tree killed)
Needed by `compete_individual!()`
"""
function compete_pair!(cons1::Cons, cons2::Cons)::UInt8
    tree1 = cons1.car
    tree2 = cons2.car
    (tree1 == nothing || tree2 == nothing) && return
    mindist = (tree1.size + tree2.size)/2
    dx = abs(tree1.position.x - tree2.position.x)
    dy = abs(tree1.position.y - tree2.position.y)
    if  dx >= mindist || dy >= mindist || hypot(dx,dy) >= mindist
        return 0
    elseif tree1.size > tree2.size
        killtree!(tree2, cons2, "competition")
        return 1
    else
        killtree!(tree1, cons1, "competition")
        return 2
    end
end

"""
Check whether the tree in this cons cell conflicts with trees in the
vicinity and, if so, kill the smaller one.
Needed by `compete!()`
"""
function compete_individual!(cons::Cons)
    tree = cons.car
    # go right until we're sure we won't find any more conflicts
    next = cons.cdr
    while next != nothing && abs(next.car.position.x - tree.position.x) < (tree.size/2)+2^7
        next2 = next.cdr # We have to save the coming step already, in case `next` is killed
        conflict = compete_pair!(cons, next)
        if conflict == 2
            return # This tree was killed, so we can break off
        else # otherwise, keep going
            next = next2
        end
    end
    # then go left and repeat
    next = cons.prev
    while next != nothing && abs(next.car.position.x - tree.position.x) < (tree.size/2)+2^7
        next2 = next.prev
        conflict = compete_pair!(cons, next)
        if conflict == 2
            return
        else
            next = next2
        end
    end
end

"""
Go through the landscape and check each tree for space conflicts
"""
function compete!(cons::Cons=forest)
    while cons != nothing
        compete_individual!(cons)
        cons = cons.cdr
    end
end

"""
All saplings grow until they reach maturity, then eventually die of old age.
"""
function grow!(cons::Cons=forest)
    while cons != nothing
        tree = cons.car
        next = cons.cdr
        if !tree.mature
            tree.size += tree.species.growth_rate
            tree.size >= tree.species.max_size && (tree.mature = true)
        elseif tree.age >= tree.species.max_age
            killtree!(tree, cons, "old age")
            continue
        end
        tree.age += 1
        cons = next
        recordindividual(tree)
    end
end
