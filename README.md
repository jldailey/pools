
Object pools can help prevent pauses due to garbage collection.

Most useful in real-time applications (e.g, games) where objects are created and
discarded at a high rate.

Usage
-----

As a stand-alone pool:

		{ObjectPool} = require 'pooled'

    pool = new ObjectPool(MyClass)
		x = pool.alloc(...) # use the same arguments as in 'new MyClass(...)'
		pool.free(x) # the corpse of x will be re-animated in alloc()

As a class decorator (my preferred method):

    {Pooled} = require 'pooled'
		Pooled class MyClass
			constructor: (junk) ->
		x = MyClass.alloc(...)
		x.free()

