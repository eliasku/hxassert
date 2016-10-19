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
Assert.that(x == y, "({{_}}) failed: {{x}} != {{y}}\nValidation: x + y = {{x + y}}");

// ASSERTION FAILED
// Expression: x == y
// x: -1
// y: 1
Assert.that(x == y, "ASSERTION FAILED\nExpression: {{_}}", x, y);
```

## Listen failures
```
// just trace
var disposeAssertTracer = Assert.on(haxe.Log.trace);

// or whatever
var disposeAssertLogging = Assert.on(
	function(err:String, infos:PosInfos) {
		logToFile(err);
		openErrorReporter(err);
	}
);

// if need to remove listeners
disposeAssertTracer();
disposeAssertLogging();
```

## Exceptions
- Exceptions are String objects with reason of failure

`-D hxassert_disable` - all asserts are disabled
