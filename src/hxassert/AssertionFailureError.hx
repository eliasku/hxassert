package hxassert;

import haxe.CallStack;
import haxe.PosInfos;

class AssertionFailureError {

	public var callstack(default, null):Array<StackItem>;
	public var position(default, null):PosInfos;
	public var recovered(default, null):Bool = false;

	var _messages:Array<String>;
	var _evaluations:Map<String, Dynamic>;

	public function new(messages:Array<String>, ?infos:PosInfos) {
		_messages = messages;
		position = infos;
		callstack = CallStack.callStack();
	}

	public function toString():String {
		return _messages.join("\n");
	}

	public function getCallStackText():String {
		return callstack != null ? CallStack.toString(callstack) : "";
	}

	inline public function recovery() {
		recovered = true;
	}
}
