import kext.Application;
import kext.AppState;
import kext.Application.ApplicationOptions;
import game.gameplay.GameState;

import kha.System.SystemOptions;
import kha.WindowOptions;

class Main {

	public static function main() {
		var windowOptions:WindowOptions = {

		}
		var systemOptions:SystemOptions = {
			width: Data.system.width,
			height: Data.system.height,
			title: Data.system.name,
			window: windowOptions
		};
		var applicationOptions:ApplicationOptions = {
			initState: GameState,
			bufferWidth: Data.system.bufferWidth,
			bufferHeight: Data.system.bufferHeight,
			defaultFontName: "KenPixel",
			platformServices: Data.system.platformServices,
			extAssetManifests: ["kextassets"]
		};
		#if debug
		applicationOptions.initState = cast(Type.resolveClass(Data.debug.statingState));
		#end
		new Application(systemOptions, applicationOptions);
	}

}