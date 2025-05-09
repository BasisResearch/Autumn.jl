module AutumnStandardLibrary
using ..AExpressions: AExpr
using Random
using Setfield
using Distributions: Categorical
import Base: floor, round, min
export Object, ObjectType, Scene, State, Env
import Base: ==

struct Click
	x::Int
	y::Int
end

struct Position
	x::Int
	y::Int
end

struct Cell
	position::Position
	color::String
	opacity::Float64
end

struct Object
	id::Int
	origin::Position
	type::Symbol
	alive::Bool
	changed::Bool
	custom_fields::Dict{Symbol, Any}
	render::Union{Nothing, Vector{Cell}}
end
function (==)(obj1::Object, obj2::Object)
	obj1.id == obj2.id
end


struct ObjectType
	render::Union{Nothing, AExpr, Vector{Cell}}
	fields::Vector{AExpr}
end

mutable struct Scene
	objects::Vector{Object}
	background::String
end

mutable struct State
	time::Int
	objectsCreated::Int
	rng::AbstractRNG
	scene::Scene
	object_types::Dict{Symbol, ObjectType}
	histories::Dict{Symbol, Dict{Int, Any}}
end


mutable struct Env
	left::Bool
	right::Bool
	up::Bool
	down::Bool
	click::Union{Nothing, Click}
	current_var_values::Dict{Symbol, Any}
	state::State
	named_functions::Dict{Symbol, AExpr}
	show_rules::Int
end

function update_nt(object::Object, x::Symbol, v)
	if x == :id
		object = @set object.id = v
	elseif x == :origin
		object = @set object.origin = v
	elseif x == :type
		object = @set object.type = v
	elseif x == :alive
		object = @set object.alive = v
	elseif x == :changed
		object = @set object.changed = v
	elseif x == :custom_fields
		object = @set object.custom_fields = v
	elseif x == :render
		object = @set object.render = v
	else
		object = deepcopy(object)
		object.custom_fields[x] = v
	end
	object
end

Click(x, y, @nospecialize(state::State)) = Click(x, y)
Position(x, y, @nospecialize(state::State)) = Position(x, y)

Cell(position::Position, color::String) = Cell(position, color, 0.8)
Cell(x::Int, y::Int, color::String) = Cell(Position(floor(Int, x), floor(Int, y)), color, 0.8)
Cell(x, y, color::String, @nospecialize(state::State)) = Cell(floor(Int, x), floor(Int, y), color)
Cell(position::Position, color::String, @nospecialize(state::State)) = Cell(position::Position, color::String)

function prev(obj::Object, @nospecialize(state))
	prev_objects = filter(o -> o.id == obj.id, state.scene.objects)
	if prev_objects != []
		prev_objects[1]
	else
		obj
	end
end

function renderValue(obj::Object, state::Union{State, Nothing} = nothing)
	if obj.alive
		[obj]
	else
		[]
	end
end

function renderValue(objs::AbstractVector, state::Union{State, Nothing} = nothing)
	vcat(map(o -> renderValue(o, state), objs)...)
end

function render(obj::Object, state::Union{State, Nothing} = nothing)::Vector{Cell}
	if obj.alive
		if isnothing(obj.render)
			render = state.object_types[obj.type].render
			map(cell -> Cell(move(cell.position, obj.origin), cell.color), render)
		else
			map(cell -> Cell(move(cell.position, obj.origin), cell.color), obj.render)
		end
	else
		[]
	end
end

function renderScene(@nospecialize(scene::Scene), state::Union{State, Nothing} = nothing)
	vcat(map(o -> render(o, state), filter(x -> x.alive, scene.objects))...)
end

function occurred(click, state::Union{State, Nothing} = nothing)
	!isnothing(click)
end

function uniformChoice(freePositions, @nospecialize(state::State))
	# @show freePositions
	# @show length(freePositions)
	freePositions[rand(state.rng, Categorical(ones(length(freePositions)) / length(freePositions)))]
end

function uniformChoice(freePositions, n::Union{Int, BigInt}, @nospecialize(state::State))
	map(idx -> freePositions[idx], rand(state.rng, Categorical(ones(length(freePositions)) / length(freePositions)), n))
end

function min(arr, state::Union{State, Nothing} = nothing)
	Base.min(arr...)
end

function range(start::Int, stop::Int, state::Union{State, Nothing} = nothing)
	[start:stop;]
end

function isWithinBounds(obj::Object, @nospecialize(state::State))::Bool
	# # println(filter(cell -> !isWithinBounds(cell.position),render(obj)))
	length(filter(cell -> !isWithinBounds(cell.position, state), render(obj, state))) == 0
end

function isOutsideBounds(obj::Object, @nospecialize(state::State))::Bool
	# # println(filter(cell -> !isWithinBounds(cell.position),render(obj)))
	length(filter(cell -> isWithinBounds(cell.position, state), render(obj, state))) == 0
end

function clicked(click::Union{Click, Nothing}, object::Object, @nospecialize(state::State))::Bool
	if isnothing(click)
		false
	else
		GRID_SIZE = state.histories[:GRID_SIZE][0]
		if GRID_SIZE isa AbstractVector
			GRID_SIZE_X = GRID_SIZE[1]
			nums = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, render(object, state))
			(GRID_SIZE_X * click.y + click.x) in nums
		else
			nums = map(cell -> GRID_SIZE * cell.position.y + cell.position.x, render(object, state))
			(GRID_SIZE * click.y + click.x) in nums
		end
	end
end

function clicked(click::Union{Click, Nothing}, @nospecialize(objects::AbstractVector), @nospecialize(state::State))
	# # println("LOOK AT ME")
	# # println(reduce(&, map(obj -> clicked(click, obj), objects)))
	if isnothing(click)
		false
	else
		foldl(|, map(obj -> clicked(click, obj, state), objects), init = false)
	end
end

function objClicked(click::Union{Click, Nothing}, @nospecialize(objects::AbstractVector), state::Union{State, Nothing} = nothing)::Union{Object, Nothing}
	# # println(click)
	if isnothing(click)
		nothing
	else
		clicked_objects = filter(obj -> clicked(click, obj, state), objects)
		if length(clicked_objects) == 0
			nothing
		else
			clicked_objects[1]
		end
	end

