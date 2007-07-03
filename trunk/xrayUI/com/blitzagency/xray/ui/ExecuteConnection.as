package com.blitzagency.xray.ui
{
	import com.blitzagency.util.LSOUserPreferences;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.media.Video;
	import flash.net.*;
	import flash.utils.setTimeout;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.controls.Alert;
	import mx.controls.Tree;
	import mx.core.Application;
	import mx.effects.easing.Back;
	import mx.events.CloseEvent;
	
	public class ExecuteConnection
	{
		// public properties
		public var app:Object = mx.core.Application.application;
		public var currentNode:Object;
		
		// private properties
		private var lc:LocalConnection;	
		private var que:Array;
		private var propertiesQue:Array;
		private var tree:Tree;
		private var currentPath:String;
		private var currentType:Number;
		private var xt:XrayTrace;
		private var pf:PropertyFactory;
		private var connectionName:String = "_xray_conn";
		private var latestRemoteCall:String = "";
		private var connected:Boolean = false;
		
		public function ExecuteConnection()
		{
			tree = app.treeView;
			xt = new XrayTrace();
			
			lc = new LocalConnection();
            lc.addEventListener("status", statusHandler);
            lc.client = this;
            lc.allowDomain("*");
            pf = new PropertyFactory();
		}
		
		public function statusHandler(event:StatusEvent):void
		{
			//OutputTools.tt(["ec.status", event.code, event.level, connected])
			if(event.code == null && event.level == "error" && connected) 
			{
				app.status.text = "No swf is available to connect with.";
				connected = false;
				tree.dataProvider = new XMLList;
				Alert.show("No swf is available to connect with.", "Connection Error", (Alert.OK), null, connectedClickHandler, null, Alert.OK);
			}else
			{
				if(event.level == "status" && event.code == null)
				{
					app.status.text = "";
					connected = true;
				}
			}
		}
		
		private function connectedClickHandler(event:CloseEvent):void
		{
			//connected = true;
		}
		
		public function getConnectorVersion():void
		{
			//latestRemoteCall = "getConnectorVersion";
			try 
	        {
	           lc.send("_xray_remote_conn", "getConnectorVersion");
	        } 
	        catch (error:Error) 
	        {
	        	OutputTools.tt(["Error in getting Connector version", error]);
	        }			
		}
		
		public function setVersion(version:String):void
		{
			var localVersion:Number = Number(app.currentConnectorVersion.split(".").join(""));
			var remoteVersion:Number = Number(version.split(".").join(""));
			if(localVersion > remoteVersion)
			{
				Alert.show("The connector version in the host SWF (" + version + ") is not the latest connector (" + app.currentConnectorVersion + ").\n\nClick 'YES' to get the latest connector.\nClick 'CANCEL' to continue anyway", "Connector Version", (Alert.YES|Alert.CANCEL), null, alertConnectorUpgrade, null, Alert.OK);
			}else if(localVersion < remoteVersion)
			{
				Alert.show("The connector version in the host SWF (" + version + ") is newer than what this interface is expecting (" + app.currentConnectorVersion + ").\n\nClick Please clear your cache and reload Xray or download the latest interface.", "Interface Version", (Alert.OK), null, null, null, Alert.OK);
			}
			OutputTools.tt(["Connector Version", version]);
		}
		
		public function alertConnectorUpgrade(event:CloseEvent):void
		{
			if (event.detail==Alert.YES)
            {
            	var u:URLRequest = new URLRequest("http://www.osflash.org/xray#downloads");
				navigateToURL(u, "_blank");
            }else
            {
            	// clear it
        	}
		}
		
		public function viewTree(p_path:String):void
		{
			currentPath = p_path;
			que = [];
			lc.send("_xray_remote_conn", "viewTreeF2", p_path, false, false, false);
		}
		
		public function setTree(obj:Object, lastOfBatch:Boolean):void
		{		
			if(obj.XMLDoc.length == 0) return;
			
			que.push(obj.XMLDoc);
			
			if(lastOfBatch)
			{
				var xmlStr:String = "";
				xmlStr = que.join('');
				
				var XMLDoc:XMLList = new XMLList(xmlStr);
				var x4:XML = new XML(xmlStr);
				
				// if the chosen path is the same as the combobox, then this should be placed in the root
				if(currentPath == app.startingPath.value)
				{
					app.treeData = XMLDoc;
					tree.expandItem(XMLDoc.children().parent(), true);
				}
				else
				{					
					var parentXML:Object = tree.selectedItem;
					parentXML.setChildren(x4.children());
					tree.expandItem(tree.selectedItem, true, false);
				}
				que = [];
				
				tree.invalidateList();
			}
		}
		
		public function updateOpenNode(rootSelection:Boolean):void
		{
			var node:DisplayObject = tree.getChildAt(1);
			tree.selectedIndex = 0
			//OutputTools.tt(["open?", node])
			//if (!tree.isItemOpen(node)){
		      //tree.expandItem(node,true, false,false,null);
  		      tree.expandChildrenOf(tree.selectedItem,true);
		   // }
		}
		
		public function executeScript(execute:String):void
		{
			lc.send("_xray_remote_conn", "executeScript", execute);
		
			// record in history
			/*
			aTemp = sExecute.split(".");
			aTemp.splice(0,1);
			sExecute = aTemp.join(".");
			*/
		
			//var key:String = (sExecute);
			//_level0.updateHistory(key, sExecute);
		}
		
		public function getMovieClipProperties(p_target:String, p_type:Number, extendedInfo:Boolean):void
		{
			propertiesQue = []
			currentType = p_type;
			currentPath = p_target;
			//OutputTools.tt(["getMovieClipProperties", currentPath, p_target, extendedInfo])
			lc.send("_xray_remote_conn", "getMovieClipPropertiesF2", p_target, extendedInfo);
		}
		
		public function getObjProperties(obj:String, key:String, p_type:Number):void
		{
			propertiesQue = [];
			currentPath = obj + "." + key;
			currentType = p_type;
			lc.send("_xray_remote_conn", "getObjPropertiesF2", obj, key);
		}
		
		public function getFunctionProperties(obj:String, p_type:Number):void
		{
			currentType = p_type;
			propertiesQue = []
			lc.send("_xray_remote_conn", "getFunctionPropertiesF2", obj);
		}
		
		public function setObjectProperties(obj:Object, lastOfBatch:Boolean):void
		{
			if(obj.XMLDoc.length == 0 || obj == null) return;

			propertiesQue.push(obj.XMLDoc);

			if(lastOfBatch)
			{
				var xmlStr:String = "";

				xmlStr = propertiesQue.join('');
				
				updatePropertyInspector(xmlStr);

				propertiesQue = []
			}
		}
		
		private function updatePropertyInspector(xmlStr:String):void
		{
			var tempXMLDoc:XML = new XML(xmlStr);
			
			var properties:XMLList = tempXMLDoc.children();				
			
			var extProperties:XMLList = tempXMLDoc._props.children();

			//OutputTools.tt(["*********setObjectProperties", extProperties.length(), currentPath])
			app.currentState ='';
			
			pf.updatePropertyInspector(properties, extProperties, currentPath, currentType);
		}
		
		public function setMetaData(metaData:Object):void
		{
			if(metaData != null ) VideoTools.setMetaData(metaData);
		}
		
		public function setProperty(path:String, _prop:String, value:String, type:String):void
		{
			//OutputTools.tt(["setProperty", path, _prop, value, type, isNaN(parseInt(value)), parseInt(value)]);
		
			// find out if we have an integer being pass for the value
			if(!type)
			{
				value = isNaN(parseInt(value)) ? "'" + value + "'" : value;
			}else
			{
				value = value == "String" ? "'" + value + "'" : value;
			}
		
			var ary:Array = path.split(".");
			ary.pop(); // strip the property off of the path
			
			var str:String = ary[0];
			for(var x:Number=1;x<ary.length;x++)
			{
				str += "[\"" + String(ary[x]) + "\"]";
			}
			path = str;
		
			// find out if there's a specific setter function for the prop change
			var execute:String = "";
			if(_prop == "_currentframe" || _prop == "depth")
			{
				var gotoCommand:String = app.gotoAndStop.selected ? "gotoAndStop" : "gotoAndPlay";
				var propSetter:String = _prop == "_currentframe" ? gotoCommand : "swapDepths";
				execute = path + "." + propSetter + "(" + value + ")";
			}else
			{
				execute = path + "." + _prop + " = " + value;
			}
			
			try 
	        {
	        	//OutputTools.tt(["drawGridLine", path, prop, value, lineColor]);
	            lc.send("_xray_remote_conn", "executeScript", execute);
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in setting property", error]);
	        	return;
	        }
			
			
		
			/*
			NOTES:
				Next, we need to update the changes object with the current settings
				We take off the level designation incase the user is only testing a section of a larger app
			*/
		
			//var key:String = sTarget_mc + "." + _prop;
			//_level0.AdminTool.trace("updateHistory from setProperty", key, sExecute);
			//_level0.updateHistory(key, sExecute);
		}
		
		// legacy for 1.4.5 and below connectors
		public function showMovieClipProperties(obj:Object):void
		{
			//OutputTools.tt(["showMovieClipProperties", obj]);
			// all objects with the old connector were coming across on showMovieClipProperties
			pf.updatePropertyInspectorLegacyData(obj, currentPath, currentType);
		}
		
		public function highlightClip(path:String, type:Number):void
		{
			if(!app.showActiveHighlighting.selected) return;
			lc.send("_xray_remote_conn", "highlightClip", path, type);
		}
		
		/******************
		*
		* lowlightClip - removes the yellow bounding box*
		*
		* */
		public function lowlightClip(path:String, type:Number):void
		{
			lc.send("_xray_remote_conn", "lowlightClip", path, type);
		}
		
		public function setLogLevel(p_level:Number):void
		{
			try 
	        {
	        	//OutputTools.tt(["drawGridLine", path, prop, value, lineColor]);
	            lc.send("_xray_remote_conn", "setLogLevel", p_level);
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in setting log level", error]);
	        	return;
	        }
		}
		
		public function getLogLevel():void
		{
			setLogLevel(app.logLevel);
		}
		
		public function drawGridLine(path:String, prop:String, value:Number, lineColor:Number=0x000000):void
		{
			try 
	        {
	        	//OutputTools.tt(["drawGridLine", path, prop, value, lineColor]);
	            lc.send("_xray_remote_conn", "drawGridLine", path, prop, value, lineColor);
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in drawing grid line", error]);
	        	return;
	        }
		}
		
		public function removeLastGridLine():void
		{
			try 
	        {
	            lc.send("_xray_remote_conn", "removeLastGridLine");
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in removing grid line", error]);
	        	return;
	        }
		}
		
		public function clearObjectGridLines(path:String):void
		{
			//OutputTools.tt(["ec.clearObjectGridLines", path])
			try 
	        {
	            lc.send("_xray_remote_conn", "clearObjectGridLines", path);
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in clearing object lines", error]);
	        	return;
	        }
		}
		
		public function clearAllGridLines():void
		{
			try 
	        {
	            lc.send("_xray_remote_conn", "clearAllGridLines");
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in clearing lines", error]);
	        	return;
	        }
		}
		
		public function startExamineClip(path:String, type:Number):void
		{
			//OutputTools.tt(["startExamineClip", path, type]);
			try 
	        {
	            lc.send("_xray_remote_conn", "startExamineClipF2", path, type);
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in starting exam", error]);
	        	return;
	        }
		}
		
		public function stopExamineClip():void
		{
			try 
	        {
	            lc.send("_xray_remote_conn", "stopExamineClipF2");
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in stop exam", error]);
	        	return;
	        }			
		}
		
		/**************
		*
		* Deal with the FPS meeter in the Xray connector
		*
		* */
		public function viewFPS(fps:String):void
		{
			app.fpsMeter.text = fps;
		}
		public function showFPS():void
		{
			try 
	        {
	            lc.send("_xray_remote_conn", "showFPS");
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in sending SHowFPS", error]);
	        	return;
	        }			
		}
		public function hideFPS():void
		{
			try 
	        {
	            lc.send("_xray_remote_conn", "hideFPS");
	            app.fpsMeter.text = "";
	        } 
	        catch (error:ArgumentError) 
	        {
	        	OutputTools.tt(["Error in sending hideFPS", error]);
	        }	
		}
		public function checkFPSOn():void
		{
			var showFPS:Boolean = LSOUserPreferences.getPreference("showFPS");
			try
			{
				lc.send("_xray_remote_conn", "fpsOn", showFPS);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in sending CheckFPSOn", error]);
			}
		}
		
		public function setFilter(path:String, filter:Object, filterType:String):void
		{
			try
			{
				lc.send("_xray_remote_conn", "setFilter", path, filter, filterType);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in sending Filter", error]);
			}
			
		}
		
		public function getVideoProperties(videoPath:String):void
		{
			// set for updating the property inspector
			currentPath = videoPath;
			currentType = 8;
			
			try
			{
				lc.send("_xray_remote_conn", "getObjPropertiesF2", videoPath);
				//lc.send("_xray_remote_conn", "getVideoProperties", videoPath);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in getting video Properties", error]);
			}
		}
		
		public function setVideoProperties(obj:Object):void
		{
			// this is not hooked up right now.  Instead, we're using the getObjPropertiesF2 call
			VideoTools.setVideoProperties(obj);
		}
		
		public function playVideo(videoPath:String, flv:String, seek:Number):void
		{
			// set global FLV variable for later use if we tab away and come back
			//_level0.lastFLV = flv;
			try
			{
				lc.send("_xray_remote_conn", "playVideoF2", videoPath, flv, seek);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in playing video", error]);
			}			
		}
		
		public function pauseVideo(videoPath:String):void
		{
			try
			{
				lc.send("_xray_remote_conn", "pauseVideo", videoPath);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in pausing video", error]);
			}
		}
		
		public function stopVideo(videoPath:String):void
		{
			try
			{
				lc.send("_xray_remote_conn", "stopVideo", videoPath);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in stopping video", error]);
			}			
		}
		
		public function getSoundProperties(soundPath:String):void
		{
			try
			{
				lc.send("_xray_remote_conn", "getSoundProperties", soundPath);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in getting Sound Properties", error]);
			}
		}
		
		public function setSoundProperties(obj:Object):void
		{
			SoundTools.setSoundProperties(obj);
		}
		
		public function playSound(soundPath:String, position:Number, loopCount:Number):void
		{
			try
			{
				lc.send("_xray_remote_conn", "playSoundF2", soundPath, position, loopCount);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in playing sound", error]);
			}			
		}
		
		public function stopSound(soundPath:String):void
		{
			try
			{
				lc.send("_xray_remote_conn", "stopSound", soundPath);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in playing sound", error]);
			}
		}
		
		public function setSoundProperty(soundPath:String, property:String, value:Number):void
		{
			try
			{
				lc.send("_xray_remote_conn", "setSoundPropertyF2", soundPath, property, value);
			}
			catch(error:ArgumentError)
			{
				OutputTools.tt(["Error in setting sound values", error]);
			}
		}
		
		public function initConnection():void
		{
			try 
	        {
	            lc.connect(connectionName);
	            connected = true;
	        	OutputTools.tt(["Execute Connection Established"]);            	
	        } 
	        catch (error:ArgumentError) 
	        {
	        	Alert.show("Execute connection already in use.  If you want to retry the connection, close the other version of Xray that is running and click 'YES'.\n\n Otherwise, just click 'CANCEL'", "Connection Error", (Alert.YES|Alert.CANCEL), null, alertClickHandler, null, Alert.OK);
	        	OutputTools.tt(["Execute Connection Name in use"]);
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
	}
}