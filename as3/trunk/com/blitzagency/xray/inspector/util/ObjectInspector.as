﻿package com.blitzagency.xray.inspector.util
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
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;

	// we extend DisplayObject so that we can have access to the base stage property
	public class ObjectInspector extends EventDispatcher
	{			
		private var log																	:XrayLog = new XrayLog();
		private var returnList															:String = "";
		protected var currentTargetPath													:String = "";
		private var _stage																:DisplayObjectContainer;
		
		public function set stage(p_stage:DisplayObjectContainer):void
		{
			_stage = p_stage;
		}
		
		public function get stage():DisplayObjectContainer
		{
			return _stage;
		}
		
		private var strings:Array = new Array
		(
			{
				replace:"&lt;", from:"<"
			},
			{
				replace:"&gt;", from:">"
			},
			{
				replace:"&apos;", from:"'"
			},
			{
				replace:"&quot;", from:"\""
			},
			{
				replace:"&amp;", from:"&"
			}
		)
		
		public function ObjectInspector():void
		{
			//constructor;
		}
		
		public function buildObjectFromString(target:String):Object
		{
			var obj:Object;
			
			try
			{
				obj = stage.root;
				//obj = stage.getChildByName("root1") as DisplayObjectContainer;
			}catch(e:Error)
			{
				log.debug("stage is not initialized");
			}
			
			var ary:Array = target.split(".");

			if(ary.length == 1) 
			{
				currentTargetPath = "stage";
				return obj
			}
			
			for(var i:Number=1;i<ary.length;i++)
			{
				var temp:Object = obj.getChildByName(ary[i]) as Object
                if(temp == obj) continue;
                obj = temp;
            }

			return obj;
		}
		
		public function getProperties(target:String):Object
		{
			var obj:* = buildObjectFromString(target);
			var returnObj:Object = {};
			
			
			returnObj.ClassExtended = ObjectTools.getFullClassPath(obj);
			returnObj.Class = ObjectTools.getImmediateClassPath(obj);
			
			var xml:XML = describeType(obj);
			
			log.debug("describeType", (xml.toXMLString()));
			//log.debug("type?", target + ", " + returnObj.Class);
			//return {};
			for each(var item:XML in xml.accessor)
			{
				try
				{
					//log.debug("item.@access", item.@access);
					//continue;
					if(item.@access.indexOf("read") > -1)
					{
						var className:String = item.@type.split("::")[1];
						className = className == null ? item.@type : className;
						var value:* = obj[item.@name];
						returnObj[item.@name] = className + "::" + value;
					}
					
				}catch(e:Error)
				{
					log.error("getProperties error (" + item.@name  + ")", e.message);
					continue;
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
			returnList = "";
			try
			{
				currentTargetPath = target;
				
				// get object reference
				var obj:DisplayObjectContainer = DisplayObjectContainer(buildObjectFromString(target));
				
				if(obj.hasOwnProperty("numChildren"))
				{
					if(obj.numChildren == 0) return "";
				}
				
				// the currentTarget should be correct now.  Create root node
				var className:String = getQualifiedClassName(obj).split("::")[1] == undefined ? getQualifiedClassName(obj) : getQualifiedClassName(obj).split("::")[1]
				returnList = "<" + currentTargetPath + " label=\"" + currentTargetPath + " (" + className + ")\" mc=\"" + currentTargetPath + "\" t=\"2\" >";
				
				// check for displayObject
				if(obj is DisplayObject) 
				{
					buildDisplayList(obj);
				}else if(obj is Object)
				{
					//buildObjectList(obj);
				}
				
				returnList += "</" + currentTargetPath + ">";				
			}catch(e:Error)
			{
				log.error("inspect object error: " + currentTargetPath, e.message);
			}
			
			return returnList;		
		}
		
		private function buildDisplayList(obj:DisplayObjectContainer):void
		{
			try
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
			}catch(e:Error)
			{
				log.debug("buildDisplayList error", e.message);
			}
		}
		
		/**
		 * @notes I'd meant to show "Objects" in the treeview as well
		 * @param obj
		 * 
		 */		
		private function buildObjectList(obj:Object):void
		{
			log.debug("buildObjectList called");
			//for(var i:Number=0;i<obj.numChildren;i++)
			for(var items:String in obj)
			{
				log.debug("items", items);
				var container:Object = obj[items];
				var name:String = items;
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
		
		public function parseObjectToString(p_obj:Object, p_nodeName:String="root"):String
		{
			var str:String = "<" + p_nodeName + ">";
			for(var items:String in p_obj)
			{
				if(typeof(p_obj[items]) == "object")
				{
					str += parseObjectToString(p_obj[items], items);
				}else
				{
					var nodeValue:* = p_obj[items];
					if(typeof(nodeValue) != "boolean" && typeof(nodeValue) != "number") nodeValue = encode(p_obj[items]);
					str += "<" + items + ">" + nodeValue + "</" + items + ">";
				}
			}
			str += "</" + p_nodeName + ">";
			return str;
		}
		
		private function encode(p_str:String):String
		{
			for(var i:Number=0;i<strings.length;i++)
			{
				p_str = p_str.split(strings[i].from).join(strings[i].replace);
			}
			
			return p_str;
		}
	}
}