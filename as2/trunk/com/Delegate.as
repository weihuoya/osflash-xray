class com.Delegate extends Object
{
	static function create(obj:Object, func:Function):Function
	{
		var returnFunction = function()
		{
			var self:Function = arguments.callee;
			var target_obj:Object = self.target_obj;
			var func:Function = self.func;
			var userArguments_array:Array = self.userArguments_array;

			return func.apply(target_obj, arguments.concat(userArguments_array));
		};

		returnFunction.target_obj = obj;
		returnFunction.func = func;
		returnFunction.userArguments_array = arguments.splice(2);

		return returnFunction;
	}
};
