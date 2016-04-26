Elm.Native.Effects = {};
Elm.Native.Effects.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Effects = localRuntime.Native.Effects || {};
	if (localRuntime.Native.Effects.values)
	{
		return localRuntime.Native.Effects.values;
	}

	var Task = Elm.Native.Task.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);
	var Signal = Elm.Signal.make(localRuntime);
	var List = Elm.Native.List.make(localRuntime);

	function Queue(tasks) {
		this.tag = "Queue"
		this.ctor = this.tag
		this.tasks = tasks
	}

	function Tagged(f, fx) {
		this.tag = "Tagged"
		this.ctor = this.tag
		this.f = f
		this.fx = fx
	}

	function enqueue(fx, task) {
		return new Queue(fx.tasks.concat(task))
	}

	function queue(task) {
		return new Queue([task]);
	}

	function map(f, task) {
		return new Tagged(f, task)
	}

	var nil = Task.succeed(Utils.Tuple0)

	function queueToTask(address, fx) {
		var report = function(value) {
			return A2(Signal.send, address, Utils.Cons(value, Utils.Nil))
		};

		return Task.asyncFunction(function(callback) {
			var tasks = fx.tasks.splice(0);
			var index = 0;
			var count = tasks.length;
			while (index < count) {
				var task = tasks[index++];
				Task.perform(A2(Task.andThen, task, report));
			}
			callback(nil);
		});
	}

	function taggedF(tagged) {
		return tagged.f
	}

	function taggedFX(tagged) {
		return tagged.fx
	}

	return localRuntime.Native.Effects.values = {
		enqueue: F2(enqueue),
		queue: queue,
		queueToTask: F2(queueToTask),
		map: F2(map),
		taggedF: taggedF,
		taggedFX: taggedFX
	};

};
