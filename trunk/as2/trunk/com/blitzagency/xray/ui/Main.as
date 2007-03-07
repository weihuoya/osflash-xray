/*
 *
 * @author
 * @version
 */
import com.blitzagency.events.GDispatcher;
import com.blitzagency.xray.ui.ExecConnections;
import com.blitzagency.xray.XrayTrace;
import com.blitzagency.util.Delegate;

class com.blitzagency.xray.ui.Main extends MovieClip
{
	var addEventListener:Function;
	var removeEventListener:Function;
	var dispatchEvent:Function;
	
	// public objects
	public var mainView:MovieClip;
	public var content:MovieClip;
	public var greenLight:MovieClip;
	public var path:MovieClip;
	public var startBtn:MovieClip;
	public var mask:MovieClip;
	public var propertyInspector:MovieClip;
	public var panes:Array;
	public var execConn:ExecConnections;
	public static var xrayTrace:XrayTrace;
	public var clickedPane:Number;
	
	// private properties
	//private var paneNum:Number;
	
	function Main()
	{
		// initialize event dispatcher
		GDispatcher.initialize(this);
	}

	public function onLoad()
	{
		init();
	}

	public function init():Void
	{
		xrayTrace = XrayTrace.getInstance();
		_global.tt = function()	{ xrayTrace.trace.apply(xrayTrace, arguments); }
		
		this.panes = new Array();
		propertyInspector.columnNames = ["Property", "Value"];
		//this.paneNum = 0;
		
		this.execConn = new ExecConnections();
		this.execConn.addEventListener("onConnection", this);
		
		this.startBtn.addEventListener("click", Delegate.create(this, this.onStartClick));
		
		// addEventListener for PropertyInspector
		propertyInspector.editable = true;
		propertyInspector.addEventListener("change", Delegate.create(this, this.propertyInspectorChange));
		
		_global.tt("Main UI initialized", this.execConn)
	}
	
	public function getObjectProperties(paneNum:Number, path:String):Void
	{
		// called if a movieclip reference is clicked.
		this.clickedPane = paneNum;
		this.execConn.getBaseProperties(path);
	}
	
	public function managePanes():Void
	{
		if(this.clickedPane != undefined)
		{
			for(var i:Number=this.clickedPane+1;i<this.panes.length;i++)
			{
				this.panes[i].removeMovieClip();
			}
			
			this.panes.splice(this.clickedPane+1, this.panes.length);
		}
	}
	
	// check to see if the returned object has any searchable objects
	public function checkChildren(obj:Object):Boolean
	{
		for(var items:String in obj)
		{
			if(obj[items].type == 0 || obj[items].type == 2 || obj[items].type == 1) return true;
		}
		return false;
	}
	
	public function updatePropertyInspector(obj)
	{		
		propertyInspector.removeAll();

		for(var items:String in obj)
		{
			_global.tt("updatePI", typeof(obj[items]),obj[items]);
			if(typeof(obj[items]) == "object")
			{
				var prop:String = items + " (" + obj[items].className + ")";
				_global.tt("loop", obj[items], obj[items].val);
				this.propertyInspector.addItem({Property:prop, Value:obj[items].val, data:obj[items]});
			}
		}
	}
	
	public function addPane(obj:Object):MovieClip
	{
		_global.tt("addPane", obj);
		this.managePanes();
		
		// update PI
		updatePropertyInspector(obj);
		
		// check for other objects within this one to see if we should make another pane
		if(!checkChildren(obj)) return;
		
		var mc:MovieClip = this.mainView.content.attachMovie("list", "list" + this.panes.length, this.mainView.content.getNextHighestDepth());
		
		mc.cacheAsBitmap = true;
		mc._x = mc._width * this.panes.length;
		mc._height = this.mainView.getPaneHeight();
		
		this.mainView.draw();
		
		this.panes.push(mc);
		
		// set the columnObj, so that when the list initializes, it can use it to populate the rows
		mc.columnObj = obj;
		
		// addeventlistener for listview click changes
		mc.addEventListener("onListClick", this);
		mc.addEventListener("onPIUpdate", this);
		
		// return movieclip reference
		return mc;
	}
	
	public function onConnection(eventObj:Object):Void
	{
		if(eventObj.status == "connected")
		{
			this.greenLight.gotoAndStop(2);
		}else
		{
			this.greenLight.gotoAndStop(1);
		}
	}
	
	public function onListClick(eventObj:Object):Void
	{
		var obj:Object = eventObj.obj;
		var mc:MovieClip = obj.target;
		
		var paneNum:Number = Number(mc._parent._name.split("list")[1])
		_global.tt("onListClick", mc.selectedItem.data.target, paneNum, mc.selectedItem.data.type);

		switch(mc.selectedItem.data.type)
		{
			case 0: // object
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 1: // array
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 2: // movieclip
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 3: // button
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 4: // sound
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 5: // textfield
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 6: // video
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 7: // function
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 8: // netstream
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			case 9: // string
				this.getObjectProperties(paneNum, mc.selectedItem.data.target)
			break;
			default:
				
		}
	}
	
	public function propertyInspectorChange(eventObj:Object):Void
	{
		_global.tt("propertyInspector change event", eventObj.target.selectedItem.data);
	}
	
	public function onPIUpdate(eventObj:Object)
	{
		//_global.tt("onPIUpdate", eventObj.dataAry, typeof(eventObj.dataAry));
		var obj:Object = eventObj.dataAry;
		propertyInspector.removeAll();

		for(var items:String in obj)
			this.propertyInspector.addItem({Property:obj[items].Property, Value:obj[items].Value.val, data:obj[items].Value});
	}
	
	public function onStartClick():Void
	{
		this.getObjectProperties(-1, path.value);
	}
}