end

function clicked(click::Union{Click, Nothing}, x::Int, y::Int, @nospecialize(state::State))::Bool
	if isnothing(click)
		false
	else
		click.x == x && click.y == y
	end
end

function clicked(click::Union{Click, Nothing}, pos::Position, @nospecialize(state::State))::Bool
	if isnothing(click)
		false
	else
		click.x == pos.x && click.y == pos.y
	end
end

function pushConfiguration(arrow::Position, @nospecialize(obj1::Object), @nospecialize(obj2::Object), @nospecialize(state::State))
	pushConfiguration(arrow, obj1, [obj2], state)
end

function pushConfiguration(arrow::Position, @nospecialize(obj1::Object), @nospecialize(obj2::AbstractVector), @nospecialize(state::State))
	# println("pushConfiguration: obj1 id = $(obj1.id), time = $(state.time)")
	moveIntersects(arrow, obj1, obj2, state) && isFree(move(move(obj1, arrow, state), arrow, state).origin, state)
end

function pushConfiguration(arrow::Position, @nospecialize(obj1::Object), @nospecialize(obj2::AbstractVector), @nospecialize(obj3::AbstractVector), @nospecialize(state::State))
	moveIntersects(arrow, obj1, obj2, state) && intersects(move(move(obj1, arrow, state), arrow, state), obj3, state)
end

function moveIntersects(arrow::Position, @nospecialize(obj1::Object), @nospecialize(obj2::Object), @nospecialize(state::State))
	(arrow != Position(0, 0)) && intersects(move(obj1, arrow, state), obj2, state)
end

function moveIntersects(arrow::Position, @nospecialize(obj::Object), @nospecialize(objects::AbstractVector), @nospecialize(state::State))
	(arrow != Position(0, 0)) && intersects(move(obj, arrow, state), objects, state)
end

function intersects(@nospecialize(obj1::Object), @nospecialize(obj2::Object), @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
		nums1 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, render(obj2, state))
		length(intersect(nums1, nums2)) != 0
	else
		nums1 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, render(obj2, state))
		length(intersect(nums1, nums2)) != 0
	end
end

function intersects(@nospecialize(obj1::Object), @nospecialize(obj2::AbstractVector), @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		nums1 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
		length(intersect(nums1, nums2)) != 0
	else
		nums1 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
		length(intersect(nums1, nums2)) != 0
	end
end

function intersects(@nospecialize(obj2::AbstractVector), @nospecialize(obj1::Object), @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		nums1 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
		length(intersect(nums1, nums2)) != 0
	else
		nums1 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, render(obj1, state))
		nums2 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
		length(intersect(nums1, nums2)) != 0
	end
end

function intersects(@nospecialize(obj1::AbstractVector), @nospecialize(obj2::AbstractVector), @nospecialize(state::State))::Bool
	if (length(obj1) == 0) || (length(obj2) == 0)
		false
	elseif (obj1[1] isa Object) && (obj2[1] isa Object)
		# # println("MADE IT")
		GRID_SIZE = state.histories[:GRID_SIZE][0]
		if GRID_SIZE isa AbstractVector
			GRID_SIZE_X = GRID_SIZE[1]
			nums1 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj1)...))
			nums2 = map(cell -> GRID_SIZE_X * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
			length(intersect(nums1, nums2)) != 0
		else
			nums1 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj1)...))
			nums2 = map(cell -> state.histories[:GRID_SIZE][0] * cell.position.y + cell.position.x, vcat(map(o -> render(o, state), obj2)...))
			length(intersect(nums1, nums2)) != 0
		end
	else
		length(intersect(obj1, obj2)) != 0
	end
end

function intersects(object::Object, @nospecialize(state::State))::Bool
	objects = state.scene.objects
	intersects(object, objects, state)
end

# (= intersectsElems (--> (elems1 elems2) (
#         if (or (== (length elems1) 0) (== (length elems2) 0)) then false else
#         (any (--> elem1
#                   (any (--> elem2 (== (.. elem1 position) (.. elem2 position))) elems2)) elems1)
#         )
#   ))
function intersectsElems(@nospecialize(elems1::AbstractVector), @nospecialize(elems2::AbstractVector), @nospecialize(state::State))::Bool
	if (length(elems1) == 0) || (length(elems2) == 0)
		false
	else
		any(elem1 -> any(elem2 -> ==(elem1.origin, elem2.origin), elems2), elems1)
	end
end

#   (= intersectsPosElems (--> (pos elems) 
#                           (any (--> elem (== (.. elem position) pos)) elems)))
function intersectsPosElems(@nospecialize(pos::Position), @nospecialize(elems::AbstractVector), @nospecialize(state::State))::Bool
	any(elem -> (elem.origin.x == pos.x) && (elem.origin.y == pos.y), elems)
end

#   (= intersectsPosPoss (--> (pos poss) 
#                           (any (--> pos2 (== pos pos2)) poss)))
function intersectsPosPoss(@nospecialize(pos::Position), @nospecialize(poss::AbstractVector), @nospecialize(state::State))::Bool
	any(pos2 -> (pos.x == pos2.x) && (pos.y == pos2.y), poss)
end

# (= isFreeRangeExceptObj (--> (start end obj) (
#     let (= allCheckedPos (map (--> (x) (Position x 0)) (range start end)))
#         (= prev_elems (renderValue obj))
#         (= filtered_pos (filter (--> pos (! (intersectsPosElems pos prev_elems))) allCheckedPos))
#         (! (any (--> pos (! (isFreePos pos))) filtered_pos))
#   )))
function isFreeRangeExceptObj(start::Int, end_::Int, obj::Object, @nospecialize(state::State))::Bool
	allCheckedPos = map(x -> Position(x, 0), start:end_)
	prev_elems = renderValue(obj, state)
	filtered_pos = filter(pos -> !intersectsPosElems(pos, prev_elems, state), allCheckedPos)
	!any(pos -> isFreePos(pos, state), filtered_pos)
end

function addObj(@nospecialize(list::AbstractVector), obj::Object, state::Union{State, Nothing} = nothing)
	new_list = vcat(list, obj)
	new_list
end

