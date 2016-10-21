package hxassert;

import haxe.Log;
@:final
class AssertTest {

	var _disposeTrace:Void->Void;
	var zero:Int;
	var one:Int;
	var two:Int;

	public function new() {}

	public function setup() {
		_disposeTrace = hxassert.Assert.on(onAssert);
		zero = Math.random() > 1 ? 1 : 0;
		one = 1 - zero;
		two = one + one;
	}

	public function teardown() {
		_disposeTrace();
	}

	static function onAssert(failure:AssertionFailureError) {
		Log.trace(failure.toString() + failure.getCallStackText(), failure.position);
	}

	public function testSimple() {
		try {
			hxassert.Assert.that(one == zero, "0 should be 1");
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("0 should be 1", err.toString());
		}

		try {
			hxassert.Assert.that(one == zero);
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Assertion failed: one == zero", err.toString());
		}

		hxassert.Assert.that(zero == zero, "0 should equals 0", Math.PI);
		hxassert.Assert.that(one == one, Math.PI);
		hxassert.Assert.that(two == two);
	}

	public function testMessageFormat() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.that(a == b, "{{_}} {{a}} {{b}} {{a - b}}");
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("a == b 0 1 -1", err);
		}
	}

	public function testMessageArguments() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.that(a == b, a, b, a - b);
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Assertion failed: a == b\na: 0\nb: 1\na - b: -1", err.toString());
		}
	}

	public function testMessageMixed() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.that(a == b, "How come? ({{_}}) => ({{a}} != {{b}})\nProve:", a, b);
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("How come? (a == b) => (0 != 1)\nProve:\na: 0\nb: 1", err.toString());
		}
	}

	public function testFail() {
		try {
			hxassert.Assert.fail();
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Assert.fail", err.toString());
		}

		try {
			hxassert.Assert.fail("Have a reason");
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Have a reason", err.toString());
		}
	}

//	public function testNotNull() {
//		var nullStr:String = null;
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.notNull(nullStr, "string should be not null");
//		});
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.notNull(nullStr);
//		});
//
//		var str = "some string";
//		hxassert.Assert.notNull(str, "string should be not null");
//		hxassert.Assert.notNull("my value");
//	}
//
//	public function testIsNull() {
//		utest.Assert.raises(function() {
//			hxassert.Assert.isNull("not null string", "string should be null");
//		});
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.isNull("not null string");
//		});
//
//		var nullStr:String = null;
//		hxassert.Assert.isNull(nullStr, "string should be null");
//		hxassert.Assert.isNull(null);
//	}
//
//	public function testIsTrue() {
//		utest.Assert.raises(function() {
//			hxassert.Assert.isTrue(false, "should be true");
//		});
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.isTrue(false);
//		});
//
//		hxassert.Assert.isTrue(true);
//		hxassert.Assert.isTrue(true, "should be true");
//	}
//
//	public function testIsFalse() {
//		utest.Assert.raises(function() {
//			hxassert.Assert.isFalse(true, "should be false");
//		});
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.isFalse(true);
//		});
//
//		hxassert.Assert.isFalse(false);
//		hxassert.Assert.isFalse(false, "should be false");
//	}
//
//	public function testEquals() {
//
//		var helloString = "Hello";
//		utest.Assert.raises(function() {
//			hxassert.Assert.equals("Hi", "He" + "llo", "{0} concatination should be Hi?");
//		});
//
//		utest.Assert.raises(function() {
//			hxassert.Assert.equals("Hi", helloString);
//		});
//
//		var hiString = "Hi";
//		hxassert.Assert.equals("Hi", hiString);
//		hxassert.Assert.equals("Hi", hiString, "{0} should be Hi");
//	}
}
