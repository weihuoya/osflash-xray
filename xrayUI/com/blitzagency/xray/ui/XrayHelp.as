package com.blitzagency.xray.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.controls.VideoDisplay;
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	public class XrayHelp
	{
		public static var app:Object = mx.core.Application.application;
		public static var initialized:Boolean = init();
		private static var tw:TitleWindow;
		private static var videoPlayer:VideoDisplay;
		private static var parent:DisplayObject = DisplayObject(mx.core.Application.application);
		
		private static function init():Boolean
		{			 
			 return true;
		}
		
		public static function selectHelp(event:Event):void
		{
			showVideo(app.videoHelpListContainer.selectedItem.data, app.videoHelpListContainer.selectedItem.label)
		}
		
		public static function showVideo(flvPath:String, label:String):void
		{
			//var window:IFlexDisplayObject = TitleWindow(PopUpManager.createPopUp(parent, videoHelpWindow , true));
			var window:videoHelpWindow = videoHelpWindow(PopUpManager.createPopUp(parent, videoHelpWindow , true));
			window.title = label;
			PopUpManager.centerPopUp(window);
			window.flvPath = flvPath; 
		}
	}
}