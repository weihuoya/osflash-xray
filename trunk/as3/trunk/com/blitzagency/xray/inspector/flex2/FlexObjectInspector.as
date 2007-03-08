package com.blitzagency.xray.inspector.flex2
{
	import com.blitzagency.xray.inspector.util.ObjectInspector;
	import mx.core.Application;

	public class FlexObjectInspector extends ObjectInspector
	{
		public function FlexObjectInspector()
		{
			super();
		}
		
		public override function buildObjectFromString(target:String):Object
		{
			var obj:Object = mx.core.Application.application;
			
			var ary:Array = target.split(".");

			if(ary.length == 1) 
			{
				currentTargetPath = "application";
				return obj
			}
			
			for(var i:Number=1;i<ary.length;i++)
			{
                obj = obj.getChildByName(ary[i]);
            }

			return obj;
		}		
	}
}