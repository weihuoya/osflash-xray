/*
Copyright (c) 2005 John Grden | BLITZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import com.blitzagency.util.Delegate;
import com.blitzagency.xray.XrayTrace;
import com.blitzagency.util.PointConverter;
import com.blitzagency.xray.FPSMeter;
import com.blitzagency.xray.FunctionName;
import com.blitzagency.xray.ControlConnection;
import com.blitzagency.xray.LoggerConnection;
import com.blitzagency.xray.ClassPath;
import com.blitzagency.xray.logger.LogManager;

/*Bit101Logger*/	
import com.blitzagency.xray.logger.Debug;
import com.blitzagency.xray.logger.XrayLogger;

//import org.as2lib.env.log.LogManager;
//import org.as2lib.env.log.logger.XrayLogger;
//import org.as2lib.env.log.MtascUtility;

/**
 * Entry point for the Xray Connector Component.  Establishes static properties for use in the host application.
 *
 * @author John Grden :: John@blitzagency.com
 */

class com.blitzagency.xray.Xray
{
	public static var xrayLogger:Object;
	/**
	 * lc_exec handles executions and treeviews.
	 */
	public static var lc_exec:ControlConnection;

	/**
	 * lc_info handles all of the logging traffic.
	 */
	public static var lc_info:LoggerConnection;
	/**
	 * xrayTrace is a singleton, and this is a static reference to it from Xray.
	 * The Xray class controls and deals with all of the incoming and outgoing LocalConnections.
	 */
	public static var xrayTrace:XrayTrace;
	/**
	 * PointConverter is a static class, and this is a static reference to it from Xray.
 	 *
	 * @PointConverter.localToLocal: Method - combines the use of globalToLocal/localToGlobal to convert
	 * coordinates of movieclips.
	 */
	public static var pointConverter:PointConverter;
	/**
	 * fpsMeter is a singleton, and this is a static reference to it from Xray.
	 * This dispatches an onFpsUpdate event and passes an object a single property:  obj.fps
	 */
	public static var fpsMeter:FPSMeter;
	/**
     * Instance of the functionName class.  FunctionName returns a method's name if it can be located.
	 */
	public static var functionName:FunctionName;
	/**
	 * Inspectable property for the component inspector in the Flash IDE.
	 *
	 * Setting showFPS to 'true' will cause the component to create a sub movieclip container with textfield
	 * and will add a listener to the fpsMeter object for an easy view of Frames Per Second without the Xray Interface.
	 *
	 * Note:  for this feature to work, the xray needs to be present on stage at runtime.
	 */
	[Inspectable(name="Show FPS Meter?", Boolean, defaultValue=false)]
	public var showFPS:Boolean;
	/**
	 * Inspectable property for the component inspector in the Flash IDE.
	 *
	 * This lets the user change the color of the FPS text box so they can see it in any bg situation
	 *
	 * Note:  for this feature to work, the xray needs to be present on stage at runtime.
	 */
	[Inspectable(name="Show FPS Meter Color?", Color, defaultValue=0xFF0000)]
	public var fpsColor:Color;
	/**
	 * Inspectable property for the component inspector in the Flash IDE.
	 *
	 * This lets the user add class packages if they're not under the normal mx or com locations.
	 *
	 * Note:  for this feature to work, the xray needs to be present on stage at runtime.
	 */
	[Inspectable(name="Class Packages", Array, defaultValue=("com,org,net,edu,gov,ch,mx,flash"))]
	public var classPackages:Array;
	
	public static var basePackages:Array;
	public static var packagesInitialized:Boolean;
	public static var addedObjects:Object;
	public static var $version:String = "1.6.2";
	/**
	 * RecursionControl is a static control number letting the loop know that a particular object's been looped.
	 * the idea is that we'll switch it back and forth.  I was deleting the check (using boolean flag) after the obj had been looped, but
	 * that does't account for cross object refrences, it only helps in situations where a child references a parent property/object.
	 */
	public static var recursionControl:Number;

