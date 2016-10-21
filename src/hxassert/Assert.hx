package hxassert;

import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;

@:final
@:unreflective
class Assert {

	/**
		Add failures listener. Could be helpful for logging.
		Returns unsubscribe method. To remove listener just call it.
	**/
	@:requires(listener != null)
	@:ensure([] != null)
	public static function on(listener:AssertionFailureError -> Void):Void -> Void {
		_listeners.push(listener);
		return function() _listeners.remove(listener);
	}

	/**
		Assert `expression` is true.

		`arguments` is optional rest-argument, which could be used for expressions to evaluate in case of failure,
		 or for format strings.

		All contant strings in `arguments` will be used as Formatter strings.
		Other arguments will be used as extra evaluations (they will be added to message as well)

		Each Formatter string could have evaluation blocks in Haxe string interpolation format:
		`${expression to evaluate}` or `$expression`

		If format lines are not provided - default message will be used

		All `arguments` evaluations will be performed only in case of assertion failure.
	**/

	public macro static function that(expression:Expr, arguments:Array<Expr>):Expr {
		var formatStrings = [];
		var formatPos = [];
		var hasFormatters = false;
		var expressionString = ExprTools.toString(expression);

		for (argument in arguments) {
			var fmtval = switch(argument.expr) {
				case EConst(CString(x)):
					hasFormatters = true;
					StringTools.replace(x, "${}", expressionString);
				default:
					StringTools.replace("-%-: ${-%-}", "-%-", ExprTools.toString(argument));
			}
			formatStrings.push(fmtval);
			formatPos.push(argument.pos);
		}

		if (!hasFormatters) {
			formatStrings.unshift("Assertion failed: " + expressionString);
			formatPos.unshift(expression.pos);
		}

		var eFormatArray = {
			expr: EArrayDecl([
				for (i in 0...formatStrings.length) MacroStringTools.formatString(formatStrings[i], formatPos[i])
			]),
			pos: expression.pos
		};

		return macro {
			if (false == ($expression)) {
				hxassert.Assert.throwError(
					@:pos(expression.pos)
					new AssertionFailureError(${eFormatArray})
				);
			}
		}
	}

	/** Throws assertion failure error with custom message **/

	public static function fail(reason:String = "Assert.fail", ?position:PosInfos) {
		throwError(new AssertionFailureError([reason], position));
	}

	/** Throw assertion failure error into the pipe with possibility to log or recover **/

	public static function throwError(error:AssertionFailureError) {
		for (listener in _listeners) {
			listener(error);
		}
		if (!error.recovered) {
			throw error;
		}
	}

	static var _listeners = [];
}