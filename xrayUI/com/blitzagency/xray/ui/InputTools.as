package com.blitzagency.xray.ui
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.Application;;
	public class InputTools
	{
		public static var app:Object = mx.core.Application.application;
		private static var ec:ExecuteConnection;
		private static var lc:LoggerConnection;
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		public static function registerLC(p_lc:LoggerConnection):void
		{
			lc = p_lc;
		}
		
		public static function flushCommand(key:KeyboardEvent):void
		{
			/*
			NOTES:
				Need to find out if we have a command, property setting or a trace
				
				Trace: look for toString()
				command: look for operators or parens
			*/
			if(key.keyCode != Keyboard.ENTER) return;
			
			app.input.text = app.input.text.substr(0,app.input.text.length-1);
			
			var ary:Array = app.input.text.split(".");
			
			if(ary[ary.length-1].indexOf("(") > -1 || ary[ary.length-1].indexOf("=") > -1)
			{
				sendCommand();
			}else
			{
				sendTrace();
			}
		}
		
		private static function sendCommand():void
		{
			ec.executeScript(app.input.text);
		}
		
		private static function sendTrace():void
		{
			// switch back to output view for a trace
			app.propertiesViewStack.selectedIndex = 0;
			lc.getTraceValue(app.input.text);
		}
	}
}