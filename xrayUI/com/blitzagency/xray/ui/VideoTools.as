package com.blitzagency.xray.ui
{
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.ItemClickEvent;
	
	public class VideoTools
	{
		public static var app:Object = mx.core.Application.application;
		public static var metaData:Object;
		public static var currentFLVReference:String = ""; // set by PropertyTools when user selects from the PI
		private static var ec:ExecuteConnection;
		private static var currentVideoPath:String = "";
		private static var currentVideoPosition:Number;
		private static var getSI:Number;
		private static var updatePosition:Boolean = true;
		private static var initialized:Boolean = init();
		//private static var updateVolume:Boolean = true;
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		private static function init():Boolean
		{
			metaData = new Object();
			return true;
		}
		
		public static function setVideoFLVReference(flv:String):void
		{
			app.videoFLVReference.text = flv;
			currentFLVReference = flv;
		}
		
		public static function setMetaData(p_metaData:Object):void
		{
			metaData = p_metaData;
			updateSlider();
		}
		
		public static function updateSlider():void
		{
			if(!app.videoPosition)return
			app.videoPosition.enabled = true;
			app.videoPosition.maximum = metaData.duration;
		}
		
		private static function updateMetaData():void
		{
			//OutputTools.tt(["updateMetaData", metaData])
			app.metaData.text = "";
			//if(!metaData) return;
			
			var str:String = "";
			str += "Creation Date: " + metaData["creationdate"] + "\n"; 
			str += "duration: " + metaData["duration"] + "\n";
			str += "framerate: " + metaData["framerate"] + "\n";
			str += "video data rate: " + metaData["videodatarate"] + "\n";
			str += "width: " + metaData["width"] + "\n";
			str += "height: " + metaData["height"] + "\n";
			
			app.metaData.text = str;
		}
		
		public static function getVideoProperties(videoPath:String):void
		{
			startPropertyPoll();
			currentVideoPath = videoPath;
			//OutputTools.tt(["getVideoProperties", videoPath])
		}
		
		public static function getUpdatedProperties():void
		{
			//OutputTools.tt(["getUpdatedProperties", currentVideoPath])
			if(currentVideoPath != null) 
			{
				ec.getVideoProperties(currentVideoPath);
				app.videoName.text = currentVideoPath;
				app.videoFLVReference.text = currentFLVReference;
				updateSlider();
				if(app.metaData.text.length <= 0 || app.metaData.text.indexOf("duration: undefined") > -1) updateMetaData();
			}
		}
		
		public static function setVideoProperties(obj:Object):void
		{
			//OutputTools.tt(["setVideoProperties", obj]);
			
			/*
			app.videoPosition.maximum = obj.txtDuration;
			if(updateVolume) app.videoVolume.value = obj.txtVolume;
			if(updatePan) app.videoPan.value = obj.txtPan;
			if(updatePosition) 
			{
				currentVideoPosition = Number(obj.txtPosition);
				app.videoPosition.value = obj.txtPosition;
			}
			app.videoName.text = getVideoName(currentVideoPath);
			app.videoDuration.text = obj.txtDuration;
			*/
			
			/*
			  txtBufferLength = 0
			  txtBytesLoaded = 1531994
			  txtCurrentFps = 0
			  txtBytesTotal = 1531994
			  txtBufferTime = 0.1
			  txtPosition = 32.56
			  props = [object Object]
			      bufferLength = number :: 0
			      time = number :: 32.56
			      videocodec = number :: 2
			      bytesLoaded = number :: 1531994
			      currentFps = number :: 0
			      bufferTime = number :: 0.1
			      bytesTotal = number :: 1531994
			      onStatus = Function :: [type Function]
			      liveDelay = number :: 0
			      onMetaData = Function :: [type Function]
			      audiocodec = number :: 0
			      decodedFrames = number :: 0
			*/
		}
		
		public static function positionChange(event:Event):void
		{
			updatePosition = false;	
		}
		
		public static function positionChangeComplete(event:Event):void
		{
			updatePosition = true;
			playVideo(true);
		}
		
		public static function updateTimePosition(time:Number):void
		{
			app.videoPosition.value = time;
		}
		
		public static function playVideo(seek:Boolean):void
		{
			//OutputTools.tt(["playVideo", currentVideoPath, currentFLVReference, metaData.duration])
			
			if(currentFLVReference == "") 
			{
				// update status bar
				Alert.show("You need to select an FLV file reference to play/scrub NetStream video", "FLV File Reference Needed", (Alert.OK), null, null, null, Alert.OK);
				return;
			}
			
			var seconds:Number = 0;
			if(seek)
			{
				currentVideoPosition = app.videoPosition.value;
				
				if(metaData == null) metaData = {};
				if(currentVideoPosition == metaData.duration) 
				{
					currentVideoPosition = 0;
				}
				
				// check seek and position.  If false or zero, then just play
				seconds = currentVideoPosition;
			}
			//OutputTools.tt(["playVideo", currentVideoPath, currentFLVReference, seconds, seek])

			ec.playVideo(currentVideoPath, currentFLVReference, seconds);
		}
		
		public static function pauseVideo():void
		{
			ec.pauseVideo(currentVideoPath); 
		}
		
		public static function stopVideo():void
		{
			ec.stopVideo(currentVideoPath);
		}
		
		public static function toolChange(event:Event):void
		{			
			if(app.treeviewStack.selectedIndex != 4) stopPropertyPoll();
			if(app.treeviewStack.selectedIndex == 4)
			{
				if(currentVideoPath == "") 
				{
					Alert.show("To use the video panel, you need to select a NetStream object from the Property Inspector or treeview", "NetStream Object Needed", (Alert.OK), null, null, null, Alert.OK);
					return;
				}else
				{
					startPropertyPoll();
				}
			} 
		}
		
		private static function startPropertyPoll():void
		{
			clearInterval(getSI);
			getSI = setInterval(VideoTools.getUpdatedProperties, 250);
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
		
		private static function getVideoName(videoPath:String):String
		{
			var ary:Array = videoPath.split(".");
			return ary.pop();
		}
	}
}