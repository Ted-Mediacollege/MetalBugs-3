package nl.teddevos.metalbugs.client.network.connection 
{
	import flash.events.Event;

	public class ServerTCPdataEvent extends Event
	{
		public static const DATA:String = "serverTCPdata";
		
		public var data:String;
		public var id:int;
		
		public function ServerTCPdataEvent(type:String, i:int, d:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
			this.id = i;
		}
		
		public override function clone():Event
		{
			return new ServerTCPdataEvent(type, id, data, bubbles, cancelable);
		}
	}
}