// ** AUTO-UI IMPORT STATEMENTS **
// ** END AUTO-UI IMPORT STATEMENTS **

//import mx.utils.Delegate;
import com.blitzagency.util.Delegate;
//import mx.events.EventDispatcher;
import com.blitzagency.events.GDispatcher;
import com.blitzagency.util.CoordinateTools;
import com.blitzagency.util.DrawingTools;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
//import flash.geom.Rectangle;

class com.blitzagency.controls.EditTool
{
// Constants:
	public static var CLASS_REF = com.blitzagency.controls.EditTool;
	public static var LINKAGE_ID:String = "com.blitzagency.controls.EditTool";
// Public Properties:
	public var currentSelection:MovieClip;
	public var _this:MovieClip;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var allowMove:Boolean = true;
	public var allowRatioScale:Boolean = true;
	public var allowWidthScale:Boolean = true;
	public var allowHeightScale:Boolean = true;
	public var allowRotate:Boolean = true;
// Private Properties:
	private var dispatchEvent:Function;
	private var mc_hiddenBtn:MovieClip;
	private var scaleDiff:Number;
	private var si:Number;
	private var rect:Object;
	private var boundingBox:MovieClip;
	private var rotateHandle:MovieClip;
	private var currentAngle:Number;
	//private var angleDiff:Number;
	private var blur:BlurFilter;
	private var ds:DropShadowFilter;
	// corner movieclips - attached at runtime
	private var c0:MovieClip;
	private var c1:MovieClip;
	private var c2:MovieClip;
	private var c3:MovieClip;
	
// UI Elements:

// ** AUTO-UI ELEMENTS **
	private var center:MovieClip;
// ** END AUTO-UI ELEMENTS **

// Initialization:
	function EditTool() {GDispatcher.initialize(this);}

// Public Methods:
	public function initialize(p_editToolContainer:MovieClip, p_mc:MovieClip, p_allowMove:Boolean, p_allowRatioScale:Boolean, p_allowWidthScale:Boolean, p_allowHeightScale:Boolean, p_allowRotate:Boolean):Void 
	{
		_this = p_editToolContainer;
		
		createCenter();
		
		allowMove = p_allowMove;
		allowRatioScale = p_allowRatioScale;
		allowWidthScale = p_allowWidthScale;
		allowHeightScale = p_allowHeightScale;
		allowRotate = p_allowRotate;
		
		blur = new BlurFilter(1.2, 1.2, 3);
		ds = new DropShadowFilter(4, 45, 0, 1, 2, 2, 1, 3, false, false, false);
		
		currentSelection = p_mc;

		// move to same coordinates
		_this._x = currentSelection._x;
		_this._y = currentSelection._y;
		
		updateBoundingBox();  // create bounding box		
		
		// the hidden button is really meant for dragging the clip around
		//boundingBox.duplicateMovieClip("mc_hiddenBtn", 99);
		createHiddenButton();
		
		// Create the corner clips
		createCorners();
		if(allowRotate) createRotateHandle();
	}
	
	public function destroyTool(evtObj:Object):Void
	{
		//_global.tt("destroyTool called", this);
		_this.removeMovieClip();
		dispatchEvent({type:"destroyTool"});
	}
// Semi-Private Methods:
// Private Methods:

	private function getRegPoint(origin:Object):Object
	{
		var point:Object = CoordinateTools.localToLocal(currentSelection, _this, origin);
		return point;
	}
	
	private function updateRect():Void
	{
		var point = getRegPoint();
		//var obj:Object = currentSelection.getBounds();
		//rect = new Rectangle(currentSelection._x, currentSelection._y, currentSelection._width, currentSelection._height);
		//rect = CoordinateTools.getRectangle(point.x, point.y, currentSelection._width, currentSelection._height)
		rect = CoordinateTools.getRectangle(point.x, point.y, currentSelection._width, currentSelection._height)
	}

	private function updateContentVisual():Void
	{
		// purpose is to apply filters to help the presentation.  Like adding blur to help resized/pixelated images
		_this.filters = [blur];
	}
	
	private function createCenter():Void
	{
		center = _this.createEmptyMovieClip("center", _this.getNextHighestDepth());
		drawCircle(center, 0, 0, 4);
		
		//var lineRect:Object = CoordinateTools.getRectangle(0, 0, 7, 1);
		//var hLine:MovieClip = DrawingTools.drawBox(center, 0xFFFFFF, 100, lineRect);
		//center.hLine.duplicateMovieClip("vLine", center.getNextHighestDepth());
		//center.vLine._rotation = 90;
		//center.hLine._x = -2.5;
		//center.hLine._y = 2.5;
	}
	