	/**
	 * @summary Init is called by the onLoad event defined in the component on stage/in the library.  We let the onLoad call init()
	 * to avoid the local connections in com.blitzagency.xray.AdminTool from being connected at design time
	 * when put on stage.  Simply using _global.isLivePreview did not keep this from firing (as of Flash 7 anyway)
	 */
	
	public static function init():Void
	{
		// setup base packages
		basePackages = new Array("com,org,net,edu,gov,ch,mx,flash");
		
		addedObjects = new Object();
		
		// setup recursionControl counter
		recursionControl = 0;
		
		/* out with the old */
		xrayTrace = XrayTrace.getInstance();
		
		/* in with the new*/
		LogManager.initialize();
		xrayLogger = LogManager.getLogger("com.blitzagency.xray.logger.XrayLogger");		

		// global shortcuts
		_global.view = function() { xrayTrace.trace.apply(xrayTrace, arguments); }
		_global.tt = function()	{ xrayTrace.trace.apply(xrayTrace, arguments); }

		// for ease of use
		_global.Xray = Xray;
		_global.Xray.setLogLevel = function(p_level:Number) {xrayLogger.setLevel(p_level); }
		_global.Xray.debug = function()	{ xrayLogger.debug(arguments[0], arguments[1]); }
		_global.Xray.info = function()	{ xrayLogger.info(arguments[0], arguments[1]); }
		_global.Xray.warn = function()	{ xrayLogger.warn(arguments[0], arguments[1]); }
		_global.Xray.error = function()	{ xrayLogger.error(arguments[0], arguments[1]); }
		_global.Xray.fatal = function()	{ xrayLogger.fatal(arguments[0], arguments[1])	; }

		// PointConverter / localToLocal
		pointConverter = PointConverter.getInstance();

		// FPS Meter
		fpsMeter = FPSMeter.getInstance();
		fpsMeter.addEventListener("onFpsUpdate", Delegate.create(Xray, Xray.updateFps));

		// Returns function name
		functionName = FunctionName.getInstance();

		// global shortcut for functionName
		_global.tf = function() {functionName.traceFunction.apply(functionName, arguments); }


		if(!_global.isLivePreview)
		{
			//NOTES:
			//	If the xray is already loaded in another SWF, abort
			if(lc_info) return;

			// setup local connection to communicate with adminTools
			lc_exec = new ControlConnection();
			lc_info = new LoggerConnection();
			
			// bring along the MtascUtility class
			//var temp = MtascUtility.initialized;
			// i modified Debug to call the connector directly.  this is to support mtasc users
			//Debug.addEventListener("onTrace", Delegate.create(lc_info, lc_info.setTrace));
		}
	}
	
	public static function addObject(id:String, obj):Void
	{
		addedObjects[id] = new Object({id:id, obj:obj});
		
		// pulled for 1.4.5 release - will have to work out other details with ObjectViewer and paths.
		//lc_exec.sendAddedObjects(id);
	}
	
	/**
	 * @summary adds class pacakges to the ClassPath
	 *
	 * @param ary:Array - array of strings representing packages to include.
	 *
	 * @return nothing
	 */
	public static function addPackages(ary:Array):Void
	{
		// init classpaths added via the PI:
		for(var i:Number=0;i<ary.length;i++)
		{
			if(ary[i] != "") ClassPath.registerPackage(ary[i]);
		}
		// add intrinsic classes
		ClassPath.registerPackage();
		packagesInitialized = true;
	}
	/**
	 * Traces the supplied objects in the .
	 * You can send anything you want to the trace method (objects, arrays, properties etc)
	 * More info can be found here:
	 * <a href="http://labs.blitzagency.com/?p=39">http://labs.blitzagency.com/?p=39</a>
	 * <a href="http://labs.blitzagency.com/?p=38">http://labs.blitzagency.com/?p=38 - Method docs</a>
	 */
	public static function trace()
	{
		//xrayTrace.trace.apply(xrayTrace, arguments);
		xrayLogger.debug.apply(xrayLogger, arguments);
	}

