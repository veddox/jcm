###
### Janzen-Connell Model
### (c) Daniel Vedder, MIT license
###

const worldsize::UInt = 1000

"""
One node of the quadtree used to represent the forest. A node has a parent
(unless it is the root node), and four children, which may be other nodes
or Tree instances.
a = upper left, b = upper right, c = lower right, d = lower left
"""
mutable struct QuadNode
    pos::NamedTuple{(:x, :y, :width), Tuple{Int,Int,Int}}
    parent::Union{Nothing,QuadNode}
    a::Union{Tree,Nothing,QuadNode}
    b::Union{Tree,Nothing,QuadNode}
    c::Union{Tree,Nothing,QuadNode}
    d::Union{Tree,Nothing,QuadNode}
end

QuadNode() = QuadNode((0,0,worldsize), nothing, nothing, nothing, nothing, nothing)
QuadNode(pos::NamedTuple{(:x, :y, :width), Tuple{Int,Int,Int}}, parent::QuadNode) =
    QuadNode(pos, parent, nothing, nothing, nothing, nothing)

"""
Set quadrant q (1=a, 2=b, etc.) of a node to a given value
"""
function setquadrant!(node::QuadNode, q::UInt, v::Union{Tree,Nothing,QuadNote})
    if q == 1
        node.a = v
    else if q == 2
        node.b = v
    else if q == 3
        node.c = v
    else if q == 4
        node.d = v
    end
end

"""
The root node of a quadtree representing a forest. The simulation map is split
up into recursive quadrants, with at zero or one trees per quadrant. If another
tree is to be added to an occupied quadrant, the quadrant is split up.
(This allows for fast search operations.)
"""
const root::QuadNode = QuadNode()

"""
Plant a tree (i.e. insert a Tree object into the quadtree representing the model forest).
"""
function planttree!(tree::Tree, node::QuadNode=root)
    # figure out which quadrant the tree goes in
    if tree.position.y >= node.pos.y
        if tree.position.x <= node.pos.x
            q = 1
        else
            q = 2
        end
    else
        if tree.position.x <= node.pos.x
            q = 4
        else
            q = 3
        end
    end
    quadrant = eval(:(node.$(fieldnames(QuadNode)[q+2])))
    if quadrant == nothing
        #if the quadrant is empty, plant the tree
        setquadrant!(node, q, tree)
    else if isa(quadrant, Tree)
        # if the quadrant already has a tree, create a new node and plant both
        oldtree = quadrant
        setquadrant!(node, q, QuadNode(node))
        planttree!(oldtree, quadrant)
        planttree!(tree, quadrant)
    else if isa(quadrant, QuadNode)
        # if the quadrant is another node, recurse down
        planttree!(tree, quadrant)
    end
end

function findconflict(tree::Tree)
    #TODO
end