function addObj(@nospecialize(list::AbstractVector), @nospecialize(objs::AbstractVector), state::Union{State, Nothing} = nothing)
	new_list = vcat(list, objs)
	new_list
end

function removeObj(@nospecialize(list::AbstractVector), obj::Object, state::Union{State, Nothing} = nothing)
	new_list = deepcopy(list)
	for x in filter(o -> o.id == obj.id, new_list)
		index = findall(o -> o.id == x.id, new_list)[1]
		new_list[index] = update_nt(x, :alive, false)
		#x.alive = false 
		#x.changed = true
	end
	new_list
end

function removeObj(@nospecialize(list::AbstractVector), num::N, state::Union{State, Nothing} = nothing) where N <: Union{Number, String}
	filter(o -> o != num, list)
end

function removeObj(@nospecialize(list::AbstractVector), fn, state::Union{State, Nothing} = nothing)
	new_list = deepcopy(list)
	println("removeObj: $(fn)")
	for x in filter(obj -> fn(obj), new_list)
		index = findall(o -> o.id == x.id, new_list)[1]
		new_list[index] = update_nt(x, :alive, false)
		#x.alive = false 
		#x.changed = true
	end
	new_list
end

function removeObj(obj::Object, state::Union{State, Nothing} = nothing)
	new_obj = update_nt(obj, :alive, false)
	# new_obj.alive = false
	# new_obj.changed = true
	new_obj
end

function updateObj(obj::Object, field::String, value, state::Union{State, Nothing} = nothing)
	fields = fieldnames(typeof(obj))
	custom_fields = fields[5:end-1]
	origin_field = (fields[2],)

	constructor_fields = (custom_fields..., origin_field...)
	constructor_values = map(x -> x == Symbol(field) ? value : getproperty(obj, x), constructor_fields)

	new_obj = typeof(obj)(constructor_values...)
	setproperty!(new_obj, :id, obj.id)
	setproperty!(new_obj, :alive, obj.alive)

	setproperty!(new_obj, Symbol(field), value)
	state.objectsCreated -= 1
	new_obj
end

function filter_fallback(obj::Object, state::Union{State, Nothing} = nothing)
	true
end

function adjPositions(position::Position, @nospecialize(state::State))::Vector{Position}
	filter(x -> isWithinBounds(x, state), [Position(position.x, position.y + 1), Position(position.x, position.y - 1), Position(position.x + 1, position.y), Position(position.x - 1, position.y)])
end