	/**
	 * Traces the supplied objects in the Xray client.
	 * You can send anything you want to the trace method (objects, arrays, properties etc)
	 *
	 * tt() was created as a shortcut rather than typing out "trace".  It calls the exact same method that trace does.
	 * More info can be found here:
	 * <a href="http://labs.blitzagency.com/?p=39">http://labs.blitzagency.com/?p=39</a>
	 * <a href="http://labs.blitzagency.com/?p=38">http://labs.blitzagency.com/?p=38 - Method docs</a>
	 */
	public static function tt():Void
	{
		xrayTrace.trace.apply(xrayTrace, arguments);
	}

	/**
	 * tf() is used within function calls.
	 * It will output the name of the called function,
	 * the timeline in which it exists and the arguments sent.
	 *
	 * NOTE: as of 1.2.7 this is still a relatively new and untested method in the .  Try sending different object references
	 * if "this" doesn't yeild any results.  Basically, it needs an object/timeline to loop to match up arguments.callee with.
	 *
	 * More info on this method can be found here:
	 * <a href="hhttp://labs.blitzagency.com/?p=51">http://labs.blitzagency.com/?p=51</a>
	 *
	 * @param	arguments	Arguments Array		The arguments array of the function/method being called.
	 * @param	object		Object				The reference to the object that the function is apart of (movieclip/class etc).
	 *
	 * @example <pre>
	 function foo(parm1, parm2, parm3)
	 {
	 	Connector.tf(arguments, this);
	 }
	 </pre>
	 *
	 */
	public static function tf()
	{

		_global.FunctionName.traceFunction.apply(_global.FunctionName, arguments);
	}
	/**
	 * @summary Deals with recieving events from the FPSMeter object and sending to the interface via lc_exec.sendFPS()
	 */
	public static function updateFps(obj:Object):Void
	{
		lc_exec.sendFPS(obj);
	}
	/**
	 * @summary This method does just what it says: creates a FPS meter on stage inside of the movieclip provided.
	 * If a target_mc is not passed, _level0 is used.
	 *
	 * @param target_mc:Movieclip Where the movieclip is to be created
	 *
	 * @return movieclip reference to the FPS Meter
	 */
	public static function createFPSMeter(target_mc:MovieClip, fpsColor:Color):MovieClip
	{
		target_mc = !target_mc ? _level0 : target_mc;

		var mc:MovieClip = target_mc.createEmptyMovieClip("fpsContainer", target_mc.getNextHighestDepth());
		mc.cacheAsBitmap = true;
		var tf:TextField = mc.createTextField("fps", 1, 0, 0, 40, 22);
		tf.autoSize = true;
		mc.embedFonts = false;
		mc.textFormat =  new TextFormat();
		mc.textFormat.color = fpsColor;
		
		mc.textFormat.font = "_sans";
		mc.textFormat.size = 10;
		mc.fps.setNewTextFormat(mc.textFormat);
		mc.fps.setTextFormat(mc.textFormat);
		mc.updateFps = function(obj:Object)
		{
			this.fps.text = obj.fps;
		}

		fpsMeter.runFPS = true;
		fpsMeter.addEventListener("onFpsUpdate", Delegate.create(mc, mc.updateFps));

		return mc;
	}
	
	public static function sendMetaData(obj:Object):Void
	{
		if(obj != undefined)
		{
			 var sent:Boolean = lc_exec.send("_xray_conn", "setMetaData", obj);
		}
	}

	/**
	 * @summary initConnections is called via component in the library when onLoad fires.  If the connection names are not
	 * being used by another Flash app, both boolean check variables will return true;
	 *
	 * @return nothing
	 */
	public static function initConnections():Void
	{
		var isConnected_exec:Boolean = lc_exec.initConnection();
		var isConnected_info:Boolean = lc_info.initConnection();

		if(isConnected_exec) 
		{
			lc_exec.send("_xray_conn", "checkFPSOn");
			lc_exec.getLogLevel();
		}

		tt("Connections", (isConnected_exec + " | " + isConnected_info))
	}
}