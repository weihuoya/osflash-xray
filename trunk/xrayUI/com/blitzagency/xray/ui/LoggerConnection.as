package com.blitzagency.xray.ui
{
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.net.ObjectEncoding;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	
    public class LoggerConnection 
    {
    	public var app:Object = mx.core.Application.application;
    	public var defaultObjectEncoding:Number;
    	public var traceQue:Array = [];
    	private var lc:LocalConnection;    	
    	private var connectionName:String = "_xray_view_conn";
    	private var connected:Boolean = false;
    	
        public function LoggerConnection()
        {
        	lc = new LocalConnection();
        	lc.addEventListener("status", statusHandler);
        	lc.client = this;
			lc.allowDomain("*");
			//defaultObjectEncoding = ObjectEncoding.AMF0;
        }
        
        public function statusHandler(event:StatusEvent):void
		{
			//OutputTools.tt(["lc.status", event, event.code, event.level])
			if(event.code == null && event.level == "error" && connected) 
			{
				app.status.text = "No swf is available to connect with.";
				connected = false;
				Alert.show("No swf is available to connect with.", "Connection Error", (Alert.OK), null, connectedClickHandler, null, Alert.OK);
			}else
			{
				if(event.level == "status" && event.code == null)
				{
					connected = true;
				}
				app.status.text = "";
			}
		}
		
		private function connectedClickHandler(event:CloseEvent):void
		{
			//connected = true;
		}
        
        public function initConnection():void
        {
        	try 
            {
                lc.connect(connectionName);
                connected = true;
            	OutputTools.tt(["Logger Connection Established"]);            	
            } 
            catch (error:ArgumentError) 
            {
				Alert.show("Logger connection already in use.  If you want to retry the connection, close the other version of Xray that is running and click 'YES'.\n\n Otherwise, just click 'CANCEL'", "Connection Error", (Alert.YES | Alert.CANCEL), null, alertClickHandler, null, Alert.OK);
                OutputTools.tt(["Logger Connection Name in use"]);
            }	
        }
        
        private function alertClickHandler(event:CloseEvent):void
        {
            if (event.detail==Alert.YES)
            {
            	initConnection();
            }else
            {
            	// clear it
        	}
        }
        
        public function getTraceValue(traceValue:String):void
		{
			/*
			NOTES:
				reset the array for the return trip
			*/
			traceQue = [];
			//OutputTools.tt(["getTraceValue", traceValue]);
			lc.send("_xray_view_remote_conn", "getTraceValue", traceValue);
		}
		
		/* New for the new logger */
		public function setTrace(message:String, level:Number=0, classPackage:String=""):void
        {
			//_level0.AdminTool.trace(0);
			/*
			* when we receive leve and classPackage, we'll use that for storing in various array's for filtering
			*/
			//OutputTools.tt(["setViewInfo",message, typeof(lastOfBatch)])
			OutputTools.tt([message],level);
        }
        
        public function setViewInfo(message:String, lastOfBatch:Boolean):void
        {
			//_level0.AdminTool.trace(0);
			/*Error #2044: Unhandled ErrorEvent:. 
				text=Error #2095: com.blitzagency.xray.ui.LoggerConnection was unable to invoke callback 'setViewInfo' due to exception 
				'TypeError: Error #1009: Cannot access a property or method of a null object reference.'
			*/
			//OutputTools.tt(["setViewInfo",message, typeof(lastOfBatch)])
			traceQue.push(message);
			if(lastOfBatch)
			{
				//OutputTools.tt([0, traceQue.toString()])
				var str:String = traceQue.join('');

				OutputTools.tt([str]);
				traceQue = [];
			}
        }
    }
}