function isWithinBounds(position::Position, @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
	else
		GRID_SIZE_X = GRID_SIZE
		GRID_SIZE_Y = GRID_SIZE
	end
	(position.x >= 0) && (position.x < GRID_SIZE_X) && (position.y >= 0) && (position.y < GRID_SIZE_Y)
end

function isOutsideBounds(position::Position, @nospecialize(state::State))::Bool
	!isWithinBounds(position, state)
end

function isFreePos(position::Position, @nospecialize(state::State))::Bool
	length(filter(cell -> cell.position.x == position.x && cell.position.y == position.y, renderScene(state.scene, state))) == 0
end

function isFreePos(click::Union{Click, Nothing}, @nospecialize(state::State))::Bool
	if isnothing(click)
		false
	else
		isFreePos(Position(click.x, click.y), state)
	end
end

function isFreePos(positions::Vector{Position}, @nospecialize(state::State))::Bool
	foldl(|, map(pos -> isFreePos(pos, state), positions), init = false)
end

function isFree(position::Position, @nospecialize(state::State))::Bool
	length(filter(cell -> cell.position.x == position.x && cell.position.y == position.y, renderScene(state.scene, state))) == 0
end

function isFree(click::Union{Click, Nothing}, @nospecialize(state::State))::Bool
	if isnothing(click)
		false
	else
		isFreePos(Position(click.x, click.y), state)
	end
end

function isFree(positions::Vector{Position}, @nospecialize(state::State))::Bool
	foldl(|, map(pos -> isFreePos(pos, state), positions), init = false)
end

function rect(pos1::Position, pos2::Position, state::Union{State, Nothing} = nothing)
	min_x = pos1.x
	max_x = pos2.x
	min_y = pos1.y
	max_y = pos2.y

	positions = []
	for x in min_x:max_x
		for y in min_y:max_y
			push!(positions, Position(x, y))
		end
	end
	positions
end

function unitVector(position1::Position, position2::Position, @nospecialize(state::State))::Position
	deltaX = position2.x - position1.x
	deltaY = position2.y - position1.y
	if (floor(Int, abs(sign(deltaX))) == 1 && floor(Int, abs(sign(deltaY))) == 1)
		Position(sign(deltaX), 0)
		# uniformChoice(rng, [Position(sign(deltaX), 0), Position(0, sign(deltaY))])
	else
		Position(sign(deltaX), sign(deltaY))
	end
end

function unitVector(object1::Object, object2::Object, @nospecialize(state::State))::Position
	position1 = object1.origin
	position2 = object2.origin
	unitVector(position1, position2, state)
end

function unitVector(object::Object, position::Position, @nospecialize(state::State))::Position
	unitVector(object.origin, position, state)
end

function unitVector(position::Position, object::Object, @nospecialize(state::State))::Position
	unitVector(position, object.origin, state)
end

function unitVector(position::Position, @nospecialize(state::State))::Position
	unitVector(Position(0, 0), position, state)
end

function displacement(position1::Position, position2::Position, state::Union{State, Nothing} = nothing)::Position
	Position(floor(Int, position2.x - position1.x), floor(Int, position2.y - position1.y))
end

function displacement(cell1::Cell, cell2::Cell, state::Union{State, Nothing} = nothing)::Position
	displacement(cell1.position, cell2.position)
end

# (= deltaPos (--> (pos1 pos2) 
# (Position 
# (- (.. pos2 x) (.. pos1 x)) 
# (- (.. pos2 y) (.. pos1 y))
# )
# ))
function deltaPos(pos1::Position, pos2::Position, state::Union{State, Nothing} = nothing)::Position
	Position(pos2.x - pos1.x, pos2.y - pos1.y)
end

# (= deltaElem (--> (e1 e2)
#     (deltaPos (.. e1 position) (.. e2 position))
#   ))
deltaElem(e1::Cell, e2::Cell, state::Union{State, Nothing} = nothing)::Position = displacement(e1, e2, state)
deltaElem(e1::Object, e2::Object, state::Union{State, Nothing} = nothing)::Position = displacement(e1.origin, e2.origin, state)
deltaElem(e1::Object, objs::AbstractVector, state::Union{State, Nothing} = nothing) = collect(map(obj -> deltaElem(e1, obj, state), objs))
deltaElem(objs1::AbstractVector, e2::Object, state::Union{State, Nothing} = nothing) = collect(map(obj -> deltaElem(obj, e2, state), objs1))

#   (= deltaObj (--> (obj1 obj2)
#     (deltaPos (.. obj1 origin) (.. obj2 origin))
#   ))
deltaObj(obj1::Object, obj2::Object, state::Union{State, Nothing} = nothing)::Position = displacement(obj1.origin, obj2.origin, state)


#   (= adjacentElem (--> (e1 e2) (
#       let (= delta (deltaPos (.. e1 position) (.. e2 position)))
#           (== (+ (abs (.. delta x)) (abs (.. delta y))) 1)
#       )
#   ))

#   (= adjacentPoss (--> (p1 p2 unitSize) (
#     let (= delta (deltaPos p1 p2))
#         (<= (+ (abs (.. delta x)) (abs (.. delta y))) unitSize)
#     )
#   ))
function adjacentPoss(p1::Position, p2::Position, unitSize::Int, state::Union{State, Nothing} = nothing)::Bool
	delta = deltaPos(p1, p2, state)
	(abs(delta.x) + abs(delta.y)) <= unitSize
end


#   (= adjacentTwoObjs (--> (obj1 obj2 unitSize) (
#     adjacentPoss (.. obj1 origin) (.. obj2 origin) unitSize
#   )))
adjacentTwoObjs(obj1::Object, obj2::Object, unitSize::Int, state::Union{State, Nothing} = nothing)::Bool = adjacentPoss(obj1.origin, obj2.origin, unitSize, state)

#   (= adjacentPossDiag (--> (p1 p2) (
#     let (= delta (deltaPos p1 p2))
#         (& (<= (abs (.. delta x)) 1)
#            (<= (abs (.. delta y)) 1))

#   )))
adjacentPossDiag(p1::Position, p2::Position, state::Union{State, Nothing} = nothing)::Bool = displacement(p1, p2, state) in [Position(1, 1), Position(1, -1), Position(-1, 1), Position(-1, -1)]

#   (= adjacentTwoObjsDiag (--> (obj1 obj2) (
#     adjacentPossDiag (.. obj1 origin) (.. obj2 origin)
#   )))
adjacentTwoObjsDiag(obj1::Object, obj2::Object, state::Union{State, Nothing} = nothing)::Bool = adjacentPossDiag(obj1.origin, obj2.origin, state)

function adjacent(position1::Position, position2::Position, state::Union{State, Nothing} = nothing)::Bool
	displacement(position1, position2) in [Position(0, 1), Position(1, 0), Position(0, -1), Position(-1, 0)]
end

function adjacent(position1::Position, position2::Position, unitSize::Int, state::Union{State, Nothing} = nothing)::Bool
	displacement(position1, position2) in [Position(0, unitSize), Position(unitSize, 0), Position(0, -unitSize), Position(-unitSize, 0)]
end

function adjacent(cell1::Cell, cell2::Cell, unitSize::Int, state::Union{State, Nothing} = nothing)::Bool
	adjacent(cell1.position, cell2.position, unitSize)
end

function adjacent(cell::Cell, cells::Vector{Cell}, unitSize::Int, state::Union{State, Nothing} = nothing)
	length(filter(x -> adjacent(cell, x, unitSize), cells)) != 0
end

function adjacentObjs(obj::Object, @nospecialize(state::State))
	filter(o -> adjacent(o.origin, obj.origin, 1) && (obj.id != o.id), state.scene.objects)
end

function adjacentObjs(obj::Object, unitSize::Int, @nospecialize(state::State))
	filter(o -> adjacent(o.origin, obj.origin, unitSize) && (obj.id != o.id), state.scene.objects)
end

function adjacentElem(e1::Object, e2::Object, unitSize::Int = 1, state::Union{State, Nothing} = nothing)::Bool
	rendered_cells_1 = e1.render
	rendered_cells_2 = e2.render
	any(c1 -> any(c2 -> adjacent(c1, c2, unitSize, state), rendered_cells_2), rendered_cells_1)
end

function adjacentElem(objs1::AbstractVector, objs2::AbstractVector, unitSize::Int = 1, state::Union{State, Nothing} = nothing)::Bool
	any(obj1 -> any(obj2 -> adjacentElem(obj1, obj2, unitSize, state), objs2), objs1)
end

function adjacentObjsDiag(obj::Object, @nospecialize(state::State))
	filter(o -> adjacentDiag(o.origin, obj.origin, 1) && (obj.id != o.id), state.scene.objects)
end

function adjacentObjsDiag(obj::Object, unitSize::Int, @nospecialize(state::State))
	filter(o -> adjacentDiag(o.origin, obj.origin, unitSize) && (obj.id != o.id), state.scene.objects)
end

function adjacentDiag(position1::Position, position2::Position, unitSize::Int, @nospecialize(state::Union{State, Nothing}) = nothing)
	displacement(position1, position2) in [Position(0, unitSize), Position(unitSize, 0), Position(0, -unitSize), Position(-unitSize, 0),
		Position(unitSize, unitSize), Position(unitSize, -unitSize), Position(-unitSize, unitSize), Position(-unitSize, -unitSize)]
end

function adj(@nospecialize(obj1::Object), @nospecialize(obj2::Object), unitSize::Int, @nospecialize(state::State))
	filter(o -> o.id == obj2.id, adjacentObjs(obj1, unitSize, state)) != []
end

function adj(@nospecialize(obj1::Object), @nospecialize(obj2::AbstractVector), unitSize::Int, @nospecialize(state::State))
	filter(o -> o.id in map(x -> x.id, obj2), adjacentObjs(obj1, unitSize, state)) != []
end

function adj(@nospecialize(obj1::AbstractVector), @nospecialize(obj2::AbstractVector), unitSize::Int, @nospecialize(state::State))
	obj1_adjacentObjs = vcat(map(x -> adjacentObjs(x, unitSize, state), obj1)...)
	intersect(map(x -> x.id, obj1_adjacentObjs), map(x -> x.id, obj2)) != []
end

function adjCorner(@nospecialize(obj1::Object), @nospecialize(obj2::Object), unitSize::Int, @nospecialize(state::State))
	filter(o -> o.id == obj2.id, map(obj -> !(obj.id in map(z -> z.id, adjacentObjs(obj1, unitSize, state))), adjacentObjsDiag(obj1, unitSize, state))) != []
end

function adjCorner(@nospecialize(obj1::Object), @nospecialize(obj2::AbstractVector), unitSize::Int, @nospecialize(state::State))
	filter(o -> o.id in map(x -> x.id, obj2), map(obj -> !(obj.id in map(z -> z.id, adjacentObjs(obj1, unitSize, state))), adjacentObjsDiag(obj1, unitSize, state))) != []
end

function adjCorner(@nospecialize(obj1::AbstractVector), @nospecialize(obj2::AbstractVector), unitSize::Int, @nospecialize(state::State))
	obj1_adjacentObjs = vcat(map(x -> map(obj -> !(obj.id in map(z -> z.id, adjacentObjs(obj1, unitSize, state))), adjacentObjsDiag(x, unitSize, state)), obj1)...)
	intersect(map(x -> x.id, obj1_adjacentObjs), map(x -> x.id, obj2)) != []
end

# Generic function to check if two objects are connected through a path of objects
function isConnected(obj1::Object, obj2::Object, connectorObjs::AbstractVector = [], state::Union{State, Nothing} = nothing)::Bool
	# Assumes that connectorObjs are all objects that are connected to each other

	# First check if obj1 and obj2 are adjacent
	(adjacentElem(obj1, obj2, 1, state) || (obj1 in adjacentObjsDiag(obj2, 1, state))) && return true

	# obj1 is adjacent to any connector object and obj2 is adjacent to any connector object
	(any([(adjacentElem(obj1, o, 1, state) || (o in adjacentObjsDiag(obj1, 1, state))) for o in connectorObjs]) & any([(adjacentElem(obj2, o, 1, state) || (o in adjacentObjsDiag(obj2, 1, state))) for o in connectorObjs])) && return true
end

function rotate(object::Object, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :render, map(x -> Cell(rotate(x.position), x.color), new_object.render))
	new_object
end

function rotate(position::Position, state::Union{State, Nothing} = nothing)::Position
	Position(-position.y, position.x)
end

function rotateByAngle(object::Object, angle, state::Union{State, Nothing} = nothing)::Object
	@show object.render
	object
end

function rotateNoCollision(object::Object, @nospecialize(state::State))::Object
	(isWithinBounds(rotate(object), state) && isFree(rotate(object), object, state)) ? rotate(object) : object
end

function movePos(position1::Position, position2::Position, state::Union{State, Nothing} = nothing)
	Position(position1.x + position2.x, position1.y + position2.y)
end

function move(position::Position, position2::Position, state::Union{State, Nothing} = nothing)
	movePos(position, position2, state)
end

function movePos(position::Position, cell::Cell, state::Union{State, Nothing} = nothing)
	Position(position.x + cell.position.x, position.y + cell.position.y)
end

function movePos(cell::Cell, position::Position, state::Union{State, Nothing} = nothing)
	Position(position.x + cell.position.x, position.y + cell.position.y)
end

function move(object::Object, position::Position, state::Union{State, Nothing} = nothing)
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, movePos(object.origin, position))
	new_object
