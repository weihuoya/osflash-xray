package com.blitzagency.xray.ui
{
	import com.blitzagency.xray.events.PropertyToolEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.*;
	
	import mx.controls.Alert;
	import mx.controls.ToolTip;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	import mx.events.SliderEvent;
	import mx.managers.ToolTipManager;
	import mx.validators.ValidationResult;
	
	[Event("axisEdit")]
	
	public class PropertyTools extends EventDispatcher
	{
		public static var app:Object = mx.core.Application.application;
		public static var initialized:Boolean = initialize();
		public static var propertyEditList:Object;
		public static var currentEditorObject:Object;
		public static var currentInspectorObject:Object;
		public static var instance:PropertyTools;
		//public static var addEventListener:Function;
		//public static var removeEventListener:Function;
		//private static var dispatchEvent:Function;
		private static var lastDataGridRow:Number = -1;
		private static var ec:ExecuteConnection;
		private static var history:Array = new Array();
		private static var tempFLVReference:String = "";
		
		
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		public function PropertyTools():void
		{
			// constructor
		}
		
		private static function initialize():Boolean
		{
			var pel:Object = propertyEditList = new Object();
			pel["_name"] = {stateName: "stringNumericEdit"};
			pel["_x"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 5000};
			pel["_y"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 5000};
			pel["_width"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 5000};
			pel["_height"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 5000};
			pel["_rotation"] = {stateName: "stringNumericEditSlider", minValue:0, maxValue: 360};
			pel["_visible"] = {stateName: "booleanEditor"};
			pel["_alpha"] = {stateName: "stringNumericEditSlider", minValue:0, maxValue: 100};
			pel["_xscale"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 1000};
			pel["_yscale"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 1000};
			pel["depth"] = {stateName: "stringNumericEdit", propSetter: "swapDepths"};
			pel["_currentframe"] = {stateName: "timelineController", propSetter: "gotoAndStop", minValue:1, maxValue: 1000};
			pel["_totalframes"] = {stateName: ""};
			pel["_framesloaded"] = {stateName: ""};
			pel["enabled"] = {stateName: "booleanEditor"};
			pel["hitArea"] = {stateName: ""};
			pel["_droptarget"] = {stateName: ""};
			pel["_target"] = {stateName: ""};
			pel["_focusEnabled"] = {stateName: "booleanEditor"};
			pel["_focusrect"] = {stateName: ""};
			pel["_lockroot"] = {stateName: "booleanEditor"};
			pel["menu"] = {stateName: ""};
			pel["_quality"] = {stateName: "stringNumericEdit"};
			pel["soundbuftime"] = {stateName: "stringNumericEdit"};
			pel["tabChildren"] = {stateName: "booleanEditor"};
			pel["tabEnabled"] = {stateName: "booleanEditor"};
			pel["tabIndex"] = {stateName: "stringNumericEdit"};
			pel["trackAsMenu"] = {stateName: "booleanEditor"};
			pel["_url"] = {stateName: ""};
			pel["useHandCursor"] = {stateName: "booleanEditor"};
			// TextField specific props
			pel["text"] = {stateName: "stringNumericEdit"};
			pel["htmlText"] = {stateName: "stringNumericEdit"};
			pel["html"] = {stateName: "booleanEditor"};
			pel["textWidth"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 1000};
			pel["textHeight"] = {stateName: "stringNumericEditSlider", minValue:-1000, maxValue: 1000};
			
			instance = new PropertyTools();
			
			return true;
		}
		
		public static function getEditorProperties(property:String):Object
		{
			return propertyEditList[property];
		}
		
		public static function rollOverHandler(event:ListEvent):void
		{
			if(event.rowIndex == lastDataGridRow) return
			/*
			var obj:Object = getData(event);

			if(obj.prop == "_x" || obj.prop == "_y") 
			{
				ec.showGridLine(obj.path, obj.prop, obj.value);
			}else
			{
				ec.hideGridLine(obj.path);
			}
			OutputTools.tt(["rollOver", obj])
			*/
		}
		
		public static function rollOutHandler(event:ListEvent):void
		{
			//OutputTools.tt(["RollOut"]);
		}
		
		public static function updateStringProperty(event:Event):void
		{
			//OutputTools.tt(["updateStringProperty", event])	
			var obj:Object = app.propertyInspector.selectedItem;
			var value:String = "";
			
			var doUpdate:Boolean = true;
			switch(app.currentState)
			{
				case "stringNumericEdit":
					value = app.editValueStringNumeric.text;
				break;
				
				case "stringNumericEditSlider":
					value = app.editValueStringNumericSliderText.text;
					app.editValueStringNumericSliderSlider.value = Number(value);
				break;
				
				case "timelineController":
					// in the case of the timeline controller, we want to give them time to type in a full frame label if necessary
					if(event.type == "change") doUpdate = false;
					value = app.editValueStringNumericSliderText.text;
					app.editValueStringNumericSliderSlider.value = Number(value);
				break;
			}
			
			// set new value
			obj.value = value;
			// cause for update in cell
			app.propertyInspector.invalidateList();
			// set the property across the pond
			if(doUpdate) ec.setProperty(obj.path, obj.property, value, obj.type);
		}
		
		public static function updateSliderValue(event:SliderEvent):void
		{
			var obj:Object = app.propertyInspector.selectedItem;
			var value:Number;
			switch(app.currentState)
			{
				case "stringNumericEditSlider":
					value = app.editValueStringNumericSliderSlider.value;
					app.editValueStringNumericSliderText.text = value;
				break;
				
				case "timelineController":
					app.gotoAndStop.selected = true;
					value = Math.floor(app.editValueStringNumericSliderSlider.value);
					app.editValueStringNumericSliderText.text = value;
				break;
			}
			
			// set new value
			obj.value = value;
			// cause for update in cell
			app.propertyInspector.invalidateList();
			// set the property across the pond
			ec.setProperty(obj.path, obj.property, String(value), obj.type);
		}
		
		public static function updateBooleanValue(currentValue:String):void
		{
			var obj:Object = app.propertyInspector.selectedItem;
			var value:String;
			// set new value
			obj.value = value = currentValue == "true" ? "false" : "true";
			// cause for update in cell
			app.propertyInspector.invalidateList();
			// set the property across the pond
			ec.setProperty(obj.path, obj.property, String(value), obj.type);
		}
		
		public static function toolChange(event:Event):void
		{
			if(app.propertiesViewStack.selectedIndex == 2)
			{
				app.videoPlayerURL = "http://labs.blitzagency.com/wp-content/xray/flex2/assets/videos/FullDemo.flv";
			}else
			{
				//app.videoContainer.close();
			}
		}
		
		// when the datagrid is clicked, this is what handles showing stuff and making calls
		public static function clickHandler(event:ListEvent):void
		{
			if(event.rowIndex == 0) return;
			//OutputTools.tt(["Click", event.rowIndex, event.reason])
			var obj:Object = getData(event);
			//OutputTools.tt(["Click", obj])
						
			// 0,1,2,3,5,6,8,12
			var type:Number = obj.objectType;
			//OutputTools.tt(["Click", type,obj])
			if(type == 7)//function?
			{
				if(app.treeviewStack.selectedIndex != 1)
				{
					app.currentFunctionCall = obj.path + "();";
					// set to the trace panel
					app.treeviewStack.selectedIndex = 1;
				}else
				{
					app.input.text = obj.path + "();";
				}
				//OutputTools.tt(["input available?", app.input])

				// if it's lower case function, then this is NOT a class, return
				if(obj.value.toLowerCase() == "[typefunction]") return
			}
			// searchable object type?
			if((type == 0 || type == 1 || type == 2 || type == 3 || type == 5 || type == 6 || type == 7 || type == 8 || type == 12) && obj.prop != "Class")
			{
				var selectedNode:Object = app.treeView.selectedItem;
				// update after setting history
				currentInspectorObject = obj;
				
				app.historyBack.enabled = true;
				history.push(obj);
				TreeTools.getProperties(obj.path, type);
			}else
			{
				//change states
				currentEditorObject = getEditorProperties(obj.prop);
				//OutputTools.tt(["boolean check",obj.value, currentEditorObject, type, obj.value.toLowerCase().indexOf(".flv")])
				if(currentEditorObject == null) currentEditorObject = {};
				// boolean
				if(type == 11 || currentEditorObject.stateName == "booleanEditor") 
				{
					//OutputTools.tt(["boolean"])
					updateBooleanValue(obj.value);
					app.currentState = '';
				}
				// string
				else if(type == 9 && obj.value.toLowerCase().indexOf(".flv") > -1)
				{
					//OutputTools.tt(["FLV STring"]);
					//we've found an flv file reference.  Prompt user to see if they want to set it as the current flv to play back
					tempFLVReference = obj.value;
					Alert.show("Do you want to save this as your current FLV playback file for netStream objects?\n\n"+obj.value, "Save FLV Reference", (Alert.YES | Alert.NO | Alert.CANCEL), null, alertClickHandler, null, Alert.OK);					
				}
				else
				{
					switch(type)
					{
						case 9://string
							if(currentEditorObject == null) currentEditorObject = {};
							currentEditorObject.prop = obj.prop;
							currentEditorObject.value = obj.value == "false" ? false : obj.value;
							app.currentState = "stringNumericEdit";
							evaluateString(obj.value);
							//OutputTools.tt(["String edit", obj])
						break;
						case 10://Number
							if(currentEditorObject == null) currentEditorObject = {};
							currentEditorObject.prop = obj.prop;
							currentEditorObject.value = obj.value;
							app.currentState = "stringNumericEdit";
							
							//OutputTools.tt(["String edit", obj])
						break;
						default:
							//OutputTools.tt(["not boolean", type, currentEditorObject]);
							currentEditorObject.prop = obj.prop;
							currentEditorObject.value = obj.value == "false" ? false : obj.value;
							app.currentState = '';
							app.currentState = currentEditorObject.stateName;
							// dispatch event
							if(obj.prop == "_x" || obj.prop == "_y" || obj.prop == "_width" || obj.prop == "_height")
							{
								var evt:PropertyToolEvent = new PropertyToolEvent(PropertyToolEvent.AXIS_EDIT, obj.path, obj.prop, obj.value);
								//OutputTools.tt(["dispatch axisEdit", evt]); 
		               			instance.dispatchEvent(evt);
		     				}
					}
					
				}
			}
		}
		
		public static function getProperty(propName:String):Object
		{
			var obj:Object = app.propertyInspector.dataProvider;
			for(var items:String in obj)
			{
				if(obj[items].property == propName) return obj[items];
			}
			
			return null;
		}
		
		public static function goBack():void
		{
			if(history == null) return;
			var obj:Object = history.pop();
			//OutputTools.tt(["back",obj, history])
			if(history.length <= 0) app.historyBack.enabled = false;
			var path:Array = obj.path.split(".");
			path.pop();
			TreeTools.getProperties(path.join("."), obj.objectType);
		}
		
		private static function evaluateString(str:String):void
		{
			// job is to find out if there's an mp3, image, link etc
			if(str.indexOf("http://") > -1 || str.indexOf("https://") > -1)
			{
				if(str.indexOf(".mp3") > -1)
				{
					// play mp3
					MP3PlayBack.loadSound(str);
					Alert.show("Close this window when you're done listening", "MP3 Preview", (Alert.OK), null, MP3alertClickHandler, null, Alert.OK);
					return;
				}
				
				//if(str.indexOf(".html") > -1 || str.indexOf(".htm") > -1 || str.indexOf(".php") > -1)
				//{
					// launch URL
					var u:URLRequest = new URLRequest(str);
					navigateToURL(u, "_blank");
					return
				//}
			}
		}
		
		private static function MP3alertClickHandler(event:CloseEvent):void
		{
			MP3PlayBack.unloadSound();
		}
		
		private static function alertClickHandler(event:CloseEvent):void
        {
            if (event.detail==Alert.YES)
            {
            	VideoTools.currentFLVReference = tempFLVReference;
            }else
            {
            	// clear it
            	tempFLVReference = "";
        	}
        }
		
		private static function getData(event:Object):Object
		{
			lastDataGridRow = event.rowIndex;
			var row:Number = event.rowIndex - 1;
			var data:Object = app.propertyInspector.dataProvider;
			
			var obj:Object = {};
			obj.prop = data[row].property;
			obj.value = data[row].value;
			obj.path = data[row].path;
			obj.type = data[row].type;
			obj.objectType = data[row].objectType;
			//OutputTools.tt(["getData", obj]);
			return obj;
		}
	}
}