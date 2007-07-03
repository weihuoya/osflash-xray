package com.blitzagency.xray.ui
{
	import flash.events.Event;
	
	import mx.core.Application;
	
	public class FilterTools
	{
		public static var app:Object = mx.core.Application.application;
		public static var currentFilterState:String = "DropShadowFilter";
		private static var ec:ExecuteConnection;
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		public static function updateState(event:Event):void
		{
			//OutputTools.tt(["updateState called", event, app.filterChoice.value]);
			var stateName:String = app.filterChoice.value + "Filter";
			initNewState(stateName);
			// based on the name of the canvas showing, we'll show the correct state
		}
		
		public static function initNewState(stateName:String):void
		{
			app.currentState = stateName;
			currentFilterState = stateName;
		}
		
		public static function updateFilter():void
		{
			var filter:Object;
			var filterType:String = "";
			var obj:Object = new Object();
			
			switch(currentFilterState)
			{
				case "DropShadowFilter":
					filterType = "ds";
					obj.distance = Number(app.distance.value); 
					obj.angle = Number(app.angle.value); 
					obj.color = Number(app.clr.value); 
					obj.alpha = Number(app.alphaValue.value);
					obj.blurX = Number(app.blurX.value);
					obj.blurY = Number(app.blurY.value); 
					obj.strength = Number(app.strength.value);
					obj.quality = Number(app.quality.value);
					obj.inner = app.innerShadow.selected; 
					obj.knockout = app.knockout.selected; 
					obj.hideObject = app.hideObject.selected;
					filter = obj;
				break;
				
				case "BlurFilter":
					filterType = "blur";
					obj.blurX = Number(app.blurX.value)
					obj.blurY = Number(app.blurY.value)
					obj.quality = Number(app.quality.value)
					filter = obj;
				break;
				
				case "GlowFilter":
					filterType = "glow";
					obj.color = Number(app.clr.value); 
					obj.alpha = Number(app.alphaValue.value);
					obj.blurX = Number(app.blurX.value);
					obj.blurY = Number(app.blurY.value); 
					obj.strength = Number(app.strength.value);
					obj.quality = Number(app.quality.value);
					obj.inner = app.innerShadow.selected; 
					obj.knockout = app.knockout.selected;
					filter = obj;
				break;
			}
			
			if(TreeTools.currentSelectedType == 2) ec.setFilter(TreeTools.currentSelectedObject, filter, filterType);
		}
		
		public static function showCode():void
		{
			var command:String = "";
			switch(currentFilterState)
			{
				case "DropShadowFilter":
					command = "\nimport flash.filters.DropShadowFilter;\n";
					command += "var ds:DropShadowFilter = new DropShadowFilter(";
					command += Number(app.distance.value) + ", "; 
					command += Number(app.angle.value) + ", ";
					command += Number(app.clr.value) + ", ";
					command += Number(app.alphaValue.value) + ", ";
					command += Number(app.blurX.value) + ", ";
					command += Number(app.blurY.value) + ", ";
					command += Number(app.strength.value) + ", ";
					command += Number(app.quality.value) + ", ";
					command += app.innerShadow.selected + ", ";
					command += app.knockout.selected + ", ";
					command += app.hideObject.selected + ");\n";
				break;
				
				case "BlurFilter":
					command = "\nimport flash.filters.BlurFilter;\n";
					command += "var blur:BlurFilter = new BlurFilter(";
					command += Number(app.blurX.value) + ", ";
					command += Number(app.blurY.value) + ", ";
					command += Number(app.quality.value) + ");\n";
				break;
				
				case "GlowFilter":
					command = "\nimport flash.filters.GlowFilter;\n";
					command += "var glow:GlowFilter = new GlowFilter(";
					command += Number(app.clr.value) + ", ";
					command += Number(app.alphaValue.value) + ", ";
					command += Number(app.blurX.value) + ", ";
					command += Number(app.blurY.value) + ", ";
					command += Number(app.strength.value) + ", ";
					command += Number(app.quality.value) + ", ";
					command += app.innerShadow.selected + ", ";
					command += app.knockout.selected + ");\n";
				break;
			}
			app.propertiesViewStack.selectedIndex = 0;
			OutputTools.tt([command]);
		}
	}
}