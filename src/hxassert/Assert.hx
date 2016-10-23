package hxassert;

import haxe.PosInfos;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;

/**
	There are `assert`, `expect` and `require` methods.

	Each method requires that first `expression` argument evaluates to `true`
	otherwise `AssertionFailureError` will be generated.

	Each `AssertionFailureError` could be handled by handlers before main throw happens.
	Handler could be added by `Assert.on` function.
	Each handler could call `AssertionFailureError::recover` method to prevent assertion exception throwing.
	Handlers are useful for logging, reporting and recovery mechanism.
	All throws could be muted in release build by `-D hxassert_mute`,
	but in this case all handlers will be called anyway.

	`arguments` is optional rest-argument, which could be used for expressions to evaluate in case of failure,
	 or for format strings.

	All constant strings in `arguments` will be used as format strings.
	If format strings are not provided - default message will be used "Assertion failed: ${}"
	`${}` is used to interpolate `expression`.
	Internal Haxe string interpolation could be used to print checked expressions results:
	`${expression to evaluate}` or `$expression`

	Other arguments will be used as shortcut to generate additional "arg: arg_value" lines.
**/

@:final
@:unreflective
class Assert {

	/**
		Add failures listener. Could be helpful for logging.
		Returns unsubscribe method. To remove listener just call it.
	**/
	//@:requires(handler != null)
	//@:ensure([] != null)
	public static function on(handler:AssertionFailureError -> Void):Void -> Void {
		_handlers.push(handler);
		return function() _handlers.remove(handler);
	}

	/**
		Top level assertions.
		Will be kept for release builds.
		Could be used for not performance critical code and released not fully tested modules
		Suitable for contracting API, glue-code, unexpected state.
	**/
	macro public static function require(expression:Expr, arguments:Array<Expr>):Expr {
		return __isTrue(expression, arguments);
	}

	/**
		Medium level assertion
		Could be removed from build by defining `hxassert_no_expect`.
		Suitable to check deep checkings, for example verify state each frame or check arrays content
	**/
	#if (debug || !hxassert_no_expect)
	macro public static function expect(expression:Expr, arguments:Array<Expr>):Expr {
		return __isTrue(expression, arguments);
	}
	#else
	macro public static function expect(expression, arguments:Array<Expr>) {
		return macro null;
	}
	#end

	/**
		Debug level assertions.
		Generates assert checkings only for `-debug` builds.
		Suitable for checking state assumptions in `private`/`internal` scope functions.
		Also suitable for debug mode state guards
	**/
	#if debug
	macro public static function assert(expression:Expr, arguments:Array<Expr>):Expr {
		return __isTrue(expression, arguments);
	}
	#else
	macro public static function assert(expression, arguments:Array<Expr>) {
		return macro null;
	}
	#end

	/** Throws assertion failure error with custom message **/

	public static function fail(reason:String = "Assert.fail", ?position:PosInfos) {
		throwError(new AssertionFailureError([reason], position));
	}

	/**
		Dispatch the error to handlers, and then throw assertion failure error, if error has not been recovered.

		`-D hxassert_mute` - disable error throwing
		but anyway run handlers to log / report about error
	**/

	public static function throwError(error:AssertionFailureError) {
		for (handler in _handlers) {
			handler(error);
		}
		#if (debug || !hxassert_mute)
		if (!error.recovered) {
			throw error;
		}
		#end
	}

	public static function throwAssertionFailureError(messages:Array<String>, ?position:PosInfos) {
		throwError(new AssertionFailureError(messages, position));
	}

	static var _handlers = [];

	#if macro
	static function __isTrue(expression:Expr, arguments:Array<Expr>):Expr {
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
				@:pos(expression.pos)
				hxassert.Assert.throwAssertionFailureError(${eFormatArray});
			}
		}
	}
	#end
}