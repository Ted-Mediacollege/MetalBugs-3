package nl.teddevos.metalbugs.server.network.connection 
{
	import flash.events.Event;

	public class ClientTCPdataEvent extends Event
	{
		public static const DATA:String = "clientTCPdata";
		
		public var data:String;
		public var id:int;
		public var playerID:int;
		
		public function ClientTCPdataEvent(type:String, pID:int, i:int, d:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = d;
			this.id = i;
			this.playerID = pID;
		}
		
		public override function clone():Event
		{
			return new ClientTCPdataEvent(type, playerID, id, data, bubbles, cancelable);
		}
	}
}