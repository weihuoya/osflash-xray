package com.blitzagency.xray.inspector.util
{
	import com.blitzagency.xray.logger.XrayLog;
	import com.blitzagency.xray.logger.util.ObjectTools;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.describeType;
	import flash.xml.XMLDocument;
	import flash.utils.getQualifiedClassName;
	import flash.events.EventDispatcher;
	import flash.display.Stage;

	// we extend DisplayObject so that we can have access to the base stage property
	public class ObjectInspector extends EventDispatcher
	{		
		private var log:XrayLog = new XrayLog();
		private var returnList:String = "";
		protected var currentTargetPath:String = "";
		private var stage:Stage;
		
		public function setStage(p_stage:Stage):void
		{
			stage = p_stage;
		}
		
		public function ObjectInspector():void
		{
			//constructor;
		}
		
		public function buildObjectFromString(target:String):Object
		{
			var obj:Object = stage.getChildByName("root1");
			
			/*
			var isFlexApp:Boolean = getQualifiedClassName(obj).indexOf("SystemManager") > -1 ? true : false;
			log.debug("isFlexApp?", isFlexApp);
			
			if(isFlexApp) 
			{
				obj = stage["parentDocument"];
			}
			*/
			
			var ary:Array = target.split(".");

			if(ary.length == 1) 
			{
				//currentTargetPath = isFlexApp ? "application" : "root1";
				currentTargetPath = "Stage";
				return obj
			}
			
			for(var i:Number=1;i<ary.length;i++)
			{
                obj = obj[ary[i]];
            }

			return obj;
		}
		
		public function getProperties(target:String):Object
		{
			var obj:Object = buildObjectFromString(target);
			var returnObj:Object = {};
			returnObj.ClassExtended = ObjectTools.getFullClassPath(obj);
			returnObj.Class = ObjectTools.getImmediateClassPath(obj);
	
			var xml:XML = describeType(obj);
			//log.debug("describeType", xml.toXMLString());
			
			for each(var item:XML in xml.accessor)
			{
				try
				{
					if(item.@access.indexOf("read") > -1)
					{
						//if(item.@name == "cacheHeuristic") continue;
						//var className:String = getQualifiedClassName(obj[item.@name]).split("::")[1];
						var className:String = item.@type.split("::")[1];
						className = className == null ? item.@type : className;
						var value:* = obj[item.@name];
						returnObj[item.@name] = className + "::" + value;
					}
				}catch(e:Error)
				{
					log.error("getProperties error (" + item.@name  + ")", e.message);
				}
			}
			
			return returnObj;
		}
		
		/*
		There are 2 parts to inspection:
		
		1. look at the displayObjects
		2. look for arrays/objects in the describeType object
		*/
		
		public function inspectObject(target:String):String
		{
			// reset the list
			try
			{
				currentTargetPath = target;
				
				// get object reference
				var obj:Object = buildObjectFromString(target);
				
				// if there are no children, then no sense in continuing, return empty string
				if(obj.numChildren == 0 || !obj.hasOwnProperty("numChildren")) return "";
				
				// the currentTarget should be correct now.  Create root node
				var className:String = getQualifiedClassName(obj).split("::")[1] == undefined ? getQualifiedClassName(obj) : getQualifiedClassName(obj).split("::")[1]
				returnList = "<" + currentTargetPath + " label=\"" + currentTargetPath + " (" + className + ")\" mc=\"" + currentTargetPath + "\" t=\"2\" >";
				
				// check for displayObject
				if(obj is DisplayObject) buildDisplayList(obj);
				
				returnList += "</" + currentTargetPath + ">";
				
				log.debug("returnList", returnList);
			}catch(e:Error)
			{
				log.error("inspect object error: " + currentTargetPath, e.message);
			}finally
			{
				return returnList;
			}
			
		}
		
		private function buildDisplayList(obj:Object):void
		{
			for(var i:Number=0;i<obj.numChildren;i++)
			{
				var container:DisplayObject = obj.getChildAt(i);
				var name:String = container.name;
				var className:String = getQualifiedClassName(container).split("::")[1];
				var mc:String = currentTargetPath + "." + name;
				// add to the return string
				addToReturnList(name, className, mc);
			}
		}
		
		private function addToReturnList(name:String, className:String, mc:String):void
		{
			// <nodeName label=nodeName mc=mc t=2 />
			name = name.split(" ").join("_");
			returnList += "<" + name + " label=\"" + name + " (" + className + ")\" mc=\"" + mc + "\" t=\"2\" />";
		}
	}
}