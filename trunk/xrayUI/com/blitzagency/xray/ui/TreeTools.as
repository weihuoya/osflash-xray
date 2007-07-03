package com.blitzagency.xray.ui
{
	import com.blitzagency.xray.events.TreeToolsEvent;
	
	import flash.events.EventDispatcher;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.core.Application;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	
	public class TreeTools extends EventDispatcher
	{
		public static var app:Object = mx.core.Application.application;
		public static var ec:ExecuteConnection;
		public static var currentSelectedObject:String;
		public static var currentSelectedType:Number;
		public static var instance:TreeTools;
		public static var initialized:Boolean = initialize();
		private static var currentRollOverIndex:Number = -1;
		private static var currentHighlightedClip:String;
		
		public static function registerEC(p_ec:ExecuteConnection):void
		{
			ec = p_ec;
		}
		
		private static function initialize():Boolean
		{
			instance = new TreeTools();
			return true;
		}
		
		public static function open(evtObj:TreeEvent):void
		{
			//OutputTools.tt(["TreeView.open", evtObj]);
			//clickHandler(evtObj);
		}
		
		public static function rollOverHandler(evtObj:ListEvent):void
		{
			if(evtObj.rowIndex == currentRollOverIndex) return;
			
			//OutputTools.tt(["TreeTools.rollOverHandler", evtObj.itemRenderer.data.@t, evtObj.itemRenderer.data.@mc])
			var type:Number = evtObj.itemRenderer.data.@t;
			var path:String = evtObj.itemRenderer.data.@mc
			if((type == 2 || type == 3 || type == 5))
			{
				var activeHighlight:Boolean = true; //_level0.SO.getPreference("activeHighlight");
				if(activeHighlight)
				{
					ec.highlightClip(path, type);
				}else
				{
					ec.lowlightClip(path, type);
				}
			}
			
			// this commented block is for highlighting a clip for moving around
			/*
			if(evtObj.itemRenderer.data.@mc != currentHighlightedClip)
			{
				// if this is a new node, then go ahead and clear the already highlighted node.
				// if this was a click on the SAME node, we'll let the connector turn the highlights on and off
				evtObj.itemRenderer.data.@mc == currentHighlightedClip
				ec.stopExamineClips(currentHighlightedClip, _level0.iType);
			}
			*/
		}
		
		public static function close(evtObj:Object):void
		{
			//OutputTools.tt(["TreeView.close", evtObj]);
		}
		
		public static function clickHandler(evtObj:Object):void
		{
			
        	var selectedNode:Object = app.treeView.selectedItem;
        	
        	if(selectedNode == null) return;
        	
        	// change over to the propertyInspector
			app.propertiesViewStack.selectedIndex = 1;

        	var type:Number = Number(selectedNode.attribute("t"));
        	var path:String = selectedNode.attribute("mc");
        	
			//OutputTools.tt(["type", type]);
			//OutputTools.tt(["path", path]);
			
        	// for quick reference to currently selected data in treeview
        	currentSelectedObject = path;
        	currentSelectedType = type;
        	
        	//OutputTools.tt(["TreeTools.clickHandler", path, type, evtObj])
        	
        	if(type == 0 || type == 2 || type == 1)
        	{        	
        		ec.currentNode = selectedNode;
        		ec.viewTree(path);
        	}

        	getProperties(path, type);     
        	
        	var evt:TreeToolsEvent = new TreeToolsEvent(TreeToolsEvent.TREEVIEW_CLICK, path, type);
			//OutputTools.tt(["dispatch axisEdit", evt]);
   			instance.dispatchEvent(evt);
		}
		
		public static function getProperties(path:String, type:Number):void
		{
        	if(type == 2 || 
			   type == 3 || 
			   type == 5 || 
			   type == 0 || 
			   type == 1 ||
			   type == 7 || 
			   type == 6 ||
			   type == 12) 
			{
				ec.stopExamineClip();
				
				if(type == 2 || type == 3 || type == 5)
				{
					ec.getMovieClipProperties(path, type, true);
					//var activeHighlight:Boolean = _level0.SO.getPreference("activeHighlight");
					//if(activeHighlight) 
					if(path != "_level0" && app.shiftKeyDown) ec.startExamineClip(path, type);
				}
				
				if(type == 0 || type == 6 || type == 1 || type == 12)
				{
					var obj:String = path.substr(0, path.lastIndexOf("."));
					var key:String = path.substr(path.lastIndexOf(".")+1, path.length);
					ec.getObjProperties(obj, key, type);
				}
				
				if( type == 7)
				{
					ec.getFunctionProperties(path, type);
				}
			}else
			{
				if(type == 4) // sound
				{
					// switch to the sound controls
					app.treeviewStack.selectedIndex = 3;
					
					// call for sound props
					SoundTools.getSoundProperties(path);
					if(path != "")
					{
						ec.getMovieClipProperties(path, type, true);
					}
				}else if(type == 8) // NetStream
				{
					// switch to the sound controls
					app.treeviewStack.selectedIndex = 4;
					
					// call for video props
					VideoTools.getVideoProperties(path);
					if(path != "")
					{
						ec.getMovieClipProperties(path, type, true);
					}
				}
			}
		}
	}
}