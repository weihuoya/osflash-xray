import com.blitzagency.xray.logger.XrayLog;
import com.blitzagency.xray.util.XrayLoader;

/*
* NOTES: Use MtascUtility in your -trace tag with mtasc:
* 
* -trace com.blitzagency.xray.util.MtascUtility.trace
* 
* This class demonstrates how to load the connector so you can inspect your SWF at runtime
* 
* This sample includes the logger classes, which allows us to use XrayLog's. 
* 
* If you didn't include the logger classes and just loaded the SWF, you would then use:
* 
* _global.Xray.xrayLogger.debug("debug test"[, object]);
* or
* _global.com.blitzagency.xray.Xray.xrayLogger.debug("debug test"[, object]);
* 
* @author John Grden
* */

class Main
{
	public static var app : Main;
	private var log:XrayLog;

	function Main() 
	{		
		XrayLoader.addEventListener(XrayLoader.LOADCOMPLETE, this, "xrayLoadComplete");
		XrayLoader.addEventListener(XrayLoader.LOADERROR, this, "xrayLoadError");
		XrayLoader.loadConnector("xrayConnector_1.6.3.swf");
	}

	// entry point
	public static function main(mc) 
	{
		app = new Main();
	}
	
	private function run(evtObj:Object):Void
	{		
		// create bogus object for tracing
		var obj:Object = {};
		obj["John"] = {};
		obj["John"].phone = "ring";
		
		// Create a log instance
		log = new XrayLog();
		
		/*usage
		* 
		* 	log.debug("testing Logger", obj);
			log.info("testing Logger", obj);
			log.warn("testing Logger", obj);
			log.error("testing Logger", obj);
			log.fatal("testing Logger", obj);
		* 
		* */
		
		// Pass it through trace.  Mtasc will change this out when it compiles to go through MtascUtility
		trace(log.debug("testing Logger", obj));
	}
	
	private function xrayLoadComplete():Void
	{
		run();
	}

	private function xrayLoadError():Void
	{
		trace("an error occured loading the Xray connector");
		run(); // try to load the app anyway
	}
}