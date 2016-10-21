package hxassert;

import haxe.CallStack;
import haxe.PosInfos;

class AssertionFailureError {

	public var callstack(default, null):Array<StackItem>;
	public var position(default, null):PosInfos;
	public var recovered(default, null):Bool = false;

	var _formats:Array<String>;
	var _evaluations:Map<String, Dynamic>;

	public function new(formats:Array<String>, ?evaluations:Map<String, Dynamic>, ?infos:PosInfos) {
		_formats = formats;
		_evaluations = evaluations;
		position = infos;
		callstack = CallStack.callStack();
	}

	public function toString():String {
		return getErrorMessage(_formats.join("\n"), _evaluations);
	}

	public function getCallStackText():String {
		return callstack != null ? CallStack.toString(callstack) : "";
	}

	inline public function recovery() {
		recovered = true;
	}

	static function getErrorMessage(formatString:String, ?evaluationResults:Map<String, Dynamic>):String {
		if(evaluationResults != null) {
			for (key in evaluationResults.keys()) {
				formatString = StringTools.replace(formatString, '{{$key}}', Std.string(evaluationResults.get(key)));
			}
		}
		return formatString;
	}
}
