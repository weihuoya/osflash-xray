// ** AUTO-UI IMPORT STATEMENTS **
// ** END AUTO-UI IMPORT STATEMENTS **
import com.blitzagency.controls.EditTool;
import mx.utils.Delegate;

class com.blitzagency.controls.TransformTool{
// Constants:
	public static var CLASS_REF = com.blitzagency.controls.TransformTool;
	public static var LINKAGE_ID:String = "com.blitzagency.controls.TransformTool";
// Public Properties:
// Private Properties:
	private static var editTool:EditTool;
	private static var currentAsset:MovieClip;

// Public Methods:
	public static function initialize(p_asset:MovieClip, p_allowMove:Boolean, p_allowRatioScale:Boolean, p_allowWidthScale:Boolean, p_allowHeightScale:Boolean, p_allowRotate:Boolean):EditTool
	{
		if(editTool != undefined) editTool.destroyTool();
		var depth:Number = p_asset._parent.getNextHighestDepth() >= 1048575 ? 1048574 : p_asset._parent.getNextHighestDepth();
		var mc = p_asset._parent.createEmptyMovieClip("xrayEditTool", depth);
		editTool = new EditTool();
		//editTool = p_asset._parent.attachMovie("com.blitzagency.controls.EditTool", "editTool", depth);

		editTool.initialize(mc, p_asset, p_allowMove, p_allowRatioScale, p_allowWidthScale, p_allowHeightScale, p_allowRotate);
		
		return editTool;
	}
// Semi-Private Methods:
// Private Methods:
	public static function destroyTool(evtObj:Object):Void
	{
		editTool.destroyTool();
	}
}