import com.blitzagency.events.GDispatcher;
class com.blitzagency.util.RecursionCheck 
{
	var addEventListener:Function;
	var removeEventListener:Function;
	var dispatchEvent:Function;
	public var maxRecursionLevel:Number;
	public static var _instance:RecursionCheck = null;
	private var members:Array

	public static function getInstance():RecursionCheck
	{
		if(RecursionCheck._instance == null)
		{
			RecursionCheck._instance = new RecursionCheck();
		}
		return RecursionCheck._instance;
	}

	private function RecursionCheck()
	{
		// private contructor insures that this will be the only instance

		// initialize event dispatcher
		GDispatcher.initialize(this);
		members = new Array()
		this.maxRecursionLevel = 3;
	}
	
	/**
	 *	Check if the object is a member
	 *	@param	obj
	 *	@return	Boolean
	 */
	public function isMember(obj):Object
	{
		var returnObj:Object = getIndex(obj);
		if( returnObj != null)
		{
			return returnObj;
		}
	}
	
	/**
	 *	Subscribe a listener to the object.
	 *	@param	obj
	 *  @return	Boolean
	 */
	public function addMember (obj):Boolean 
	{
		if (obj != undefined) 
		{
			members.push({obj:obj, count:1});
			return true;
		}
		return false;
	}
	
	/**Unsubscribe a member from the object.
	* 	@param	obj
	* 	@return	Boolean
	*/
	public function removeMember (obj):Boolean 
	{
		var testObj = getIndex(obj);
		if (testObj.exists) 
		{
			members.splice (testObj.index, 1);
			return true;
		}
		return false;
	}
	
	/**
	 *	Remove all members from the object
	 */
	public function clear ():Void 
	{
		members = [];
	}
	
	//Returns the index of the member in the array
	private function getIndex (obj):Object 
	{
		var len:Number = members.length;
		for (var i:Number = 0; i < len; i++) 
		{
			var o = members[i];
			if (o.obj == obj && o.count < this.maxRecursionLevel) 
			{
				// can be recursed again
				o.count++;
				return {exists:true, recurse:true, count:o.count, index:i};
			}else if (o.obj == obj && o.count >= this.maxRecursionLevel) 
			{
				// can be shown, but not recursed
				return {exists:true, recurse:false, count:o.count, index:i};
			}
		}
		return {exists:false, recurse:true, index:-1};
	}
}
