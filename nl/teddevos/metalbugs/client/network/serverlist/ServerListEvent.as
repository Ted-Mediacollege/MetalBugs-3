package nl.teddevos.metalbugs.client.network.serverlist 
{
	import flash.events.Event;

	public class ServerListEvent extends Event
	{
		public static const DATA:String = "serverListEvent";
		
		public var data:String;
		public var succes:Boolean;
		
		public function ServerListEvent(type:String, suc:Boolean, d:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
			this.succes = suc;
		}
		
		public override function clone():Event
		{
			return new ServerListEvent(type, succes, data, bubbles, cancelable);
		}
	}
}