package com.blitzagency.xray.inspector.flex2
{
	import com.blitzagency.xray.inspector.util.ObjectInspector;
	import com.blitzagency.xray.logger.XrayLog;
	import com.blitzagency.xray.logger.util.ObjectTools;
	
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	import mx.core.IChildList;

	public class FlexObjectInspector extends ObjectInspector
	{
		private var log												:XrayLog = new XrayLog();
		
		public function FlexObjectInspector()
		{
			super();
		}
		
		public override function buildObjectFromString(target:String):Object
		{
			var obj:Object = mx.core.Application.application as Application;
			
			var ary:Array = target.split(".");

			if(ary.length == 1) 
			{
				currentTargetPath = "application";
				return obj
			}
			
			return parseObjectString(ary, obj);
		}	
		
		public override function parseObjectsForReturn(obj:Object, returnObj:Object):Object
		{
			returnObj = super.parseObjectsForReturn(obj, returnObj);
			
			if( obj is IChildList )
			{
				//log.debug("IS RawChild");
				returnObj = processRawChildren(obj, returnObj);
			}
			
			return returnObj;
		}
		
		public function processRawChildren( obj:Object, returnObj:Object ):Object
		{
			var className:String = "";
			var value:Object;
			
			for(var i:Number=0;i<obj.numChildren;i++)
			{
				className = ObjectTools.getImmediateClassPath(obj.getChildAt(i));
				className = className == null ? String(i) : className;
				value = obj.getChildAt(i);
				returnObj[i] = className + "::" + value;
			}
				
			return returnObj;
		}
	}
}