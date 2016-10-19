package hxassert;

import haxe.macro.Context;
import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

@:final
@:unreflective
class Assert {

	/**
		Add failures listener. Could be helpful for logging.
		Returns unsubscribe method. To remove listener just call it.
	**/
	public static function on(listener:Dynamic->PosInfos->Void):Void->Void {
		_listeners.push(listener);
		return removeListener.bind(listener);
	}

	/**
		Assert `expression` is true.
	**/
	public macro static function that(expression:Expr, arguments:Array<Expr>):Expr {
		var error = DEFAULT_ASSERT_HEADER;
		var map = new Map<String, Dynamic>();

		if(arguments.length > 0) {
			var fa = arguments[0];
			switch(fa.expr) {
				case EConst(CString(message)):
					error = message != null ? message : "";
					arguments = arguments.slice(1);
				default:
			}
			for(argument in arguments) {
				var key = ExprTools.toString(argument);
				error += "\n" + key + ": {{" + key + "}}";
			}
		}

		var keys = extractKeys(error);
		var exprs:Array<Expr> = [];
		var valueExpr:Expr = null;
		for(key in keys) {
			if(key != "_") valueExpr = Context.parse(key, expression.pos);
			else valueExpr = macro $v{ExprTools.toString(expression)};
			exprs.push(
				macro __watch_map.set($v{key}, $valueExpr)
			);
		}

		return macro {
			if (false == ($expression)) {
				var __watch_map = new Map<String, Dynamic>();
				$b{exprs};

				@:pos(expression.pos)
				hxassert.Assert.fail(
					@:privateAccess
					hxassert.Assert.getErrorMessage(
						$v{error},
						__watch_map
					)
				);
			}
		}
	}

	public static function fail(reason:String = "FAIL", ?infos:PosInfos) {
#if !hxassert_disable
		for (listener in _listeners) {
			listener(reason, infos);
		}
		throw reason;
#end
	}

	static inline var DEFAULT_ASSERT_HEADER:String = "assert: {{_}}";

	static var _listeners:Array<Dynamic->PosInfos->Void> = [];

	static function getErrorMessage(message:String, map:Map<String, Dynamic>):String {
		var keys = extractKeys(message);
		for(key in keys) {
			if(map.exists(key)) {
				message = StringTools.replace(message, '{{$key}}', Std.string(map.get(key)));
			}
		}
		return message;
	}

	static function extractKeys(str:String):Array<String> {
		var keys = [];
		var i = str.indexOf("{{");
		while (i >= 0) {
			var e = str.indexOf("}}", i + 2);
			if(e < 0) {
				break;
			}
			keys.push(str.substring(i + 2, e));
			i = str.indexOf("{{", e + 2);
		}
		return keys;
	}

	static function removeListener(f) {
		_listeners.remove(f);
	}

//
//	public macro static function notNull(actual:Expr, ?message:String):Expr {
//#if hxassert_disable
//		return macro null;
//#else
//		var errorMessage = format(message != null ? message : "`{0}` shoud not be `null`", [
//			ExprTools.toString(actual)
//		]);
//
//		return macro {
//			if (null == ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
//		}
//#end
//	}
//
//	public macro static function isNull(actual:Expr, ?message:String):Expr {
//#if hxassert_disable
//		return macro null;
//#else
//		var errorMessage = format(message != null ? message : "`{0}` shoud be `null`", [
//			ExprTools.toString(actual)
//		]);
//
//		return macro {
//			if (null != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
//		}
//#end
//	}
//
//	public macro static function isTrue(actual:Expr, ?message:String):Expr {
//#if hxassert_disable
//		return macro null;
//#else
//		var errorMessage = format(message != null ? message : "`{0}` shoud be `true`", [
//			ExprTools.toString(actual)
//		]);
//
//		return macro {
//			if (true != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
//		}
//#end
//	}
//
//	public macro static function isFalse(actual:Expr, ?message:String):Expr {
//#if hxassert_disable
//		return macro null;
//#else
//		var errorMessage = format(message != null ? message : "`{0}` shoud be `false`", [
//			ExprTools.toString(actual)
//		]);
//
//		return macro {
//			if (false != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
//		}
//#end
//	}
//
//	public macro static function equals(expected:Expr, actual:Expr, ?message:String):Expr {
//#if hxassert_disable
//		return macro null;
//#else
//		var errorMessage = format(message != null ? message : "`{1}` shoud be `{0}`", [
//			ExprTools.toString(actual),
//			ExprTools.toString(expected)
//		]);
//
//		return macro {
//			if (($expected) != ($actual)) @:pos(actual.pos) hxassert.Assert.fail($v{errorMessage});
//		}
//#end
//	}
//
//#if macro
//
//	static function formatErrorMessage(expr:Expr, message:String, customMessage:String):String {
//		var msg = message + '\nExpression: ${ExprTools.toString(expr)}';
//		if (customMessage != null) {
//			msg += '\nDescription: $customMessage';
//		}
//		return msg;
//	}
//
//	static function error(expr:Expr, message:String, customMessage:String):Expr {
//		return macro @:pos(expr.pos) hxassert.Assert.fail($v{formatErrorMessage(expr, message, customMessage)});
//	}
//#end
}