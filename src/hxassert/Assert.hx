package hxassert;

import haxe.PosInfos;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

@:final
@:unreflective
class Assert {

	/**
		Add failures listener. Could be helpful for logging.
		Returns unsubscribe method. To remove listener just call it.
	**/
	public static function on(listener:Dynamic -> PosInfos -> Void):Void -> Void {
		_listeners.push(listener);
		return function() _listeners.remove(listener);
	}

	/**
		Assert `expression` is true.
	**/
	public macro static function that(expression:Expr, arguments:Array<Expr>):Expr {
		var error = DEFAULT_ASSERT_HEADER;
		var map = new Map<String, Dynamic>();

		if (arguments.length > 0) {
			var fa = arguments[0];
			switch(fa.expr) {
				case EConst(CString(message)):
					error = message != null ? message : "";
					arguments = arguments.slice(1);
				default:
			}
			for (argument in arguments) {
				var key = ExprTools.toString(argument);
				error += "\n" + key + ": {{" + key + "}}";
			}
		}

		var keys = extractKeys(error);
		var exprs:Array<Expr> = [];
		var valueExpr:Expr = null;
		for (key in keys) {
			if (key != "_") valueExpr = Context.parse(key, expression.pos);
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

	static var _listeners = [];

	static function getErrorMessage(message:String, map:Map<String, Dynamic>):String {
		var keys = extractKeys(message);
		for (key in keys) {
			if (map.exists(key)) {
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
			if (e < 0) {
				break;
			}
			keys.push(str.substring(i + 2, e));
			i = str.indexOf("{{", e + 2);
		}
		return keys;
	}
}