
assert = require 'assert'
{Pooled, ObjectPool} = require "../lib/objectpool.js"

describe "ObjectPool", ->
	it "is constructable", ->
		class Test
		pool = new ObjectPool(Test)
		assert.equal typeof pool.alloc, 'function'
		assert.equal typeof pool.free, 'function'
		assert.equal pool.klass, Test
	describe ".alloc(args...)", ->
		it "creates new items if pool is empty", (done) ->
			class Test then constructor: (@v) ->
				@ts ?= +new Date # test objects track their original creation time
			pool = new ObjectPool(Test)
			a = pool.alloc 1
			assert.equal a.v, 1
			setTimeout (->
				b = pool.alloc 2
				assert.notEqual a.ts, b.ts
				assert.equal b.v, 2
				done()
			), 10
	describe ".free(object)", ->
		it "allows object to be re-allocated", (done) ->
			class Test then constructor: (@v) ->
				@ts ?= +new Date # test objects track their original creation time
			pool = new ObjectPool(Test)
			a = pool.alloc 1
			pool.free a
			setTimeout (->
				b = pool.alloc 2
				# even though this is later, the ts should have been re-used
				assert.equal b.ts, a.ts
				assert.equal b.v, 2
				done()
			), 10
		it "calls object.destructor if available", ->
			class Test
				constructor: -> @status = 'up'
				destructor:  -> @status = 'down'
			pool = new ObjectPool(Test)
			a = pool.alloc()
			assert.equal a.status, 'up'
			pool.free(a)
			assert.equal a.status, 'down'
			b = pool.alloc()
			assert.equal b.status, 'up'


describe "Pooled", ->
	it "is a class decorator", ->
		Pooled class Test
			constructor: (@v) -> @ts ?= +new Date
			destructor: -> @v = null

		f = Test.alloc 10
		assert.equal f.v, 10
		f.free()
		assert.equal f.v, null
