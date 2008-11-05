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
			
			trace("Build object from string", ary, obj);
			return parseObjectString(ary, obj);
		}	
		
		/* protected override function parseObjectString(ary:Array, obj:Object):Object
		{
			var temp:* = null;
			for(var i:Number=1;i<ary.length;i++)
			{
				temp = null;
				trace("OBJECT TYPE", ObjectTools.getImmediateClassPath(obj));
				if( obj.hasOwnProperty("getChildByName" && isNaN(ary[i]) ) ) 
				{
					temp = obj.getChildByName(ary[i]);
				}
				else if( obj.hasOwnProperty("getChildAt" && !isNaN(ary[i]) ) ) 
				{
					temp = obj.getChildAt(ary[i]);
				}
				else if( obj is Array )
				{
					trace("FOUND ARRAY", ary[i]);
					temp = obj[Number(ary[i])];
				}
				else if( obj is Dictionary )
				{
					trace("Dictionary Found");
					if( !isNaN(ary[i]) )
					{
						//trace("is Number", ary[i]);
						var counter:Number = 0;
						for each( var dObj:* in obj )
						{
							if( counter == Number(ary[i]) ) temp = dObj;
							counter++;
						}
					}
				}
				//else if ( obj is IChildList || ObjectTools.getImmediateClassPath(obj) == "Object.mx.core.ContainerRawChildrenList" ) // rawChildren
				//{
				//	trace("is rawchild");
				//	if( !isNaN(ary[i]) )
				//	{
				//		temp = obj.getChildAt(Number(ary[i]));
				//	}
				//}
				
				if( temp == null && obj.hasOwnProperty([String(ary[i])]) ) temp = obj[ary[i]];
				//trace("TEMP obj null?", temp == null);
                if( temp == obj) continue;
                if( temp == null ) break;
				//trace("Building path", ary[i], temp is Dictionary)
                obj = temp;
            }

			return obj;
		} */
		
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