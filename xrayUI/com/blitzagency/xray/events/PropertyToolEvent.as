package com.blitzagency.xray.events
{
	import flash.events.Event;

	public class PropertyToolEvent extends Event
	{
		public static var AXIS_EDIT:String = "axisEdit";
		public var path:String;
		public var prop:String;
		public var value:*;
		public function PropertyToolEvent(eventType:String, path:String, prop:String, value:*)
		{
			//TODO: implement function
			super(eventType);
			this.path = path;
			this.prop = prop;
			this.value = value;
		}
		
	}
}