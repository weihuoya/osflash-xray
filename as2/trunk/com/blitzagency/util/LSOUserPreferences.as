import com.blitzagency.events.GDispatcher;

class com.blitzagency.util.LSOUserPreferences {

// Public Properties
	public static var loaded:Boolean = false;
	public static var persistent:Boolean = true;

// Private Properties
	private static var preferences:Object = {};
	private static var storedObject:SharedObject;

	// EventDispatcher
	public static var removeEventListener:Function;
	private static var dispatchEvent:Function;


// Initialization
	private function LSOUserPreferences() {	}


// Public Methods
	public static function addEventListener(p_type:String,p_listener:String):Void{
		GDispatcher.initialize(LSOUserPreferences);
		LSOUserPreferences.addEventListener(p_type,p_listener);
	}
	
	// Retrieve Preference
	public static function getPreference(p_key:String) {
		if (preferences[p_key] == undefined) {
			// Try and get LSO property?
			return;
		}
		return preferences[p_key];
	}
	
	public static function getAllPreferences():Object {
		return preferences;
	}

	// Set Local/LSO Preference
	public static function setPreference(p_key:String, p_value, p_persistent:Boolean):Void 
	{
		//_level0.AdminTool.trace(p_key, p_value, p_persistent);
		preferences[p_key] = p_value;

		// Optionally save to LSO
		if (p_persistent == undefined) { p_persistent = persistent; } // Use Default Setting
		if (p_persistent) 
		{
			
			storedObject.data[p_key] = p_value;
			var r = storedObject.flush();
			var m:String;
			//_level0.AdminTool.trace("writing to SO", m);
			switch (r) 
			{
				case "pending": 	
					//_level0.AdminTool.trace("case pending");
					m = "Flush is pending, waiting on user interaction"; 			
					break;
				case true: 		
					//_level0.AdminTool.trace("case true");
					m = "Flush was successful.  Requested Storage Space Approved"; 	
					break;
				case false: 	
					//_level0.AdminTool.trace("case false");
					m = "Flush failed.  User denied request for additional space."; 	
					break;
			}
			dispatchEvent({type:"save", target:LSOUserPreferences, success:r, msg:m});
		}
	}

	// Load from LSO for now
	public static function load(p_path:String):Void {
		//storedObject = SharedObject.getLocal("userPreferences" + _root.projectID, "/");
		storedObject = SharedObject.getLocal("userPreferences" + p_path, "/");
		for (var i:String in storedObject.data) {
			preferences[i] = storedObject.data[i];
		}
		loaded = true;
		dispatchEvent({type:"load", target:LSOUserPreferences, success:true});
	}

	// Clear LSO and reset preferences
	public static function clear():Void {
		storedObject.clear();
		storedObject.flush();
		delete storedObject;
		preferences = {};
	}

// Semi-Public Methods
// Private Methods

}