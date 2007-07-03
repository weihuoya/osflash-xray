package com.blitzagency.xray.events
{
	import flash.events.Event;

	public class TreeToolsEvent extends Event
	{
		public static var TREEVIEW_CLICK:String = "treeviewClick";
		public var path:String;
		public var objectType:Number;
		
		public function TreeToolsEvent(eventType:String, path:String, objectType:Number)
		{
			//TODO: implement function
			super(eventType);
			this.path = path;
			this.objectType = objectType;
		}
	}
}