end

function move(object::Object, x::Int, y::Int, state::Union{State, Nothing} = nothing)::Object
	move(object, Position(x, y))
end

# ----- begin left/right move ----- #

function moveLeft(object::Object, state::Union{State, Nothing} = nothing)::Object
	move(object, Position(-1, 0))
end

function moveRight(object::Object, state::Union{State, Nothing} = nothing)::Object
	move(object, Position(1, 0))
end

function moveUp(object::Object, state::Union{State, Nothing} = nothing)::Object
	move(object, Position(0, -1))
end

function moveDown(object::Object, state::Union{State, Nothing} = nothing)::Object
	move(object, Position(0, 1))
end

# ----- end left/right move ----- #

function moveNoCollision(object::Object, position::Position, @nospecialize(state::State))::Object
	(isWithinBounds(move(object, position), state) && isFree(move(object, position.x, position.y), object, state)) ? move(object, position.x, position.y) : object
end

function moveNoCollision(object::Object, x::Int, y::Int, @nospecialize(state::State))
	(isWithinBounds(move(object, x, y), state) && isFree(move(object, x, y), object, state)) ? move(object, x, y) : object
end

function moveNoCollisionColor(object::Object, position::Position, color::String, @nospecialize(state::State))::Object
	new_object = move(object, position)
	matching_color_objects = filter(obj -> intersects(new_object, obj, state) && (color in map(cell -> cell.color, render(obj, state))), state.scene.objects)
	if matching_color_objects == []
		new_object
	else
		object
	end
end

function moveNoCollisionColor(object::Object, x::Int, y::Int, color::String, @nospecialize(state::State))::Object
	new_object = move(object, Position(x, y))
	matching_color_objects = filter(obj -> intersects(new_object, obj, state) && (color in map(cell -> cell.color, render(obj, state))), state.scene.objects)
	if matching_color_objects == []
		new_object
	else
		object
	end
end

# ----- begin left/right moveNoCollision ----- #

function moveLeftNoCollision(object::Object, @nospecialize(state::State))::Object
	(isWithinBounds(move(object, -1, 0), state) && isFree(move(object, -1, 0), object, state)) ? move(object, -1, 0) : object
end

function moveRightNoCollision(object::Object, @nospecialize(state::State))::Object
	x = (isWithinBounds(move(object, 1, 0), state) && isFree(move(object, 1, 0), object, state)) ? move(object, 1, 0) : object
	x
end

