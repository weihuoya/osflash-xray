/*
Copyright (c) 2007 John Grden

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package com.blitzagency.xray.logger
{
	import com.blitzagency.xray.logger.ClassLoader;
	/**
	 * @author John Grden
	 */
	public class LogManager
	{
		public static var initialized:Boolean;
		private static var loggerList:Object;
		
		
		public static function initialize():void
		{
			if(initialized) return;
			loggerList = new Object();
			initialized = true;
		}
		
		public static function getLogger(p_logger:String):Object
		{
			// initialize loggers object if not done so already
			var package:String = p_logger.split(".").join("_");
			if(loggerList[package].instance != undefined)
			{
				// if instance already exists, pass it back
				return loggerList[package].instance;
			}
			else
			{
				// grag logger class
				var loggerObject = ClassLoader.getClassByName(p_logger);
				
				// create new instance
				var instance:Object = new loggerObject();
				
				// update list
				loggerList[package] = new Object();
				loggerList[package].instance = instance;
				
				// return logger instance
				return instance;
			}
		}
	}
}