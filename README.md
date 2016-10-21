# hxassert
Assert utility for Haxe

## Assertion level
- Top level: `Assert.require` - generates always.
- Medium level: `Assert.expect` - could be disabled for release builds by defining `-D hxassert_no_expect`.
- Debug level: `Assert.assert` - generates only for `-debug` builds.

Look at method documentation for usage suggestions.

## Failure messages
```
var x = -1;
var y = 1;

// assert: x > 0
Assert.require(x > 0);

// assert: x > 0
// x: -1
// y: 1
// x + y: 0
Assert.require(x > 0, x, y, x + y);

// (x == y) failed: -1 != 1
// Validation: x + y = 0
Assert.require(x == y, "(${}) failed: $x != $y\nValidation: x + y = ${x + y}");

// ASSERTION FAILED
// Expression: x == y
// x: -1
// y: 1
Assert.require(x == y, "ASSERTION FAILED\nExpression: ${}", x, y);
```

## Failure handling

Errors could be recovered from throwing by handlers by calling `error.recovery()` method
Throwing could be disabled totally in release builds by defining `-D hxassert_mute`.
In case of muting errors throwing, they are dispatched and handled anyway.
That allows to recover, report and log critical failures in release builds without throwing assertion failure error.

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