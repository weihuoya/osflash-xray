import com.blitzagency.xray.logger.LogManager;
import com.blitzagency.xray.logger.XrayLog;

/*
* NOTES: Use MtascUtility in your -trace tag with mtasc:
* 
* -trace com.blitzagency.xray.util.MtascUtility.trace
* 
* @author John Grden
* */

class Main
{
	public static var app : Main;
	private var log:XrayLog;

	function Main() 
	{
		//init LogManager
		LogManager.initialize();
		
		run();
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
		
		// Create a local log object
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
}