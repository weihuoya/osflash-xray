package
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.*;
	import com.blitzagency.xray.logger.XrayLog;
	
	public class XrayConnector extends Sprite
	{
		private var log:XrayLog = new XrayLog();
		private var canvas:Sprite;
		
		public function XrayConnector()
		{
			addChild(canvas = new Sprite());
			canvas.name = "testSprite";
			for(var i:Number=0;i<this.numChildren;i++)
			{
				var container:DisplayObject = this.getChildAt(i);
				log.debug("container name", container.name);
			}
		}
	}
}