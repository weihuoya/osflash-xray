package com.blitzagency.xray.ui
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
    
	public class MP3PlayBack extends Sprite 
	{
        private static var song:SoundChannel;
        private static var request:URLRequest;;
        private static var initialized:Boolean = init();
        private static var soundFactory:Sound;

        public static function init():Boolean
        {
            soundFactory = new Sound();
            soundFactory.addEventListener(Event.COMPLETE, completeHandler);
            soundFactory.addEventListener(Event.ID3, id3Handler);
            soundFactory.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            soundFactory.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            return true;
        }
        
        public static function loadSound(soundURL:String):void
        {
        	request = new URLRequest(soundURL);
        	soundFactory.load(request);
            song = soundFactory.play();
        }
        
        public static function unloadSound():void
        {
        	song.stop();
        	soundFactory.close();
        }

        private static function completeHandler(event:Event):void {
            OutputTools.tt(["completeHandler", event]);
        }

        private static function id3Handler(event:Event):void {
            OutputTools.tt(["id3Handler", event]);
        }

        private static function ioErrorHandler(event:Event):void {
            OutputTools.tt(["ioErrorHandler", event]);
        }

        private static function progressHandler(event:ProgressEvent):void {
            //OutputTools.tt(["progressHandler",event]);
        }

    }
}