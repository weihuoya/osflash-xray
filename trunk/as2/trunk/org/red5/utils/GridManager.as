import com.blitzagency.events.GDispatcher;
import com.blitzagency.util.DrawingTools;
import com.blitzagency.util.CoordinateTools;

class org.red5.utils.GridManager
{
	private static var eventDispatcherDependency:Object = GDispatcher;
	private static var eventDispatcherInitialized:Boolean = initEventDispatcher();

	public static var addEventListener:Function;
	public static var removeEventListener:Function;
	private static var dispatchEvent:Function;

	public static var mc:MovieClip; // movieclip where grid is created
	public static var cols:Number;
	public static var rows:Number;
	public static var gridCount:Number; // zero based number of tiles
	public static var currentGridLocation:Number; // represents current gridLocation
	private static var lastGridLocation:Number; // represents last gridLocation

	public static var horizontalRatio:Number;
	public static var verticalRatio:Number;
	
	private static var gridContainer:MovieClip;
	private static var gridLineHistory:Array;


	public function onLoad()
	{
		init();
	}

	public static function init():Void
	{
		if(!GridManager.cols) GridManager.cols = 8;
		if(!GridManager.rows) GridManager.rows = 8;
		
		// xray container for drawing grid lines
		initGridContainer();
	}

	private static function initEventDispatcher():Boolean
	{
		// initialize the Connector to dispatch events
		GDispatcher.initialize(GridManager);
		init();
		return true;
	}
	
	public static function initGridContainer():Void
	{
		
		gridLineHistory = [];
		
		//var depth:Number = 1048573;
		var depth:Number = _level0.getNextHighestDepth() >= 1048575 ? 1048573 : _level0.getNextHighestDepth()+1;
		gridContainer = _level0.createEmptyMovieClip("xrayGridManager", depth);
		
		// not sure we need  to draw a box
		/*
		var rect:Object = CoordinateTools.getRectangle(0, 0, Stage.width, Stage.height);
		DrawingTools.drawBox(gridContainer, 0x000000, 0, rect, null,0);
		*/
	}
	
	public static function drawGridLine(target, axis:String, position:Number, lineColor:Number, path:String):Void
	{
		// target can be a movieclip, button or textfield
		/* 	0.  decide parent
		* 	1.  convert to level0 coordinates
			2.  create line movieclip
			3.  push to history
		*/

		target = target._parent != undefined ? target._parent : target;
		
		var obj:Object = axis == "_x" ? {x:position, y:0} : {x:0, y:position}
		var point:Object = CoordinateTools.localToLocal(target, gridContainer, obj); 
		position = Math.abs(Math.floor(position));
		var mc:MovieClip = gridContainer.createEmptyMovieClip("gridLine_" + axis + "_" + position, gridContainer.getNextHighestDepth());
		addToGridLineHistory(mc, path);
		mc[axis] = axis == "_x" ? point.x : point.y;
		
		var fx:Number = 0//axis == "_x" ? position : 0;
		var fy:Number = 0//axis == "_y" ? position : 0;
		var tx:Number = axis == "_x" ? 0 : Stage.width;
		var ty:Number = axis == "_y" ? 0 : Stage.height;
		//_global.tt("GridManager.drawGridLine", axis, target, point, mc, gridLineHistory.length, fx, fy, tx, ty)
		
		lineColor = lineColor == undefined ? 0x00ff00 : lineColor;
		DrawingTools.drawLine(mc, lineColor, fx, fy, tx, ty);
	}
	
	private static function addToGridLineHistory(mc:MovieClip, path:String):Void
	{
		gridLineHistory.push({path:path, mc:mc});
	}
	
	public static function removeLastGridLine():Void
	{
		var line = gridLineHistory.pop();
		line.mc.removeMovieClip();
	}
	
