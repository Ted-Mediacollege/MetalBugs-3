package nl.teddevos.metalbugs.server.data 
{
	public class ServerLog 
	{
		public static var nextLogID:int;
		public static var log:Vector.<String>;
		
		public static function init():void
		{
			nextLogID = 0;
			log = new Vector.<String>();
		}
		
		public static function addMessage(m:String):void
		{
			trace(m);
			log.push(nextLogID + ";" + m);
			nextLogID++;
			
			if (log.length > 8)
			{
				log.shift();
			}
		}
		
		public static function getServerLogString():String
		{
			var l:int = log.length;
			var s:String = "";
			for (var i:int = 0; i < l; i++ )
			{
				if (i > 0)
				{
					s += "#";
				}
				s += log[i];
			}
			
			return s;
		}
	}
}