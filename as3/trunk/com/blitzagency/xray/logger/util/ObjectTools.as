package com.blitzagency.xray.logger.util
{
	import flash.utils.*;
	import com.blitzagency.xray.logger.XrayLog;
	
	public class ObjectTools
	{
		private static var log:XrayLog = new XrayLog();
		
		private static var strings:Array = new Array
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
		
		public static function getFullClassPath(obj:Object):String
		{
			var xmlDoc:XML = describeType(obj);
			var ary:Array = [];
			
			
			// add the className of the actual object
			var className:String = getQualifiedClassName(obj);
			className = className.indexOf("::") > -1 ? className.split("::").join(".") : className;
			
			ary.push(className);
			
			// loop the extendsClass nodes
			for each(var item:XML in xmlDoc.extendsClass)
			{
				var extClass:String = item.@type.toString().indexOf("::") > -1 ? item.@type.toString().split("::")[1] : item.@type.toString();
				ary.push(extClass);
			}
			
			// return the full path as dot separated
			
			return ary.join(".");
		}
		
		public static function getImmediateClassPath(obj:Object):String
		{
			var className:String = getQualifiedClassName(obj);
			var superClassName:String = getQualifiedSuperclassName(obj);
			className = className.indexOf("::") > -1 ? className.split("::").join(".") : className;
			if(superClassName == null) return className; 
			
			superClassName = superClassName.indexOf("::") > -1 ? superClassName.split("::").join(".") : superClassName;
			return superClassName + "." + className;
		}
		
		public static function parseObject(p_obj:Object, p_nodeName:String="root"):String
		{
			var str:String = "<" + p_nodeName + ">";
			for(var items:String in p_obj)
			{
				if(typeof(p_obj[items]) == "object")
				{
					str += parseObject(p_obj[items], items);
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
		
		private static function encode(p_str:String):String
		{
			for(var i:Number=0;i<strings.length;i++)
			{
				p_str = p_str.split(strings[i].from).join(strings[i].replace);
			}
			
			return p_str;
		}
		
		public function resolveBaseType(obj:Object):String
		{
			return "";
		}
	}
}