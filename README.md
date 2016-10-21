# hxassert
Assert utility for Haxe

## Failure messages
```
var x = -1;
var y = 1;

// assert: x > 0
Assert.that(x > 0);

// assert: x > 0
// x: -1
// y: 1
// x + y: 0
Assert.that(x > 0, x, y, x + y);

// (x == y) failed: -1 != 1
// Validation: x + y = 0
Assert.that(x == y, "(${}) failed: $x != $y\nValidation: x + y = ${x + y}");

// ASSERTION FAILED
// Expression: x == y
// x: -1
// y: 1
Assert.that(x == y, "ASSERTION FAILED\nExpression: ${}", x, y);
```

## Failure handling
```
// whatever
var disposeAssertLogging = Assert.on(
	function(err) {
		haxe.Log.trace(err.toString(), err.position);
		logToFile(err);
		openErrorReporter(err);

		// in case if you want to recover from throwing assert error immediately
		err.recover();
	}
);

// if need to remove listeners
disposeAssertLogging();
```