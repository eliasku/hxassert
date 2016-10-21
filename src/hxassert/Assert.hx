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

		Each Formatter string could have evaluation blocks in format:
		`{{expression to evaluate}}`

		If format lines are not provided - default message will be used

		All `arguments` evaluations will be performed only in case of assertion failure.
	**/

	public macro static function that(expression:Expr, arguments:Array<Expr>):Expr {
		var evaluations = new Map<String, Int>();
		var formatStrings = [];
		var formatPos = [];
		var hasFormatters = false;
		var expressionString = ExprTools.toString(expression);

		for (argument in arguments) {
			switch(argument.expr) {
				case EConst(CString(x)):
					pushExpressionsFromFormat(x, evaluations);
					formatStrings.push(x);
					formatPos.push(argument.pos);
					hasFormatters = true;
				default:
					var evalExprString = ExprTools.toString(argument);
					evaluations.set(evalExprString, 1);
					formatStrings.push('$evalExprString: {{$evalExprString}}');
					formatPos.push(argument.pos);
			}
		}

		if (!hasFormatters) {
			formatStrings.unshift("Assertion failed: " + expressionString);
			formatPos.unshift(expression.pos);
		}

		var exprs:Array<Expr> = [];
		var valueExpr:Expr = null;
		for (evaluation in evaluations.keys()) {
			if (evaluation != "_") valueExpr = Context.parse(evaluation, expression.pos);
			else valueExpr = macro $v{ExprTools.toString(expression)};
			exprs.push(macro {
				try {
					__eval_result = $valueExpr;
				}
				catch(__eval_error:Dynamic) {
					__eval_result = "Evaluation failed";
				}
				__eval_map.set($v{evaluation}, __eval_result);
			});
		}

		var eFormatArray = {
			expr: EArrayDecl([
				for (i in 0...formatStrings.length) {
					expr: EConst(CString(formatStrings[i])),
					pos: formatPos[i]
				}
			]),
			pos: expression.pos
		};

		return macro {
			if (false == ($expression)) {
				var __eval_map = new Map<String, Dynamic>();
				var __eval_result:Dynamic;

				$b{exprs};

				hxassert.Assert.throwError(
					@:pos(expression.pos)
					new AssertionFailureError(${eFormatArray}, __eval_map)
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

	static function pushExpressionsFromFormat(formatString:String, outResult:Map<String, Int>) {
		var i = formatString.indexOf("{{");
		while (i >= 0) {
			var e = formatString.indexOf("}}", i + 2);
			if (e < 0) {
				break;
			}
			outResult.set(formatString.substring(i + 2, e), 1);
			i = formatString.indexOf("{{", e + 2);
		}
	}
}