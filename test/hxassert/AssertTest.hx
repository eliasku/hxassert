package hxassert;

import haxe.Log;
@:final
class AssertTest {

	var _disposeTrace:Void->Void;

	public function new() {}

	public function setup() {
		_disposeTrace = hxassert.Assert.on(Log.trace);
	}

	public function teardown() {
		_disposeTrace();
	}

	static function onAssert(msg, _) {
		trace(msg);
	}

	public function testSimple() {
		try {
			hxassert.Assert.that(1 == 0, "0 should be 1");
		}
		catch (err:String) {
			utest.Assert.equals("0 should be 1", err);
		}

		try {
			hxassert.Assert.that(1 == 0);
		}
		catch (err:String) {
			utest.Assert.equals("assert: 1 == 0", err);
		}

		hxassert.Assert.that(0 == 0, "0 should equals 0", Math.PI);
		hxassert.Assert.that(1 == 1, Math.PI);
		hxassert.Assert.that(2 == 2);
	}

	public function testMessageFormat() {
		try {
			var a = 0;
			var b = 1;
			hxassert.Assert.that(a == b, "{{_}} {{a}} {{b}} {{a - b}}");
		}
		catch (err:String) {
			utest.Assert.equals("a == b 0 1 -1", err);
		}
	}

	public function testMessageArguments() {
		try {
			var a = 0;
			var b = 1;
			hxassert.Assert.that(a == b, a, b, a - b);
		}
		catch (err:String) {
			utest.Assert.equals("assert: a == b\na: 0\nb: 1\na - b: -1", err);
		}
	}

	public function testMessageMixed() {
		try {
			var a = 0;
			var b = 1;
			hxassert.Assert.that(a == b, "How come? ({{_}}) => ({{a}} != {{b}})\nProve:", a, b);
		}
		catch (err:String) {
			utest.Assert.equals("How come? (a == b) => (0 != 1)\nProve:\na: 0\nb: 1", err);
		}
	}

	public function testFail() {
		try {
			hxassert.Assert.fail();
		}
		catch (err:String) {
			utest.Assert.equals("FAIL", err);
		}

		try {
			hxassert.Assert.fail("Have a reason");
		}
		catch (err:String) {
			utest.Assert.equals("Have a reason", err);
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
