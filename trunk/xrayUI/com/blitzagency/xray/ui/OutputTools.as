package com.blitzagency.xray.ui
{
	import com.blitzagency.util.LSOUserPreferences;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.*;
	
	import mx.core.Application;
	import com.roguedevelopment.logviewer.LogViewer;
	;
	
	public class OutputTools
	{
		public static var app:Object = mx.core.Application.application;
		public static var acceptOutput:Boolean = true;
		private static var xt:XrayTrace = new XrayTrace();
//		private static var history:Array = new Array();
		private static var lastSearch:String;
		private static var lastSearchIndex:Number;
		private static var scrolling:Boolean = false;
		private static var searchList:Array = [];
		public static var initialized:Boolean = initialize();
		
		public static function initialize():Boolean
		{
			return true;
		}
					
		public static function tt(p_messageList:Array, level:int=0):void
		{
			//app.output.text += "message received :: " + acceptOutput + "\n";
			if(!acceptOutput) return;
			if( p_messageList.length == 0 ){return;}
			if( (p_messageList.length == 1) && (p_messageList[0] == "undefined") ){ return; }
			
			var ary:Array = [];
			//ary.push("(" + getTimer() + ") ");
			var logger:LogViewer = app.output ;
			
			for(var i:Number=0;i<p_messageList.length;i++)
			{
				var value:String = xt.trace(p_messageList[i]);
				if( value.substr(0,1) == "\n" )
				{
					value = value.substr(1);
				}
				ary.push(value);
			}
			
			//history.push(ary.join(""));
			//app.output.data = history.join("\n");
			logger.append(ary.join(""),level);			
		}
		
		
		public static function clear():void
		{
			
			app.output.clear();
		}
		
		public static function setAcceptOutput():void
		{
			if(!app.acceptOutput.selected) tt(["*** You've turned off output!  You're trace statements will not appear. ***"]);
			acceptOutput = app.acceptOutput.selected;			
			LSOUserPreferences.setPreference("acceptOutput", app.acceptOutput.selected, true);
		}
		
	}
}