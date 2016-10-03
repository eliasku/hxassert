package hxassert;

@:final
class Assert {

	var _handlers:Array<AssertHandler> = [];

	public macro static function that(actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		return macro if(!($actual)) ${error(actual, "Assert failed", description)};
#end
	}

	public macro static function notNull(actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		return macro if(($actual) == null) ${error(actual, "Expected not null", description)};
#end
	}

	public macro static function isNull(actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = formatErrorMessage(actual, "Expected null but it's {0}", description);
		return macro {
			var __actualValue = $actual;
			if(__actualValue != null) throw @:privateAccess Assert.format($v{errorMessage}, [__actualValue]);
		}
#end
	}

	public macro static function isTrue(actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		return macro if(($actual) != true) ${error(actual, "Expected true", description)};
#end
	}

	public macro static function isFalse(actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		return macro if(($actual) != false) ${error(actual, "Expected false", description)};
#end
	}

	public macro static function equals(expected:haxe.macro.Expr, actual:haxe.macro.Expr, description:String = null):haxe.macro.Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = formatErrorMessage(actual, "Expected {0} but it's {1}", description);
		return macro {
			var __expectedValue = $expected;
			var __actualValue = $actual;
			if(__expectedValue != __actualValue) throw @:privateAccess Assert.format($v{errorMessage}, [__expectedValue, __actualValue]);
		}
#end
	}

	public macro static function fail(reason:String = null):haxe.macro.Expr {
#if (hxassert_disable || hxassert_noexept)
		return macro null;
#else
		if(reason == null) {
			reason = "Assert.fail";
		}
		return macro {
			throw $v{reason};
		}
#end
	}

#if macro
	static function formatErrorMessage(expr:haxe.macro.Expr, message:String, customMessage:String):String {
		var msg = message + '\nExpression: ${haxe.macro.ExprTools.toString(expr)}';
		if(customMessage != null) {
			msg += '\nDescription: $customMessage';
		}
		return msg;
	}

	static function error(expr:haxe.macro.Expr, message:String, customMessage:String):haxe.macro.Expr {
		return macro throw $v{formatErrorMessage(expr, message, customMessage)};
	}
#end

	static function format(message:String, arguments:Array<Dynamic>):String {
		for(i in 0...arguments.length) {
			message = message.replace('{$i}', Std.string(arguments[i]));
		}
		return message;
	}
}