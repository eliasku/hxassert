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
		Log.trace(failure.toString(), failure.position);
	}

	public function testSimple() {
		try {
			hxassert.Assert.require(one == zero, "0 should be 1");
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("0 should be 1", err.toString());
		}

		try {
			hxassert.Assert.require(one == zero);
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Assertion failed: one == zero", err.toString());
		}

		hxassert.Assert.require(zero == zero, "0 should equals 0", Math.PI);
		hxassert.Assert.require(one == one, Math.PI);
		hxassert.Assert.require(two == two);
	}

	public function testMessageFormat() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.require(a == b, '${} $a $b ${a - b}');
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("a == b 0 1 -1", err);
		}
	}

	public function testMessageArguments() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.require(a == b, a, b, a - b);
		}
		catch (err:AssertionFailureError) {
			utest.Assert.equals("Assertion failed: a == b\na: 0\nb: 1\na - b: -1", err.toString());
		}
	}

	public function testMessageMixed() {
		try {
			var a = zero;
			var b = one;
			hxassert.Assert.require(a == b, "How come? (${}) => ($a != $b)\nProve:", a, b);
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

	public function testCallStack() {
		try {
			hxassert.Assert.throwError(new AssertionFailureError(["Test"]));
		}
		catch (err:AssertionFailureError) {
			utest.Assert.isTrue(err.getCallStackText() != null);
		}
	}

	public function testNoDebug() {
		hxassert.Assert.assert(1 == 0);
		utest.Assert.pass("assert() is only for -debug builds");
	}
}
