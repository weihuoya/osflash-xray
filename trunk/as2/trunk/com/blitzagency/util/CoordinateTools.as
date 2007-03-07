/*
Developer: John Grden
*/
class com.blitzagency.util.CoordinateTools
{
	public static var initialized:Boolean = initialize();
	
	private static function initialize():Boolean
	{
		_global.localToLocal = localToLocal;
		return true;
	}
	
	public static function localToLocal(from:MovieClip, to:MovieClip, origin:Object):Object
	{
		var point:Object = origin == undefined ? {x: 0, y: 0} : origin;
		from.localToGlobal(point);
		to.globalToLocal(point);
		return point;
	} 
	
	public static function getAngle(pointAX:Number, pointAY:Number, pointBX:Number, pointBY:Number):Number
	{
		//return angle
		var nYdiff:Number = (pointAY - pointBY);
		var nXdiff:Number = (pointAX - pointBX);
		var rad:Number = Math.atan2(nYdiff, nXdiff);
	
		var deg:Number = Math.round(rad * 180 / Math.PI);
	
		//this will return a true 360 value
		deg = convertDegrees(deg);
		//deg < 0 ? 180 + (180-Math.abs(deg)) : deg;
		return deg;
	}
	
	public static function convertDegrees(p_degree:Number):Number
	{
		var deg:Number = p_degree < 0 ? 180 + (180-Math.abs(p_degree)) : p_degree;
		return deg;
	}
	
	public static function getRectangle(p_x:Number, p_y:Number, p_width:Number, p_height:Number):Object
	{
		var obj:Object = {};
		obj.x = p_x;
		obj.y = p_y;
		obj.width = p_width;
		obj.height = p_height;		
		obj.top = p_y;
		obj.left = p_x;
		obj.right = p_x + p_width;
		obj.bottom = p_y + p_height;
		obj.bottomRight = {x:(p_x + p_width), y:(p_y + p_height)};
		obj.topLeft = {x:p_x, y:p_y};
		
		return obj;
	}
}