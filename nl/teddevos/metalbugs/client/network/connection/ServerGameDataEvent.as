package nl.teddevos.metalbugs.client.network.connection 
{
	import flash.events.Event;

	public class ServerGameDataEvent extends Event
	{
		public static const DATA:String = "serverGameData";
		
		public var data:String;
		public var id:int;
		
		public function ServerGameDataEvent(type:String, i:int, d:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
			this.id = i;
		}
		
		public override function clone():Event
		{
			return new ServerGameDataEvent(type, id, data, bubbles, cancelable);
		}
	}
}