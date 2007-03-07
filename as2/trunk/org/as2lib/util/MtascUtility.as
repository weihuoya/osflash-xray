//import asunit.runner.BaseTestRunner;
/**
 * @author Chris Allen mrchrisallen@gmail.com
 */
class org.as2lib.util.MtascUtility {
	
	public static function trace(msg:Object, fullClassName:String, fileName:String, lineNumber:Number):Void {
		
		//var message:String = fullClassName + " - " + lineNumber + ":\n\n" + msg + "\n\n";
		var message:String = fullClassName + " - " + lineNumber;
		
		//for use with Xray
		_global.tt(message + "\n", msg, "\n");
		
		//for ASUnit
		//BaseTestRunner.trace(message + "\n" + msg );
	}
}