	// clear lines only in a particular object
	public static function clearObjectGridLines(path:String):Void
	{
		for(var i:Number=0;i<gridLineHistory.length;i++)
		{
			var line = gridLineHistory[i];
			if(line.path == path) 
			{
				line.mc.removeMovieClip();
				gridLineHistory[i] = null;
			}
		}
		clearupHistory();
	}
	
	private static function clearupHistory():Void
	{
		for(var i:Number=0;i<gridLineHistory.length;i++)
		{
			if(gridLineHistory[i] == null) gridLineHistory.splice(i, 1);
		}
	}
	
	// clear all gridLines everywhere
	public static function clearAllGridLines():Void
	{
		for(var i:Number=0;i<gridLineHistory.length;i++)
		{
			var line = gridLineHistory[i];
			line.mc.removeMovieClip();
		}
		
		gridLineHistory = [];
	}

	public static function initGrid(p_mc:MovieClip, p_cols:Number, p_rows:Number, p_gridWidth:Number, p_gridHeight:Number, p_lineSize:Number, p_color:Number, p_drawGrid:Boolean):Void
	{
		_global.tt("initGrid called", arguments);
		/*
		NOTES:
			Draws a grid using the drawing api:
			initGrid(13,6,600,400,true);
		*/
		mc = p_mc;
		cols = p_cols;
		rows = p_rows;
		gridCount = (cols*rows)-1;
		horizontalRatio = (p_gridWidth)/cols;
		verticalRatio = (p_gridHeight)/rows;
		trace("dimensions :: " + horizontalRatio + " :: " + verticalRatio);
		
		Mouse.addListener(GridManager);

		if(!p_drawGrid) return;

		for(var i:Number=0;i<=cols;i++)
		{
			var line:MovieClip = mc.createEmptyMovieClip("colLine_" + i, mc.getNextHighestDepth());
			line.lineStyle(p_lineSize, p_color, 100);
			line.moveTo(horizontalRatio*i, 0);
			line.lineTo(horizontalRatio*i, p_gridHeight);
		}
		for(var i:Number=0;i<=rows;i++)
		{
			var line:MovieClip = mc.createEmptyMovieClip("rowLine_" + i, mc.getNextHighestDepth());
			line.lineStyle(p_lineSize, p_color, 100);
			line.moveTo(0, verticalRatio*i);
			line.lineTo(p_gridWidth,verticalRatio*i);
		}
	}
	
	public static function calcCenterSpot(p_col:Number, p_row:Number):Object
	{
		var x:Number = (p_col * horizontalRatio) + (horizontalRatio / 2);
		var y:Number = (p_row * verticalRatio) + (verticalRatio / 2);
		
		return {x:x, y:y};
	}
	
	public static function getColRow(p_location):Object
	{
		var row:Number = Math.floor(p_location / cols);
		var col:Number = Math.floor(p_location%cols);;
		
		return {col:col, row:row};
	}

	public static function calcGridLocation(p_x:Number, p_y:Number):Number
	{
		var x:Number = Math.ceil(p_x / (horizontalRatio));
		var y:Number = Math.ceil(p_y / (verticalRatio));

		var gridLocation = (x+(cols*(y-1)))-1; // -1 to make it zero based

		// check to see if the location is outside the bounds of the grid. If so, return null
		if(gridLocation < 0 ||
		   gridLocation > (cols*rows)-1 ||
		   x > cols ||
		   y > rows)
		   {
			   GridManager.currentGridLocation = null; // we want currentGridLocation to have a null if it's out of bounds
			   return null;
		   }
		GridManager.lastGridLocation = GridManager.currentGridLocation;
		GridManager.currentGridLocation = gridLocation; // we want currentGridLocation to have a null if it's out of bounds
		return gridLocation;
	}
	
	private static function onMouseMove():Void
	{
		var location:Number = calcGridLocation(mc._xmouse, mc._ymouse);
		if(location != null) 
		{
			if(location != GridManager.lastGridLocation) dispatchEvent({type:"gridLocationChange", location: location});
			if(location == GridManager.lastGridLocation) dispatchEvent({type:"gridLocation", location: location});
		}
	}
}