import com.blitzagency.events.GDispatcher;
import com.xfactorstudio.xml.xpath.*;
class com.blitzagency.xray.ui.ExecConnections extends LocalConnection
{
	var addEventListener:Function;
	var removeEventListener:Function;
	var dispatchEvent:Function;

	function ExecConnections()
	{
		// initialize event dispatcher
		GDispatcher.initialize(this);

		init();
	}

	public function init():Void
	{
		var connected:Boolean = this.initConnections();
		
		/*Originally, this fired off when I didn't have a dropdown for the path to start at*/
		//this.getObjProperties("_level0");
		
		_global.tt("ExecConnections initialized", connected)
	}

	/**************
	*
	* Deal with the FPS meeter in the Xray connector
	*
	* */
	public function viewFPS(fps:String)
	{
		_level0.main_mc.fps.text = fps;
	}
	public function showFPS()
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "showFPS");
		_global.tt("showFPS?", bSent);
	}
	public function hideFPS()
	{
		_level0.main_mc.fps.text = "";
		var bSent:Boolean = this.send("_xray_remote_conn", "hideFPS");
	}
	public function checkFPSOn()
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "fpsOn", _level0.showFPS);
	}
	
	/******************
	*
	* View tree 4 parms:
	*
	* @sInitView = string path to the movieclip or oject.  This is the starting point for the recursion.  Typically, it's what you see in the drop down box
	* @resursiveSearches:Boolean - false = active treeview mode, true = recurse the application in one snapshot
	* @showHidden:Boolean - true turns on the use of ASSetPropFlags in your application, which can cause longer snapshots, and usually isn't necessary
	* @objectSearch:Boolean - true allows snapshots to recurse objects.  Right now, objects/array's are simply listed in the timelines they live.  Setting to true will allow
	* them to be recursed for the treeview.  Currently, i've not included this option in the interface so, it defaults to false right now.*
	*
	* */
	
	// calls the local connector and initializes the tree view
	public function viewTree(sInitView)
	{
		_level0.que = null;
		_level0.que = new Array();
		var bSent:Boolean = this.send("_xray_remote_conn", "viewTree", sInitView, _level0.recursiveSearches, _level0.showHidden, _level0.objectSearch);
		//_level0.AdminTool.trace("viewTree called", bSent, sInitView);
	}
	
	/****************
	*
	* setTree recieves the snapshot XML
	*
	* this is a sample of what's returned:
	* <_level0 label="_level0 (MovieClip)" mc="_level0" t="2"><onLoad label="onLoad( Function )" mc="_level0.onLoad" t="7" /></_level0>
	*
	* if you want to view the treeview XML after a snapshot, use this in the execute panel of Xray:
	* _global.tt("XML", _global.com.blitzagency.xray.Xray.lc_exec.objViewer.XMLDoc.toString());
	*
	* Basically, since LocalConnection has a limit on the amount of data it can send, it comes over in string chunks that you assemble.  If bLast is true,
	* then you set the dataprovider of your treeview.
	*
	*
	* */
	
	// I use xPath for setTree to find the node id when NOT doing recursiveSearches
	
	public function setTree(obj:Object, ary:Array, bLast:Boolean)
	{
		/*
		NOTES:
			@obj: obj.XMLDoc is the treeview data in string format
			@ary: array of levels containing content
		*/
		//_level0.AdminTool.trace("setTree called", obj.XMLDoc.length, _level0.que.length);
	
		if(obj.XMLDoc.length == 0) return;
	
		var tree = _global.treeView.treeView_cmp;
	
		_level0.que.push(obj.XMLDoc);
		if(bLast)
		{
			var sXMLDoc:String = "";
			sXMLDoc = _level0.que.join('');
	
	
			/*
			NOTES:
				when the treeview data comes back, we have to check to see if recursiveSearches is true/fals
				if false
					we set the new data to the viewable id in the existing tree
				if true
					we reset the treeview's dataprovider
			*/
	
	
			if(_level0.recursiveSearches)
			{
				XMLDoc = new XML(sXMLDoc);
				_global.treeView.treeView_cmp.dataProvider = XMLDoc;
			}else
			{
				XMLDoc = new XML(sXMLDoc);
				XMLChild = new XMLNode()
				XMLChild = XMLDoc.firstChild;
	
				/*
				var pathTemp = _level0.sCurrentTarget.split(".");
				var clearPath = "";
	
				for(var x:Number=0;x<pathTemp.length;x++)
				{
					clearPath +=
				}
				*/
	
				var pathTemp = _level0.sCurrentTarget.split(".")
				var clearPath = escape(pathTemp.join("/"));
	
	
				//var aNodes = XPath.selectNodes(_global.treeView.treeView_cmp.dataProvider,"/"+_level0.sCurrentTarget.split(".").join("/"));
				var aNodes = XPath.selectNodes(tree.dataProvider,"/"+clearPath);
				//_level0.AdminTool.trace("setTree called", aNodes.length, _level0.recursiveSearches, _level0.viewableTreeID, _level0.sCurrentTarget.split(".").join("/"), aNodes[0].toString());
	
				if(aNodes.length == 0)
				{
					var node:XMLNode = tree.addTreeNode(XMLChild);
					tree.setIsOpen(tree.getNodeDisplayedAt(0), true);
				}else
				{
					//aNodes[0] = XMLChild;
					var parentXML = tree.getNodeDisplayedAt(_level0.viewableTreeID).parentNode;
	
					var index:Number;
					for(var x:Number=0;x<parentXML.childNodes.length;x++)
					{
						//_level0.AdminTool.trace("loop", parentXML.childNodes[x].nodeName, XMLChild.nodeName);
						//if(parentXML.childNodes[x].attributes["label"] == XMLChild.attributes["label"])
						if(parentXML.childNodes[x].attributes["label"] == XMLChild.attributes["label"])
						{
							index = x;
							break;
						}
					}
	
					var removeXML = tree.getNodeDisplayedAt(_level0.viewableTreeID).removeTreeNode();
	
					//_level0.AdminTool.trace("parentXML", index);
	
					parentXML.addTreeNodeAt(index, XMLChild);
					tree.setIsOpen(tree.getNodeDisplayedAt(_level0.viewableTreeID), true);
				}
	
				//_global.treeView.treeView_cmp.addTreeNodeAt(_level0.viewableTreeID, node);
			}
	
			//_level0.AdminTool.trace(XMLDoc.toString())
			_level0.que = null;
			_level0.que = new Array();
		}
	
		initLevels(ary);
	}
	
	/***************
	*
	* getMovieClipProperties requests properties for the object sent through.
	*
	* @sTarget_mc:String - full path in string format to the object
	* @bExtendedInfo:Boolean - if true, ASSetPropFlags is used on the object to return all props/methods.  this is defaulted to true in the current interface
	*
	* */
	public function getMovieClipProperties(sTarget_mc, bExtendedInfo)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getMovieClipProperties", sTarget_mc, bExtendedInfo);
		//_level0.AdminTool.trace("getMovieClipProperties called", bSent, sTarget_mc);
	}
	
	/***************
	*
	* getTipMovieClipProperties requests tooltip properties for the object sent through.
	*
	* @sTarget_mc:String - full path in string format to the object
	*
	* */
	
	public function getTipMovieClipProperties(sTarget_mc)
	{
		if(_global.bConnected) var bSent:Boolean = this.send("_xray_remote_conn", "getTipMovieClipProperties", sTarget_mc, false);
		//_level0.AdminTool.trace("getMovieClipProperties called", bSent, sTarget_mc);
	}
	
	/***************
	*
	* showTipMovieClipProperties receives the tooltip properties and sets the tooltip.
	*
	* @obj:Object - contains all the properties for a tooltip
	*
	* NOTE: Xray will check for type of MovieClip, button or textfield and return properties based on which ever was detected.
	* A button or textfield's property list is much shorter than the one for the Movieclip ;)
	*
	* */
	
	public function showTipMovieClipProperties(obj:Object)
	{
		//_level0.AdminTool.trace("Tip Properties", obj._props);
		var str:String = "";
		for(var items:String in obj._props)
		{
			str += items + " : " + obj._props[items] + "\n";
		}
		Tooltip.show(str);
	}
	
	/****************
	*
	* getObjProperties = same idea as getMovieClipProperties, but more generic.  If Xray interface sees something as an object (not a movieclip, sound, NetStream, button or textfiled) it calls
	* this method for a list of props/methods
	*
	* */
	
	public function getBaseProperties(sObj, key)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getBaseProperties", sObj, key);
		//_global.tt("localConn getObjProperties called", sObj, key);
	}
	
	public function showBaseProperties(obj:Object)
	{
		_global.tt("BaseProperties", obj);
		//_global.controlPanel.setProps(obj);
		//_global.propertyInspector.setProps(obj);
		var mc:MovieClip = _level0.main.addPane(obj);
		//mc.setProps(obj);
		current_mc_obj = obj;
	}
	
	/*
	public function getValue(sObj, _prop)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getValue", sObj, _prop);
		//_level0.AdminTool.trace("getValue called", sObj);
	}
	
	public function getObjType(sObj)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getObjType", sObj);
		//_level0.AdminTool.trace("getObjProperties called", sObj);
	}
	*/
	public function getFunctionProperties(sObj)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getFunctionProperties", sObj);
		//_level0.AdminTool.trace("getFunctionProperties called", sObj);
	}
	
	/*****************
	*
	* receives the movieclip properties and sends them to the PI.setProps method.  Esentially, the property inspector is a datagrid and it handles
	* the click events for objects in the PI.  So when you click on an object in the PI and it drills down to the properties of THAT object, PI determines type of
	* object and makes the proper "get" call*
	*
	* */
	
	public function showMovieClipProperties(obj:Object)
	{
		_global.tt("Movie clip Properties", obj, _global.propertyInspector, _global.propertyInspector.setProps);
		//_global.controlPanel.setProps(obj);
		//_global.propertyInspector.setProps(obj);
		var mc:MovieClip = _level0.main.addPane(obj);
		//mc.setProps(obj);
		current_mc_obj = obj;
	}
	
	/*****************
	*
	* sends the changesObj to the connector.  Not sure why or when I've used this.  But it works.
	*
	* */
	public function sendChangeHistory()
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "writeChangeHistory", _level0.changesObj);
	}
	
	/*****************
	*
	* executeScript - It sends actionscript commands as strings to Xray's Commander.  When a user types in a command in the execute panel, it's sent through here
	*
	* IE:
	*
	* _level0.mc.gotoAndStop("off");
	* _level0.mc._xscale = 150;
	* _global.tt("XML", _global.com.blitzagency.xray.Xray.lc_exec.objViewer.XMLDoc.toString());
	*
	* */
	public function executeScript(sExecute)
	{
		//_level0.AdminTool.trace("execute", sExecute);
		var bSent:Boolean = this.send("_xray_remote_conn", "executeScript", sExecute);
	
		// record in history
		/*
		aTemp = sExecute.split(".");
		aTemp.splice(0,1);
		sExecute = aTemp.join(".");
		*/
	
		var key:String = (sExecute);
		//_level0.AdminTool.trace("updateHistory from executeScript", key, sExecute);
		_level0.updateHistory(key, sExecute);
	}
	
	/****************
	*
	* setProperty - probably the single most important call next to viewTree.  It sends actionscript commands as strings to Xray's Commander.  This is
	* where you can change an objects properties via the PI (IE: _rotation, _visible, _x, gotoAndStop/Play frames, execute code panel etc)
	*
	* IE:
	*
	* _level0.mc.gotoAndStop("off");
	* _level0.mc._xscale = 150;
	* _global.tt("XML", _global.com.blitzagency.xray.Xray.lc_exec.objViewer.XMLDoc.toString());
	*
	* */
	public function setProperty(sTarget_mc:String, _prop:String, sValue:String, sValueType:String, sPropSetter:String)
	{
		_global.tt("setProperty", arguments);
		// clear global interval
		clearInterval(_level0.setPropSI);
	
		// find out if we have an integer being pass for the value
		if(!sValueType)
		{
			sValue = isNaN(parseInt(sValue)) ? "'" + sValue + "'" : sValue;
		}else
		{
			sValue = sValueType == "String" ? "'" + sValue + "'" : sValue;
		}
	
		var sTemp:Array = sTarget_mc.split(".");
		//_global.AdminTool.trace("sTemp in connector", sTemp.toString(), key);
		var sObj:String = sTemp[0];
		for(var x:Number=1;x<sTemp.length;x++)
		{
			sObj += "[\"" + String(sTemp[x]) + "\"]";
		}
		sTarget_mc = sObj;
	
		// find out if there's a specific setter function for the prop change
		if(sPropSetter)
		{
			var sExecute:String = sTarget_mc + "." + sPropSetter + "(" + sValue + ")";
		}else
		{
			var sExecute:String = sTarget_mc + "." + _prop + " = " + sValue;
		}
		//_level0.AdminTool.trace(sExecute, sTarget_mc);
		var bSent:Boolean = this.send("_xray_remote_conn", "executeScript", sExecute);
	
		/*
		NOTES:
			Next, we need to update the changes object with the current settings
			We take off the level designation incase the user is only testing a section of a larger app
		*/
		/*
		var aTemp:Array = sTarget_mc.split(".");
		aTemp.splice(0,1);
		sTarget_mc = aTemp.join(".");
		_level0.AdminTool.trace("splitting sTarget_mc", aTemp, sExecute);
	
		aTemp = sExecute.split(".");
		aTemp.splice(0,1);
		sExecute = aTemp.join(".");
		_level0.AdminTool.trace("splitting sExecute", aTemp, sExecute);
		*/
	
		var key:String = sTarget_mc + "." + _prop;
		//_level0.AdminTool.trace("updateHistory from setProperty", key, sExecute);
		_level0.updateHistory(key, sExecute);
	}
	public function updateHistory(obj)
	{
		for(var items:String in obj)
		{
			if(typeof(obj[items]) == "object")
			{
				_level0.updateHistory(obj[items].key, obj[items].sExecute);
			}
		}
		this.getMovieClipProperties(_level0.sCurrentTarget, true)
	}
	
	/*****************
	*
	* These next set of calls are specific to sound, NetStream.  They either call for properties or send remote commands to control the object
	*
	* Again, properties recieved are in an object that's sent to the PI for displayin the datagrid*
	*
	* */
	public function getSoundProperties(sSound)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getSoundProperties", sSound);
	}
	public function setSoundProperties(obj:Object)
	{
		_global.sound_cp.setSoundProperties(obj);
	}
	public function getVideoProperties(sNetStream)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "getVideoProperties", sNetStream);
	}
	public function setVideoProperties(obj:Object)
	{
		_global.controlPanel.setVideoProperties(obj);
	}
	public function playSound(sSound:String, iLoops:Number)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "playSound", sSound, iLoops);
	}
	public function stopSound(sSound:String)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "stopSound", sSound);
	}
	public function playVideo(sVideo:String, flv:String)
	{
		// set global FLV variable for later use if we tab away and come back
		_level0.lastFLV = flv;
		var bSent:Boolean = this.send("_xray_remote_conn", "playVideo", sVideo, flv);
	}
	public function pauseVideo(sVideo:String)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "pauseVideo", sVideo);
	}
	public function stopVideo(sVideo:String)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "stopVideo", sVideo);
	}
	
	/*****************
	*
	* startExamineClips - this is ActiveHighlighting.  When the user clicks on a movieclip in the treeview, this clip is highlighted.
	*
	* */
	public function startExamineClips(sTarget_mc:String, iType:Number)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "startExamineClips", sTarget_mc, iType);
	}
	
	/*****************
	*
	* startExamineClips - this is ActiveHighlighting.  When the user clicks on a movieclip in the treeview, this clip is de-selected.
	*
	* */
	public function stopExamineClips(sTarget_mc:String, iType:Number)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "stopExamineClips", sTarget_mc, iType);
	}
	
	/******************
	*
	* highlightClip - causes the target to receive the standard issue yellow bounding box
	*
	* */
	public function highlightClip(sTarget_mc:String, iType:Number)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "highlightClip", sTarget_mc, iType);
	}
	
	/******************
	*
	* lowlightClip - removes the yellow bounding box*
	*
	* */
	public function lowlightClip(sTarget_mc:String, iType:Number)
	{
		var bSent:Boolean = this.send("_xray_remote_conn", "lowlightClip", sTarget_mc, iType);
	}
	public function allowDomain(sendingDomain:String)
	{
		return true;
	}

	
	//===================================\[ VIEW CONNECTION ]/===================================>
	
	
	//===================================/[ CONNECTION STATUS ]\===================================>
	public function onStatus(infoObject:Object)
	{
		_global.tt("onStatus", infoObject);
		switch (infoObject.level)
		{
		case 'status' :
		
		   if(!_global.bConnected)
		   {
				//_level0.AdminTool.trace("<font size=\"14\" color=\"#006633\"><b>LocalConnection status :: Connected</b></font>\n");
				_global.tt("LocalConnection status :: Connected");
				// reset the examine button if it was in action
				_level0.btn_examineClips.bExamine = false;
				this.stopExamineClips();
				_level0.main_mc.status.text = "Ready";
				if(_level0.showFPS) this.showFPS();
				if(!_level0.showFPS) this.hideFPS();
		   }
		   this.dispatchEvent({type:"onConnection", status:"connected"});
		   _global.bConnected = true;
	
		  break;
		case 'error' :
	
		  if(_global.bConnected)
		  {
			this.hideFPS()
			_level0.main_mc.status.text = "Connection Error - not connected";
				//_level0.AdminTool.trace("<font size=\"14\" color=\"#FF0000\"><b>LocalConnection encountered an error</b></font>\nEither close the Admin Tool and re-open, or restart your flash application.\n");
				_globalt.tt("LocalConnection encountered an error\nEither close the Admin Tool and re-open, or restart your flash application.\n");
		  }
		  _global.bConnected = false;
		  break;
		}
	}
	//===================================\[ CONNECTION STATUS ]/===================================>
	
	public function initConnections():Boolean
	{
		// connect to the local connection to RECIEVE DATA
		_global.bConnected = this.connect("_xray_conn");

		if(_global.bConnected) 
		{
			if(_level0.showFPS) this.showFPS();
			if(!_level0.showFPS) this.hideFPS();
			this.dispatchEvent({type:"onConnection", status:"connected"});
		}

		return _global.bConnected;
	}	
}