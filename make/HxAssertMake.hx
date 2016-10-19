package ;

import hxmake.haxelib.HaxelibExt;
import hxmake.test.TestTask;
import hxmake.idea.IdeaPlugin;
import hxmake.haxelib.HaxelibPlugin;

using hxmake.haxelib.HaxelibPlugin;

class HxAssertMake extends hxmake.Module {

	function new() {
		config.classPath = ["src"];
		config.testPath = ["test"];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(HaxelibPlugin);
		apply(IdeaPlugin);

		library(
			function(ext:HaxelibExt) {
				ext.config.description = "General assert utility for Haxe";
				ext.config.contributors = ["eliasku"];
				ext.config.url = "https://github.com/eliasku/hxassert";
				ext.config.license = "MIT";
				ext.config.version = "0.1.0";
				ext.config.releasenote = "Initial release";
				ext.config.tags = ["utility", "assert", "contract", "debug"];

				ext.pack.includes = ["src", "haxelib.json", "README.md", "LICENSE"];
			}
		);

		var tt = new TestTask();
		tt.targets = ["neko", "swf", "js", "node", "cpp", "java", "cs"];
		tt.libraries = ["hxassert"];
		task("test", tt);
	}
}