function moveUpNoCollision(object::Object, @nospecialize(state::State))::Object
	(isWithinBounds(move(object, 0, -1), state) && isFree(move(object, 0, -1), object, state)) ? move(object, 0, -1) : object
end

function moveDownNoCollision(object::Object, @nospecialize(state::State))::Object
	(isWithinBounds(move(object, 0, 1), state) && isFree(move(object, 0, 1), object, state)) ? move(object, 0, 1) : object
end

# ----- end left/right moveNoCollision ----- #

function moveWrap(object::Object, position::Position, @nospecialize(state::State))::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, position.x, position.y, state))
	new_object
end

function moveWrap(cell::Cell, position::Position, @nospecialize(state::State))
	moveWrap(cell.position, position.x, position.y, state)
end

function moveWrap(position::Position, cell::Cell, @nospecialize(state::State))
	moveWrap(cell.position, position, state)
end

function moveWrap(object::Object, x::Int, y::Int, @nospecialize(state::State))::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, x, y, state))
	new_object
end

function moveWrap(position1::Position, position2::Position, @nospecialize(state::State))::Position
	moveWrap(position1, position2.x, position2.y, state)
end

function moveWrap(position::Position, x::Int, y::Int, @nospecialize(state::State))::Position
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
		# # println("hello")
		# # println(Position((position.x + x + GRID_SIZE) % GRID_SIZE, (position.y + y + GRID_SIZE) % GRID_SIZE))
		Position((position.x + x + GRID_SIZE_X) % GRID_SIZE_X, (position.y + y + GRID_SIZE_Y) % GRID_SIZE_Y)
	else
		Position((position.x + x + GRID_SIZE) % GRID_SIZE, (position.y + y + GRID_SIZE) % GRID_SIZE)
	end

end

# ----- begin left/right moveWrap ----- #

function moveLeftWrap(object::Object, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, -1, 0, state))
	new_object
end

function moveRightWrap(object::Object, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, 1, 0, state))
	new_object
end

function moveUpWrap(object::Object, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, 0, -1, state))
	new_object
end

function moveDownWrap(object::Object, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, moveWrap(object.origin, 0, 1, state))
	new_object
end

# ----- end left/right moveWrap ----- #

function scalarMult(pos::Position, s::Int, state::Union{State, Nothing} = nothing)::Position
	Position(pos.x * s, pos.y * s)
end

function randomPositions(GRID_SIZE, n::Int, state::Union{State, Nothing} = nothing)::Vector{Position}
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
		nums = uniformChoice([0:(GRID_SIZE_X*GRID_SIZE_Y-1);], n, state)
		map(num -> Position(num % GRID_SIZE_X, floor(Int, num / GRID_SIZE_X)), nums)
	else
		nums = uniformChoice([0:(GRID_SIZE*GRID_SIZE-1);], n, state)
		map(num -> Position(num % GRID_SIZE, floor(Int, num / GRID_SIZE)), nums)
	end
end

function distance(position1::Position, position2::Position, state::Union{State, Nothing} = nothing)::Int
	abs(position1.x - position2.x) + abs(position1.y - position2.y)
end

function distance(object1::Object, object2::Object, state::Union{State, Nothing} = nothing)::Int
	position1 = object1.origin
	position2 = object2.origin
	distance(position1, position2)
end

function distance(object::Object, position::Position, state::Union{State, Nothing} = nothing)::Int
	distance(object.origin, position)
end

function distance(position::Position, object::Object, state::Union{State, Nothing} = nothing)::Int
	distance(object.origin, position)
end

function distance(object::Object, @nospecialize(objects::AbstractVector), state::Union{State, Nothing} = nothing)::Int
	if objects == []
		typemax(Int)
	else
		distances = map(obj -> distance(object, obj), objects)
		minimum(distances)
	end
end

function distance(@nospecialize(objects1::AbstractVector), @nospecialize(objects2::AbstractVector), state::Union{State, Nothing} = nothing)::Int
	if objects1 == [] || objects2 == []
		typemax(Int)
	else
		distances = vcat(map(obj -> distance(obj, objects2), objects1)...)
		minimum(distances)
	end
end


function firstWithDefault(@nospecialize(arr::AbstractVector), state::Union{State, Nothing} = nothing)
	if arr == []
		Position(-30, -30)
	else
		first(arr)
	end
end

