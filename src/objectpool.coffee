
### Object Pool: Allocate and re-use objects so they never cause GC pauses. ###

# First, define the simplest possible coupling for use in a linked list.
link = (item, next) -> { item, next }

# Use the link coupling to manage two lists, one for the stack, one for the trash.
class Stack
	constructor: ->
		@trash = link null, null # lists are null-terminated
		@data = link null, null
		@peak = @length = 0 # track the current and peak size
	push: (item) ->
		if @trash.next isnt null # re-use a wrapper out of the trash
			node = @trash
			@trash = @trash.next
			node.item = item
			node.next = @data
		else # if trash is empty, make a new wrapper
			node = link item, @data
		@length += 1
		if @length > @peak
			@peak = @length
		@data = node # push node on top of the stack
	pop: ->
		return undefined if @data.next is null
		node = @data
		@data = @data.next
		@length -= 1
		ret = node.item
		node.item = node.next = null
		@trash = link node, @trash
		return ret
	isEmpty: -> @data.next is null

class ObjectPool
	constructor: (@klass) ->
		@pool = new Stack()
	alloc: ->
		if not @pool.isEmpty()
			ret = @pool.pop()
			@klass.apply ret, arguments
		else ret = new @klass arguments...
		ret
	free: (item) ->
		@pool.push item
	toString: -> "{ObjectPool[#{@klass.name}] #{@pool.length}/#{@pool.peak}}"

Pooled = (klass) ->
	pool = new ObjectPool(klass)
	klass.alloc = pool.alloc.bind pool
	klass::free = -> pool.free @
	klass

module.exports.ObjectPool = ObjectPool
module.exports.Pooled = Pooled

