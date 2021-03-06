# hxassert

[![Build Status](https://travis-ci.org/eliasku/hxassert.svg?branch=master)](https://travis-ci.org/eliasku/hxassert)
[![Build status](https://ci.appveyor.com/api/projects/status/sply9dxqg2fhbpkn?svg=true)](https://ci.appveyor.com/project/eliasku/hxassert)

[![Lang](https://img.shields.io/badge/language-haxe-orange.svg)](http://haxe.org)
[![Version](https://img.shields.io/badge/version-v0.1.0-green.svg)](https://github.com/eliasku/hxassert)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

Assert utility for Haxe.
Lightweight library deliveries flexible base functionality on assertions.
It could be used as standard assert library.
It could provide base API for more high-level tools as "matching extensions", "contract-by-design", "assert-that notation".

[API documentation](https://eliasku.github.io/hxassert/api-minimal/)

## Status
API is not final yet. Development is in progress.
Feel free to suggest better naming, API hacks, and compatibility features!

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