function farthestRandom(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	choices = [farthestLeft(object, types, unit_size, state),
		farthestRight(object, types, unit_size, state),
		farthestDown(object, types, unit_size, state),
		farthestUp(object, types, unit_size, state)]

	nonzero_positions = filter(p -> p != Position(0, 0), choices)

	# println("farthestRandom")
	# @show nonzero_positions 

	if nonzero_positions == []
		Position(0, 0)
	else
		rand(nonzero_positions)
	end
end

function farthestLeft(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	orig_position = closestRight(object, types, unit_size, state)
	if orig_position == Position(unit_size, 0)
		Position(-unit_size, 0)
	else
		objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
		if length(objects_of_type) == 0
			Position(0, 0)
		else
			min_distance = min(map(obj -> distance(object, obj), objects_of_type))
			objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
			if objects_of_min_distance[1].origin.x == object.origin.x
				Position(-unit_size, 0)
			else
				Position(0, 0)
			end
		end
	end
end

function farthestRight(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	orig_position = closestLeft(object, types, unit_size, state)
	if orig_position == Position(-unit_size, 0)
		Position(unit_size, 0)
	else
		objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
		if length(objects_of_type) == 0
			Position(0, 0)
		else
			min_distance = min(map(obj -> distance(object, obj), objects_of_type))
			objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
			if objects_of_min_distance[1].origin.x == object.origin.x
				Position(unit_size, 0)
			else
				Position(0, 0)
			end
		end
	end
end

function farthestUp(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	orig_position = closestDown(object, types, unit_size, state)
	if orig_position == Position(0, unit_size)
		Position(0, -unit_size)
	else
		objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
		if length(objects_of_type) == 0
			Position(0, 0)
		else
			min_distance = min(map(obj -> distance(object, obj), objects_of_type))
			objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
			if objects_of_min_distance[1].origin.y == object.origin.y
				Position(0, -unit_size)
			else
				Position(0, 0)
			end
		end
	end
end

function farthestDown(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	orig_position = closestUp(object, types, unit_size, state)
	if orig_position == Position(0, -unit_size)
		Position(0, unit_size)
	else
		objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
		if length(objects_of_type) == 0
			Position(0, 0)
		else
			min_distance = min(map(obj -> distance(object, obj), objects_of_type))
			objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
			if objects_of_min_distance[1].origin.y == object.origin.y
				Position(0, unit_size)
			else
				Position(0, 0)
			end
		end
	end
end

function aprint(o, @nospecialize(state::State))
	println("[PRINT] $o")
	true
end

function closest(object::Object, type::Symbol, @nospecialize(state::State))::Position
	objects_of_type = filter(obj -> (obj.type == type) && (obj.alive), state.scene.objects)
	if length(objects_of_type) == 0
		object.origin
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		sort(objects_of_min_distance, by = o -> (o.origin.x, o.origin.y))[1].origin
	end
end

function closest(object::Object, @nospecialize(objects_of_type::AbstractVector), @nospecialize(state::State))::Position
	# objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
	# @show object
	# @show objects_of_type
	if length(objects_of_type) == 0
		# println("here!")
		object.origin
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		sort(objects_of_min_distance, by = o -> (o.origin.x, o.origin.y))[1].origin
	end
end

function closestRandom(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	choices = [closestLeft(object, types, unit_size, state),
		closestRight(object, types, unit_size, state),
		closestDown(object, types, unit_size, state),
		closestUp(object, types, unit_size, state)]

	nonzero_positions = filter(p -> p != Position(0, 0), choices)

	# println("closestRandom")
	# @show nonzero_positions 

	if nonzero_positions == []
		Position(0, 0)
	else
		rand(nonzero_positions)
	end
end

function closestLeft(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
	if length(objects_of_type) == 0
		Position(0, 0)
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		negative_x_displacements = filter(x -> x < 0, map(o -> (o.origin.x - object.origin.x), objects_of_min_distance))
		if length(negative_x_displacements) > 0
			Position(-unit_size, 0)
		else
			Position(0, 0)
		end
	end
end

function closestRight(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
	if length(objects_of_type) == 0
		Position(0, 0)
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		positive_x_displacements = filter(x -> x > 0, map(o -> (o.origin.x - object.origin.x), objects_of_min_distance))
		if length(positive_x_displacements) > 0
			Position(unit_size, 0)
		else
			Position(0, 0)
		end
	end
end

function closestUp(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	# @show object 
	# @show types 
	# @show state   

	objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
	# @show objects_of_type 
	if length(objects_of_type) == 0
		Position(0, 0)
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		negative_y_displacements = filter(x -> x < 0, map(o -> (o.origin.y - object.origin.y), objects_of_min_distance))

		# @show min_distance 
		# @show objects_of_min_distance 
		# @show negative_y_displacements 

		if length(negative_y_displacements) > 0
			Position(0, -unit_size)
		else
			Position(0, 0)
		end
	end
end

function closestDown(object::Object, @nospecialize(types::AbstractVector), unit_size::Int, @nospecialize(state::State))::Position
	# @show object 
	# @show types 
	# @show state 
	objects_of_type = filter(obj -> (obj.type in types) && (obj.alive), state.scene.objects)
	# @show objects_of_type 
	if length(objects_of_type) == 0
		Position(0, 0)
	else
		min_distance = min(map(obj -> distance(object, obj), objects_of_type))
		objects_of_min_distance = filter(obj -> distance(object, obj) == min_distance, objects_of_type)
		positive_y_displacements = filter(x -> x > 0, map(o -> (o.origin.y - object.origin.y), objects_of_min_distance))

		# @show min_distance 
		# @show objects_of_min_distance 
		# @show positive_y_displacements 

		if length(positive_y_displacements) > 0
			Position(0, unit_size)
		else
			Position(0, 0)
		end
	end
end

function mapPositions(constructor, GRID_SIZE, filterFunction, args, state::Union{State, Nothing} = nothing)::AbstractVector
	map(pos -> constructor(args..., pos), filter(filterFunction, allPositions(GRID_SIZE)))
end

function allPositions(GRID_SIZE, state::Union{State, Nothing} = nothing)
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
		nums = [0:(GRID_SIZE_X*GRID_SIZE_Y-1);]
		map(num -> Position(num % GRID_SIZE_X, floor(Int, num / GRID_SIZE_X)), nums)
	else
		nums = [0:(GRID_SIZE*GRID_SIZE-1);]
		map(num -> Position(num % GRID_SIZE, floor(Int, num / GRID_SIZE)), nums)
	end
end

function updateOrigin(object::Object, new_origin::Position, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :origin, new_origin)
	new_object
end

function updateAlive(object::Object, new_alive::Bool, state::Union{State, Nothing} = nothing)::Object
	new_object = deepcopy(object)
	new_object = update_nt(new_object, :alive, new_alive)
	new_object
end

function nextLiquid(object::Object, @nospecialize(state::State))::Object
	# # println("nextLiquid")
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
	else
		GRID_SIZE_X = GRID_SIZE
		GRID_SIZE_Y = GRID_SIZE
	end
	new_object = deepcopy(object)
	if object.origin.y != GRID_SIZE_Y - 1 && isFree(move(object.origin, Position(0, 1)), state)
		new_object = update_nt(new_object, :origin, move(object.origin, Position(0, 1)))
	else
		leftHoles = filter(pos -> (pos.y == object.origin.y + 1)
									  && (pos.x < object.origin.x)
									  && isFree(pos, state), allPositions(state))
		rightHoles = filter(pos -> (pos.y == object.origin.y + 1)
									   && (pos.x > object.origin.x)
									   && isFree(pos, state), allPositions(state))
		if (length(leftHoles) != 0) || (length(rightHoles) != 0)
			if (length(leftHoles) == 0)
				closestHole = closest(object, rightHoles)
				if isFree(move(closestHole, Position(0, -1)), move(object.origin, Position(1, 0)), state)
					new_object = update_nt(new_object, :origin, move(object.origin, unitVector(object, move(closestHole, Position(0, -1)), state), state))
				end
			elseif (length(rightHoles) == 0)
				closestHole = closest(object, leftHoles)
				if isFree(move(closestHole, Position(0, -1)), move(object.origin, Position(-1, 0)), state)
					new_object = update_nt(new_object, :origin, move(object.origin, unitVector(object, move(closestHole, Position(0, -1)), state)))
				end
			else
				closestLeftHole = closest(object, leftHoles)
				closestRightHole = closest(object, rightHoles)
				if distance(object.origin, closestLeftHole) > distance(object.origin, closestRightHole)
					if isFree(move(object.origin, Position(1, 0)), move(closestRightHole, Position(0, -1)), state)
						new_object = update_nt(new_object, :origin, move(object.origin, unitVector(new_object, move(closestRightHole, Position(0, -1)), state)))
					elseif isFree(move(closestLeftHole, Position(0, -1)), move(object.origin, Position(-1, 0)), state)
						new_object = update_nt(new_object, :origin, move(object.origin, unitVector(new_object, move(closestLeftHole, Position(0, -1)), state)))
					end
				else
					if isFree(move(closestLeftHole, Position(0, -1)), move(object.origin, Position(-1, 0)), state)
						new_object = update_nt(new_object, :origin, move(object.origin, unitVector(new_object, move(closestLeftHole, Position(0, -1)), state)))
					elseif isFree(move(object.origin, Position(1, 0)), move(closestRightHole, Position(0, -1)), state)
						new_object = update_nt(new_object, :origin, move(object.origin, unitVector(new_object, move(closestRightHole, Position(0, -1)), state)))
					end
				end
			end
		end
	end
	new_object
end

function nextSolid(object::Object, @nospecialize(state::State))::Object
	# # println("nextSolid")
	new_object = deepcopy(object)
	if (isWithinBounds(move(object, Position(0, 1)), state) && reduce(&, map(x -> isFree(x, object, state), map(cell -> move(cell.position, Position(0, 1)), render(object, state)))))
		new_object = update_nt(new_object, :origin, move(object.origin, Position(0, 1)))
	end
	new_object
end

function closest(object::Object, positions::Vector{Position}, state::Union{State, Nothing} = nothing)::Position
	closestDistance = sort(map(pos -> distance(pos, object.origin), positions))[1]
	closest = filter(pos -> distance(pos, object.origin) == closestDistance, positions)[1]
	closest
end

function isFree(start::Position, stop::Position, @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
	else
		GRID_SIZE_X = GRID_SIZE
		GRID_SIZE_Y = GRID_SIZE
	end
	translated_start = GRID_SIZE_X * start.y + start.x
	translated_stop = GRID_SIZE_X * stop.y + stop.x
	if translated_start < translated_stop
		ordered_start = translated_start
		ordered_end = translated_stop
	else
		ordered_start = translated_stop
		ordered_end = translated_start
	end
	nums = [ordered_start:ordered_end;]
	reduce(&, map(num -> isFree(Position(num % GRID_SIZE_X, floor(Int, num / GRID_SIZE_X)), state), nums))
end

function isFree(start::Position, stop::Position, object::Object, @nospecialize(state::State))::Bool
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
	else
		GRID_SIZE_X = GRID_SIZE
		GRID_SIZE_Y = GRID_SIZE
	end
	translated_start = GRID_SIZE_X * start.y + start.x
	translated_stop = GRID_SIZE_X * stop.y + stop.x
	if translated_start < translated_stop
		ordered_start = translated_start
		ordered_end = translated_stop
	else
		ordered_start = translated_stop
		ordered_end = translated_start
	end
	nums = [ordered_start:ordered_end;]
	reduce(&, map(num -> isFree(Position(num % GRID_SIZE_X, floor(Int, num / GRID_SIZE_X)), object, state), nums))
end

function isFree(position::Position, object::Object, @nospecialize(state::State))
	# println("isFree")
	# @show position 
	# @show object
	length(filter(cell -> cell.position.x == position.x && cell.position.y == position.y,
		renderScene(Scene(filter(obj -> obj.id != object.id, state.scene.objects), state.scene.background), state))) == 0
end

function isFree(object::Object, @nospecialize(orig_object::Object), @nospecialize(state::State))::Bool
	l = map(x -> isFree(x, orig_object, state), map(cell -> cell.position, render(object, state)))
	l == [] ? true : reduce(&, l)
end

function allPositions(@nospecialize(state::State))
	GRID_SIZE = state.histories[:GRID_SIZE][0]
	if GRID_SIZE isa AbstractVector
		GRID_SIZE_X = GRID_SIZE[1]
		GRID_SIZE_Y = GRID_SIZE[2]
	else
		GRID_SIZE_X = GRID_SIZE
		GRID_SIZE_Y = GRID_SIZE
	end
	nums = [0:GRID_SIZE_X*GRID_SIZE_Y-1;]
	map(num -> Position(num % GRID_SIZE_X, floor(Int, num / GRID_SIZE_X)), nums)
end

function unfold(A::AbstractVector, state::Union{State, Nothing} = nothing)
	V = []
	for x in A
		for elt in x
			push!(V, elt)
		end
	end
	V
end

function range(n::Int, state::Union{State, Nothing} = nothing)
	if n == 0
		[0]
	elseif n < 0
		collect(1:-n)
	else
		collect(1:n)
	end
end

function floor(n::Union{Float64, Int}, state::Union{State, Nothing} = nothing)::Int
	floor(Int, n)
end

function round(n::Union{Float64, Int}, state::Union{State, Nothing} = nothing)::Int
	round(Int, n)
end

function defined(obj::Object, state::Union{State, Nothing} = nothing)
	obj.alive
end

# (= unitVectorObjPos (--> (obj pos)
#     (let
#       (= delta (deltaPos (.. obj origin) pos))
#       (= sign_x (sign (.. delta x)))
#       (= sign_y (sign (.. delta y)))
#       (if (and (== (abs sign_x) 1)
#                (== (abs sign_y) 1)) then
#           (Position sign_x 0) else (Position sign_x sign_y)
#       )
#     )
#   ))
function unitVectorObjPos(obj::Object, pos::Position, state::Union{State, Nothing} = nothing)
	unitVector(obj, pos, state)
end

end

