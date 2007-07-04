package com.blitzagency.xray.inspector.flex2
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.blitzagency.xray.inspector.util.ControlConnection;
	import com.blitzagency.xray.inspector.commander.Commander;
	import com.blitzagency.xray.inspector.flex2.FlexObjectInspector;
	import com.blitzagency.xray.logger.XrayLog;

	public class Xray extends EventDispatcher
	{
		private static var _instance:Xray = null;
		private static var log:XrayLog = new XrayLog();
		
		private var controlConnection:ControlConnection;
		
		public static function getInstance():Xray
		{
			if(_instance == null) _instance = new Xray();
			return _instance;
		}
		
		public function Xray(target:IEventDispatcher=null)
		{
			super(target);
			
			log.debug("Flex xray constructor called");
			
			controlConnection = new ControlConnection();
			controlConnection.setObjectInspector(new FlexObjectInspector());
			controlConnection.initConnection();
			
			Commander.getInstance().objectInspector = new FlexObjectInspector();
			
			controlConnection.send("_xray_conn", "checkFPSOn");
		}		
	}
}