import com.blitzagency.events.GDispatcher;
class com.blitzagency.xray.ui.ListView extends MovieClip
{
	var addEventListener:Function;
	var removeEventListener:Function;
	var dispatchEvent:Function;
	
	public var columnObj:Object;
	private var main:MovieClip;
	public var dataAry:Array;
	
	//public UI
	public var column:MovieClip;
	
	function ListView()
	{
		// initialize event dispatcher
		GDispatcher.initialize(this);
	}

	public function onLoad()
	{
		column.addEventListener("change", this);
		this.main = _level0.main;
		this.dataAry = new Array();
		init();
	}

	public function init():Void
	{
		if(columnObj) setProps(columnObj);
		_global.tt("ListView initialized")
	}
	
	public function setProps(obj:Object):Void
	{
		_global.tt("setProps", obj);
		this.dataAry = new Array();
		for (var items:String in obj) 
		{
			if(typeof(obj[items]) == "object")
			{
				/*
				NOTES:
					At this point, we need to check for object type that's passed back.  
					
					MovieClips, buttons, textFields, objects, arrays will go to the list
					Everything goes to the PI
					
					if(bObject) i=0;
					if(bAry) i=1;
					if(bMc) i=2;
					if(bButton) i=3;
					if(bSound) i=4;
					if(bTextField) i=5;
					if(bVideo) i=6;
					if(bFunction) i = 7;
					if(bNetStream) i = 8;
					if(bString) i = 9;
					if(bNumber) i = 10;
					if(bBoolean) i = 11;
				*/
				if(obj[items].type == 0 
					|| obj[items].type == 1
					|| obj[items].type == 2
					|| obj[items].type == 3
					|| obj[items].type == 4
					|| obj[items].type == 5
					|| obj[items].type == 6
					|| obj[items].type == 8)
				{
					var label:String = items + " (" + obj[items].className + ")";
					var data:String = obj[items];
					//_global.tt("should add to list", this.column, this.column.addItem, label, data);
					this.column.addItem({label:label, data:data})
				}
				
				/* moved to main
				var prop:String = items + " (" + obj[items].className + ")";
				var val:String = obj[items];
				dataAry.push({Property:prop, Value:val});
				*/
			}
		}
		
		//update the PI
		//this.dispatchEvent({type:"onPIUpdate", dataAry:dataAry});
	}
	
	public function change(eventObj:Object):Void
	{
		_global.tt("change", eventObj.target.selectedItem.data,this._name.split("list")[1], eventObj.target);
		this.dispatchEvent({type:"onListClick", obj:eventObj});
	}
}