	private static function drawCircle(mc:MovieClip, x:Number, y:Number, r:Number):Void 
	{
		mc.lineStyle(0, 0xFFFFFF);
		mc.beginFill(0xFFFFFF, 25);
		mc.moveTo(x+r, y);
		mc.curveTo(r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo(Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
		mc.curveTo(-Math.tan(Math.PI/8)*r+x, r+y, -Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo(-r+x, Math.tan(Math.PI/8)*r+y, -r+x, y);
		mc.curveTo(-r+x, -Math.tan(Math.PI/8)*r+y, -Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.curveTo(-Math.tan(Math.PI/8)*r+x, -r+y, x, -r+y);
		mc.curveTo(Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.curveTo(r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
		mc.endFill();
	}

	private function updateBoundingBox()
	{
		if(boundingBox != undefined) boundingBox.removeMovieClip();
		updateRect();
		
		
		boundingBox = DrawingTools.drawBox(_this, 0xFFFFFF, 5, rect, 0xFFFFFF);
		var moveBox:MovieClip = DrawingTools.drawBox(boundingBox, 0xFFFFFF, 5, rect, 0xFFFFFF, 0);
		
		var obj:Object = currentSelection.getBounds(currentSelection._parent);
		//var obj:Object = currentSelection.getBounds(); // works
		var point:Object = CoordinateTools.localToLocal(currentSelection._parent, _this, {x:obj.xMin, y:obj.yMin});
		//var point:Object = CoordinateTools.localToLocal(currentSelection, this, {x:obj.xMin, y:obj.yMin}); //works
		
		boundingBox._x = point.x;
		boundingBox._y = point.y;
		
		/*
		var obj:Object = currentSelection.getBounds();
		boundingBox._x += obj.xMin * (currentSelection._xscale * .01);
		boundingBox._y += obj.yMin * (currentSelection._yscale * .01);
		*/
		//_this._rotation = currentSelection._rotation;
		
		scaleDiff = Math.floor((currentSelection._xscale / boundingBox._xscale) * 100);
		
		if(allowMove)
		{
			moveBox.onPress = Delegate.create(this, startMove);
			moveBox.onRelease = moveBox.onReleaseOutside = Delegate.create(this, stopMove);
			//boundingBox.onPress = Delegate.create(this, startMove);
			//boundingBox.onRelease = boundingBox.onReleaseOutside = Delegate.create(this, stopMove);
		}
	}
	
	private function createHiddenButton():Void
	{
		mc_hiddenBtn = DrawingTools.drawBox(_this, 0xFFFFFF, 5, rect, 0xFFFFFF, 99);
		mc_hiddenBtn._alpha = 20;
		mc_hiddenBtn._width = boundingBox._width * 100;
		mc_hiddenBtn._height = boundingBox._height * 100;
		mc_hiddenBtn._x -= mc_hiddenBtn._width/2;
		mc_hiddenBtn._y -= mc_hiddenBtn._height/2;
		
		// set the hidden bg button press
		mc_hiddenBtn.onRelease = Delegate.create(this, destroyTool);
	}
	
	private function createRotateHandle():Void
	{
		rotateHandle = _this.createEmptyMovieClip("rotateHandle", _this.getNextHighestDepth());
		drawCircle(rotateHandle, 0, 0, 4);
		//rotateHandle = _this.attachMovie("com.blitzagency.controls.GraphicButton:rotate", "rotateHandle", _this.getNextHighestDepth());
		rotateHandle.onPress = Delegate.create(this, grabRotate);
		rotateHandle.onRelease = rotateHandle.onReleaseOutside = Delegate.create(this, releaseRotate);
		updateRotateHandle();
	}

	private function createCorners():Void
	{
		var square = CoordinateTools.getRectangle(0, 0, 8, 8);
		
		if(!allowRatioScale)
		{
			c2 = DrawingTools.drawBox(_this, 0xFFFFFF, 50, square, 0xFFFFFF, _this.getNextHighestDepth());
			//var corner:MovieClip = _this.attachMovie("com.blitzagency.controls.GraphicButton:SelectionCorner", "c2", _this.getNextHighestDepth());
			
			c2.num = x;
			c2.onPress = Delegate.create(this, grabCorner);
			c2.onRelease = c2.onReleaseOutside = Delegate.create(this, releaseCorner);
			updateCorners();
		}else
		{
			for(var x:Number=0;x<4;x++)
			{
				var corner:MovieClip = _this.attachMovie("com.blitzagency.controls.GraphicButton:SelectionCorner", "c" + x, _this.getNextHighestDepth());
				
				corner.num = x;
				corner.addEventListener("down", Delegate.create(this, grabCorner));
				corner.addEventListener("click", Delegate.create(this, releaseCorner));
			}
			
			// position corners
			updateCorners();
		}
	}
	
	private function grabCorner(evtObj:Object):Void
	{
		scale();
	}
	
	private function releaseCorner(evtObj:Object):Void
	{
		stop_scale();
	}
	
	private function updateRotateHandle():Void
	{
		rotateHandle._x = c2._x + 15;
		rotateHandle._y = c2._y + 15;
	}
	
	private function updateCorners():Void
	{
		for(var i:Number=0;i<4;i++)
		{
			switch(i)
			{
				case 0:
					this["c" + i]._x = boundingBox._x;
					this["c" + i]._y = boundingBox._y;
					break;
				case 1:
					this["c" + i]._x = boundingBox._x + (boundingBox._width-5);
					this["c" + i]._y = boundingBox._y;
					break;
				case 2:
					this["c" + i]._x = boundingBox._x + (boundingBox._width-5);
					this["c" + i]._y = boundingBox._y + (boundingBox._height-5);
					
					updateRotateHandle();
					break;
				case 3:
					this["c" + i]._x = boundingBox._x;
					this["c" + i]._y = boundingBox._y + (boundingBox._height-5);
					break;
			}
		}
	}
	
	// define possible public methods
	//************[ ROTATE ] ************************
	
	private function grabRotate(evtObj:Object):Void
	{
		if(!allowRotate) return;
		currentAngle = getAngle();
		clearInterval(si);
		si = setInterval(this, "rotate",25);
	}
	
	private function releaseRotate(evtObj:Object):Void
	{
		clearInterval(si);
		_this._rotation = 0;
		updateBoundingBox();
		updateCorners();
	}
	
	private function getAngle():Number
	{
		var angle:Number = CoordinateTools.getAngle(center._x, center._y, center._xmouse, center._ymouse);
		//var angle:Number = CoordinateTools.getAngle(_this._x, _this._y, _this._xmouse, _this._ymouse);
		return angle;
	}
	
	private function rotate():Void
	{
		var angle:Number = getAngle();
		var diff:Number = angle - currentAngle;
		
		_this._rotation += diff;
		currentSelection._rotation += diff;
		dispatchEvent({type:"rotate", value:_this._rotation});
		updateContentVisual();
	}

	//************[ SCALE ] ************************
	private function scale():Void
	{
		//if(!allowRatioScale) return;
		clearInterval(si);
		si = setInterval(this, "updateScale", 25);
	}
	
	private function getCoordinates():Object
	{		
		//var point:Object = centerRegister ? CoordinateTools.localToLocal(currentSelection, currentSelection._parent, {x:currentSelection._xmouse, y:currentSelection._ymouse}) : {x:_xmouse, y:_ymouse};
		//var point:Object = CoordinateTools.localToLocal(currentSelection, currentSelection._parent, {x:currentSelection._xmouse, y:currentSelection._ymouse});
		var point:Object = {x:_this._xmouse, y:_this._ymouse};
		return point;
	}
	
	private function updateScale()
	{
		var s = currentSelection;
		var point:Object = getCoordinates();
		//var point:Object = CoordinateTools.localToLocal(_this, currentSelection, {x:_xmouse, y:_ymouse});
		var obj:Object = currentSelection.getBounds();
		
		var xOffset:Number = obj.xMin * (currentSelection._xscale * .01);
		var yOffset:Number = obj.yMin * (currentSelection._yscale * .01);
		
		var xm = point.x;
		var ym = point.y;
		
		if(allowRatioScale || Key.isDown(Key.SHIFT))
		{
			// get ratio between xscale and yscale
			//var p = s._xscale/s._yscale;
			var p = s._width/s._height;
			// set new width of the stage movie clip
			//s._width = !centerRegister ? Math.abs(s._x - xm) : Math.abs(s._x - xm)*2;
			s._width = xm + Math.abs(xOffset);
			// set yscale based on ratio to keep same
			//s._yscale = s._xscale / p;
			s._height = s._width/ p;
			
			// update lines
			updateBoundingBox();
			
			// update the corner square's positions
			updateCorners();			
			
			// send to asset to maintain scale number and do actual scaling
			var value:Number = s._xscale * (scaleDiff/100);
		}
		else
		{
			currentSelection._width = xm + Math.abs(xOffset)// * 2;
			currentSelection._height = ym + Math.abs(yOffset)// * 2;
			
			updateBoundingBox();
		
			// update the corner square's positions
			updateCorners();	
		}		
		
		updateContentVisual();
		
		dispatchEvent({type:"scale", value:value});
	}

	private function stop_scale()
	{
		clearInterval(si);
	}
	//************[ MOVE ] ***********************
	
	private function onMouseMove(evtObj:Object):Void
	{
		currentSelection._x = _this._x;
		currentSelection._y = _this._y;
	}
	
	private function startMove():Void
	{
		if(!allowMove) return;
		
		Mouse.addListener(this);
		_this.startDrag();
		_this.filters = [blur, ds];
		//dispatchEvent({type:"startMove"});
	}
	
	private function stopMove():Void
	{
		Mouse.removeListener(this);
		_this.stopDrag();
		updateContentVisual();
		//dispatchEvent({type:"stopMove"});
	}
}