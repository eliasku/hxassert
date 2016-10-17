package hxassert;

@:final
class AssertTest {

	public function new() {}

	public function setup() {
		hxassert.Assert.add(hxassert.Assert.traceAssert);
	}

	public function teardown() {
		hxassert.Assert.remove(hxassert.Assert.traceAssert);
	}

	public function testThat() {
		utest.Assert.raises(function() {
			hxassert.Assert.that(1 == 0, "0 should be 1");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.that(1 == 0);
		});

		hxassert.Assert.that(0 == 0, "0 should equals 0");
		hxassert.Assert.that(1 == 1);
	}

	public function testNotNull() {
		var nullStr:String = null;

		utest.Assert.raises(function() {
			hxassert.Assert.notNull(nullStr, "string should be not null");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.notNull(nullStr);
		});

		var str = "some string";
		hxassert.Assert.notNull(str, "string should be not null");
		hxassert.Assert.notNull("my value");
	}

	public function testIsNull() {
		utest.Assert.raises(function() {
			hxassert.Assert.isNull("not null string", "string should be null");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.isNull("not null string");
		});

		var nullStr:String = null;
		hxassert.Assert.isNull(nullStr, "string should be null");
		hxassert.Assert.isNull(null);
	}

	public function testIsTrue() {
		utest.Assert.raises(function() {
			hxassert.Assert.isTrue(false, "should be true");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.isTrue(false);
		});

		hxassert.Assert.isTrue(true);
		hxassert.Assert.isTrue(true, "should be true");
	}

	public function testIsFalse() {
		utest.Assert.raises(function() {
			hxassert.Assert.isFalse(true, "should be false");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.isFalse(true);
		});

		hxassert.Assert.isFalse(false);
		hxassert.Assert.isFalse(false, "should be false");
	}

	public function testEquals() {

		var helloString = "Hello";
		utest.Assert.raises(function() {
			hxassert.Assert.equals("Hi", "He" + "llo", "{0} concatination should be Hi?");
		});

		utest.Assert.raises(function() {
			hxassert.Assert.equals("Hi", helloString);
		});

		var hiString = "Hi";
		hxassert.Assert.equals("Hi", hiString);
		hxassert.Assert.equals("Hi", hiString, "{0} should be Hi");
	}

	public function testFail() {
		utest.Assert.raises(function() {
			hxassert.Assert.fail();
		});

		utest.Assert.raises(function() {
			hxassert.Assert.fail("my reason");
		});
	}
}
