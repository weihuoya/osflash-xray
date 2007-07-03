package com.blitzagency.xray.ui
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.DataGrid;
	import mx.core.Application;
	
	public class PropertyFactory
	{
		public var app:Object = mx.core.Application.application;
		[Bindable]
		public var propertyInspectorData:ArrayCollection;
		private var sortA:Sort;
		private var sortByProperty:SortField;
		private var dg:DataGrid;
		
		public function PropertyFactory():void
		{
			sortA = new Sort();
			sortByProperty = new SortField("property", true, false, false);
			
			dg = app.propertyInspector;
		}
		
		public function updatePropertyInspector(properties:XMLList, extProperties:XMLList, currentPath:String, currentType:Number):void
		{
			propertyInspectorData = serializeData(properties, extProperties, currentPath, currentType);
			// sort the data alphabetically
			sortA.fields = [sortByProperty];
			propertyInspectorData.sort = sortA;
			var refreshed:Boolean = propertyInspectorData.refresh();
			// update the data
			app.propertyInspector.dataProvider = propertyInspectorData;
		}
		
		public function updatePropertyInspectorLegacyData(properties:Object, currentPath:String, currentType:Number):void
		{
			propertyInspectorData = serializeLegacyData(properties, currentPath, currentType);
			
			// sort the data alphabetically
			sortA.fields = [sortByProperty];
			propertyInspectorData.sort = sortA;
			var refreshed:Boolean = propertyInspectorData.refresh();
			
			// update the data
			app.propertyInspector.dataProvider = propertyInspectorData;
		}
		
		private function serializeData(properties:XMLList, extProperties:XMLList, currentPath:String, currentType:Number):ArrayCollection
		{
			//OutputTools.tt(["*********0", properties]);
			var simpleAry:Array = [];
			if(extProperties.length() > 0)
			{
				//OutputTools.tt(["*********2"]);
				var simpleObj:Object;
				var ary:Array;
				var value:String = "";
				
				for(var items:String in extProperties)
				{
					if(extProperties[items].children().length() > 1) continue;
					
					simpleObj = {};
					ary = [];
					value = String(extProperties[items].toString());

					if(value.indexOf("::") > -1)
					{
						ary = value.split("::");
					}else
					{
						ary.push("property");
						ary.push(value);
					}
					simpleObj.property = extProperties[items].name().localName;	
					simpleObj.value = ary[1];
					simpleObj.type = ary[0];
					simpleObj.path = currentPath + "." + simpleObj.property;
					simpleObj.objectType = -1; // give movieclip properties -1 so prop inspector won't let those be clicked ;)
					
					simpleAry.push(simpleObj);
					
					//OutputTools.tt(["extProperties", extProperties[items].name().localName, extProperties[items]])
				}
			}
			
			//var simpleObj:Object;
			//var ary:Array;
			//var value:String = "";
			
			for(items in properties)
			{
				//OutputTools.tt(["*********0.5",properties[items].name().localName, properties[items].children().length(),properties[items]]);
				// if children length is greater than 1, this is another full node
				if(properties[items].children().length() > 1) continue;
				
				simpleObj= {};
				ary = [];
				//var value:String = String(properties[items].split(" ").join(""));
				value = String(properties[items].toString());
				//OutputTools.tt(["what's value?", value, properties[items]]);
				if(value.indexOf("::") > -1)
				{
					ary = value.split("::");
				}else
				{
					ary.push("Object");
					ary.push(value);
				}
				
				simpleObj.property = properties[items].name().localName;	
				simpleObj.value = ary[1];
				simpleObj.type = ary[0];
				simpleObj.path = currentPath + "." + simpleObj.property;
				simpleObj.objectType = getType(ary[0]);
				
				simpleAry.push(simpleObj);
				
				// for NetStream only - updates the playhead position
				if(currentType == 8 && simpleObj.property == "time") VideoTools.updateTimePosition(ary[1]);
				
				//OutputTools.tt(["Properties", simpleObj, ary[1], ary, value])
			}
			//OutputTools.tt(["*********1"]);
			//OutputTools.tt(["*********setObjectProperties", extProperties.length()])
			
			//OutputTools.tt(["Final Properties", simpleAry])
			var returnObj:ArrayCollection = new ArrayCollection(simpleAry);

			return returnObj;
		}
		
		private function getType(type:String):Number
		{
			var returnType:Number = 0;
			switch(type.toLowerCase())
			{
				case "object":
					returnType = 0;
				break;
				
				case "array":
					returnType = 1;
				break;
				
				case "movieclip":
					returnType = 2;
				break;
				
				case "button":
					returnType = 3;
				break;
				
				case "sound":
					returnType = 4;
				break;
				
				case "textfield":
					returnType = 5;
				break;
				
				case "video":
					returnType = 6;
				break;
				
				case "function":
					returnType = 7;
				break;
				
				case "netstream":
					returnType = 8;
				break;
				
				case "string":
					returnType = 9;
				break;
				
				case "number":
					returnType = 10;
				break;
				
				case "boolean":
					returnType = 11;
				break;
				
				case "date":
					returnType = 12;
				break;
			}
			
			return returnType;
			
			/*
	        	if(bObject) {i=0} else 
				if(bAry) {i=1} else 
				if(bMc) {i=2} else 
				if(bButton) {i=3} else 
				if(bSound) {i=4} else 
				if(bTextField) {i=5} else 
				if(bVideo) {i=6} else 
				if(bFunction) {i = 7} else 
				if(bNetStream) {i = 8} else 
				if(bString) {i = 9} else 
				if(bNumber) {i = 10} else 
				if(bBoolean) {i = 11} else 
				if(bDate) {i = 12}
	        	*/	
		}
		
		private function serializeLegacyData(obj:Object, currentPath:String, currentType:Number):ArrayCollection
		{
			var simpleAry:Array = [];
			
			for(var items:String in obj)
			{
				var simpleObj:Object = {};
				var ary:Array = obj[items].split(" :: ");	

							
				simpleObj.property = items;	
				simpleObj.value = ary[1];
				simpleObj.type = ary[0];
				simpleObj.path = currentPath + "." + simpleObj.property;
				simpleObj.objectType = currentType;				
				
				simpleAry.push(simpleObj);
			}
			var returnObj:ArrayCollection = new ArrayCollection(simpleAry);

			return returnObj;
		}
	}
}