import flash.geom.Rectangle;

class com.blitzagency.util.DrawingTools
{
	public static function drawBox(mc:MovieClip, clr:Number, alpha:Number, rect:Object, lineClr:Number, depth:Number):MovieClip
	{
		var d:Number = depth == undefined ? 100 : depth; //mc.getNextHighestDepth()
		var boxName = "mc_" + d;
		var mc:MovieClip = mc.createEmptyMovieClip(boxName, d);
		
		alpha = alpha == undefined ? 100 : alpha;
		lineClr = lineClr == undefined ? 0xFF0000 : lineClr;
		mc.beginFill(clr, alpha);
		if(lineClr != null) mc.lineStyle(.25, lineClr, 100);
		mc.moveTo(rect.left,rect.top); //upper left
		mc.lineTo(rect.left, rect.bottom);
		mc.lineTo(rect.bottomRight.x, rect.bottomRight.y);
		mc.lineTo(rect.right, rect.top);
		mc.lineTo(rect.left,rect.top);
		
		/*
		mc.lineTo(rect.left, rect.bottom);
		mc.lineTo(rect.bottomRight.x, rect.bottomRight.y);
		mc.lineTo(rect.right, rect.top);
		mc.lineTo(rect.left, rect.top);
		*/
		mc.endFill();

		return mc;
	}
	
	public static function drawLine(mc:MovieClip,clr:Number,fx:Number,fy:Number,tx:Number,ty:Number):Void
	{
		mc.beginFill(0x000000, 0);
		mc.lineStyle(.25, clr, 100);
		mc.moveTo(fx,fy);
		mc.lineTo(tx,ty)
		mc.endFill();
	}
}