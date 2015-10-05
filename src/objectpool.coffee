### Object Pool: Allocate and re-use objects so they never cause GC pauses. ###

{min, max, abs} = Math

# First, define the simplest possible coupling for use in a linked list.
link = (item, next) -> { item, next }

# Use the link coupling to define a garbage-free last-in-first-out linked-list.
class Stack
	constructor: ->
		# Keep track of our own trash, for re-use.
		@trash = link null, null # lists are null-terminated
		@data = link null, null
		# Keep track of the current (and peak) number of items in-use.
		@peak = @length = 0
	push: (item) ->
		# If there is a link in the trash, re-use the top one.
		if @trash isnt null
			node = @trash
			@trash = @trash.next
			node.item = item
			node.next = @data
		# Otherwise, the trash is empty. Make a new link.
		else
			node = link item, @data
		# Adjust the length (and peak).
		@length += 1
		@peak = max @peak, @length
		# Push the node on top of the stack.
		@data = node
	peek: -> @data.item
	pop: ->
		# Calling pop() on an empty stack returns undefined.
		return undefined if @data.next is null
		# Consume the top data item.
		node = @data
		@data = @data.next
		@length -= 1
		# Save the return value out of the link.
		ret = node.item
		# Wipe the link off before trashing it.
		node.item = null
		# Put the node on top of the trash.
		node.next = @trash
		@trash = node
		return ret
	isEmpty: -> @data.next is null

class ObjectPool
	constructor: (klass) ->
		@klass = klass
		pool = new Stack()
		apply = (n, args) ->
			klass.apply n, args
			n
		@alloc = ->
			return if pool.isEmpty() then apply Object.create(@klass.prototype), arguments
			else apply pool.pop(), arguments
		@free = (item) ->
			return unless item?
			item.destructor?()
			pool.push item
		@toString = -> "{ObjectPool[#{klass.name}] #{pool.length}/#{pool.peak}}"

Pooled = (klass) ->
	pool = new ObjectPool(klass)
	klass.alloc = pool.alloc.bind pool
	klass::free = -> pool.free @
	klass

module.exports.ObjectPool = ObjectPool
module.exports.Pooled = Pooled

