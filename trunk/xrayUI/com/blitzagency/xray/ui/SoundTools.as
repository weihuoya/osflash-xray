package com.blitzagency.xray.ui
{
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.core.Application;
	import mx.events.ItemClickEvent;
	
	public class SoundTools
	{
		public static var app:Object = mx.core.Application.application;
		private static var ec:ExecuteConnection;
		private static var currentSoundPath:String;
		private static var currentSoundPosition:Number;
		private static var getSI:Number;
		private static var updatePosition:Boolean = true;
		private static var updateVolume:Boolean = true;
		private static var updatePan:Boolean = true;
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		public static function getSoundProperties(soundPath:String):void
		{
			startPropertyPoll();
			currentSoundPath = soundPath;
		}
		
		public static function getUpdatedProperties():void
		{
			if(currentSoundPath != null)ec.getSoundProperties(currentSoundPath);
		}
		
		public static function setSoundProperties(obj:Object):void
		{
			//OutputTools.tt(["setSoundProperties", obj]);			
			app.soundPosition.maximum = obj.txtDuration;
			if(updateVolume) app.soundVolume.value = obj.txtVolume;
			if(updatePan) app.soundPan.value = obj.txtPan;
			if(updatePosition) 
			{
				currentSoundPosition = Number(obj.txtPosition);
				app.soundPosition.value = obj.txtPosition;
			}
			app.soundName.text = getSoundName(currentSoundPath);
			app.soundDuration.text = obj.txtDuration;
		}
		
		public static function positionChange(event:Event):void
		{
			updatePosition = false;	
		}
		
		public static function positionChangeComplete(event:Event):void
		{
			updatePosition = true;
			playSound();
		}
		
		public static function volumeChange(event:Event):void
		{
			updateVolume = false;
			ec.setSoundProperty(currentSoundPath, "volume", app.soundVolume.value);
		}
		
		public static function volumeChangeComplete(event:Event):void
		{
			updateVolume = true;
		}
		
		public static function panChange(event:Event):void
		{
			updatePan = false;
			ec.setSoundProperty(currentSoundPath, "pan", app.soundPan.value);
		}
		
		public static function panChangeComplete(event:Event):void
		{
			updatePan = true;
		}
		
		public static function playSound():void
		{
			currentSoundPosition = app.soundPosition.value;
			if(currentSoundPosition == app.soundDuration.text) 
			{
				currentSoundPosition = 0;
			}
			var seconds:Number = convertToSeconds(currentSoundPosition);
			var loopCount:Number = Number(app.loopCount.text) + 1;
			ec.playSound(currentSoundPath, seconds, loopCount);
		}
		
		public static function stopSound():void
		{
			ec.stopSound(currentSoundPath);
		}
		
		public static function toolChange(event:Event):void
		{
			//OutputTools.tt(["toolChange", app.treeviewStack.selectedIndex])
			if(app.treeviewStack.selectedIndex != 3) stopPropertyPoll();
			if(app.treeviewStack.selectedIndex == 3) startPropertyPoll();
		}
		
		private static function startPropertyPoll():void
		{
			clearInterval(getSI);
			getSI = setInterval(SoundTools.getUpdatedProperties, 250);
		}
		
		private static function stopPropertyPoll():void
		{
			//OutputTools.tt(["stopPropertyPoll"])
			clearInterval(getSI);
		}
		
		private static function convertToSeconds(position:Number):Number
		{
			return position/1000;
		}
		
		private static function getSoundName(soundPath:String):String
		{
			var ary:Array = soundPath.split(".");
			return ary.pop();
		}
	}
}