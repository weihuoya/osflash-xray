package com.blitzagency.xray.inspector.flex2
{
	import com.blitzagency.xray.inspector.util.ObjectInspector;
	import mx.core.Application;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import com.blitzagency.xray.logger.XrayLog;

	public class FlexObjectInspector extends ObjectInspector
	{
		private var log												:XrayLog = new XrayLog();
		
		public function FlexObjectInspector()
		{
			super();
		}
		
		public override function buildObjectFromString(target:String):Object
		{
			var obj:Object = mx.core.Application.application as Object;
			
			var ary:Array = target.split(".");

			if(ary.length == 1) 
			{
				currentTargetPath = "application";
				return obj
			}
			
			for(var i:Number=1;i<ary.length;i++)
			{
				var temp:Object = obj.getChildByName(ary[i]) as Object;
                if(temp == obj) continue;
                obj = temp;
            }

			return obj;
		}		
	}
}