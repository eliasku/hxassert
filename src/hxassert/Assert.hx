package hxassert;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.PosInfos;

@:final
class Assert {

	static var _handlers:Array<AssertHandler> = [];

	public static function add(handler:AssertHandler) {
		_handlers.push(handler);
	}

	public static function remove(handler:AssertHandler) {
		_handlers.remove(handler);
	}

	public macro static function that(actual:Expr, message:String = null):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{0}` condition shoud be true", [
			ExprTools.toString(actual)
		]);

		return macro {
			if(false == ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

	public macro static function notNull(actual:Expr, ?message:String):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{0}` shoud not be `null`", [
			ExprTools.toString(actual)
		]);

		return macro {
			if(null == ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

	public macro static function isNull(actual:Expr, ?message:String):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{0}` shoud be `null`", [
			ExprTools.toString(actual)
		]);

		return macro {
			if(null != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

	public macro static function isTrue(actual:Expr, ?message:String):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{0}` shoud be `true`", [
			ExprTools.toString(actual)
		]);

		return macro {
			if(true != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

	public macro static function isFalse(actual:Expr, ?message:String):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{0}` shoud be `false`", [
			ExprTools.toString(actual)
		]);

		return macro {
			if(false != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

	public macro static function equals(expected:Expr, actual:Expr, ?message:String):Expr {
#if hxassert_disable
		return macro null;
#else
		var errorMessage = format(message != null ? message : "`{1}` shoud be `{0}`", [
			ExprTools.toString(actual),
			ExprTools.toString(expected)
		]);

		return macro {
			if(($expected) != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
		}
#end
	}

#if macro
	static function formatErrorMessage(expr:Expr, message:String, customMessage:String):String {
		var msg = message + '\nExpression: ${ExprTools.toString(expr)}';
		if(customMessage != null) {
			msg += '\nDescription: $customMessage';
		}
		return msg;
	}

	static function error(expr:Expr, message:String, customMessage:String):Expr {
		return macro @:pos(expr.pos) hxassert.Assert.fail($v{formatErrorMessage(expr, message, customMessage)});
	}
#end

	public static function fail(?reason:String, ?infos:PosInfos) {
#if !hxassert_disable
		for(handler in _handlers) {
			handler(reason, infos);
		}
	#if !hxassert_noexept
		throw reason;
	#end
#end
	}

	static function format(message:String, arguments:Array<Dynamic>):String {
		for(i in 0...arguments.length) {
			message = StringTools.replace(message, '{$i}', Std.string(arguments[i]));
		}
		return message;
	}

	public static function traceAssert(message:Dynamic, infos:PosInfos) {
		haxe.Log.trace(message, infos);
	}
}