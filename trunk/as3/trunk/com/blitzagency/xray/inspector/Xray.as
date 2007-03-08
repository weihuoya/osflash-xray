package com.blitzagency.xray.inspector
{
	import com.blitzagency.xray.inspector.util.ControlConnection;
	import com.blitzagency.xray.inspector.util.ObjectInspector;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.getQualifiedClassName;
	import com.blitzagency.xray.logger.XrayLog;
	
	public class Xray extends Sprite
	{
		private var log:XrayLog = new XrayLog();
		private var controlConnection:ControlConnection;
		
		public function Xray()
		{
			var isLivePreview:Boolean = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
			// if parent is null, then we're in livePreview
			if(isLivePreview) return;
			
			visible = false;
			
			// doing this so that ObjectInspector will have it's own stage property to work with
			ObjectInspector.getInstance().setStage(stage);
			
			controlConnection = new ControlConnection();
			controlConnection.initConnection();
			
			controlConnection.send("_xray_conn", "checkFPSOn");
		}
	}
}