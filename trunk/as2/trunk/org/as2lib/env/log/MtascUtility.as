//import asunit.runner.BaseTestRunner;
import com.bit101.Debug;
import com.blitzagency.xray.Xray;
/**
 * @author Chris Allen mrchrisallen@gmail.com
 * @author John Grden neoriley@gmail.com
 */
class org.as2lib.env.log.MtascUtility 
{
	public static var initialized:Boolean = initialize();
	
	public static function initialize():Boolean
	{
		// i added this method to force it's compiling with the xray connector
		return true;
	}
	
	public static function trace(msg:Object, fullClassName:String, fileName:String, lineNumber:Number):Void
	{
		/*
		* NOTES:
		* 
		* 	A trace statement should now look like:
		* 
		*        trace({message:"What's obj got?", dump:obj, level:"debug"});
		* 
		* 	then, when received here, take msg properties and deal with it.
		* 
		*   resulting output is like this:
		* 
		* 	com.blitzagency.Main::run : line 32
			What's obj got?
			John: [Object]
				phone: ring
		*/
		
		//var message:String = fullClassName + " - " + lineNumber + ":\n\n" + msg + "\n\n";
		var message:String =  fullClassName + " : line " + lineNumber + "\n" + msg.message;
		var level:String = msg.level == undefined ? "debug" : msg.level;
		Xray.xrayLogger[level](message, msg.dump);

		//for ASUnit
		//BaseTestRunner.trace(message + "\n" + msg );
	}
}
