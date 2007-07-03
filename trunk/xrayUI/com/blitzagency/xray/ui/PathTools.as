package com.blitzagency.xray.ui
{	
	public class PathTools
	{
		/*
		serializePath takes a path being sent to the connector and creates key values as strings.
		We do this incase a key name might have special characters.		
		*/
		public static function serializePath(path:String):String
		{
			var ary:Array = path.split(".");
			var str:String = ary.shift() + "['";
			str += ary.join("']['");
			str += "']";
			
			return str;
		}
		
		public static function deSerializePath(path:String):String
		{
			// _level0['a']['b'];
			var ary:Array = path.split("']['");
			var ary_0:Array = ary.shift().split("['");
			var ary_1:Array = ary.pop().split("']");
			var str:String = ary_0[0] + "." + ary_0[1] + "." + ary.join(".") + "." + ary_1[0];
		
			return str;
		}
	}
}