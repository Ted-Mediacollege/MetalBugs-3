package nl.teddevos.metalbugs.client.network.test 
{
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import nl.teddevos.metalbugs.common.Port;
	import flash.utils.ByteArray;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	
	public class ConnectionTest 
	{
		public var socketUDP:DatagramSocket;
		public var failed:Boolean;
		
		public function ConnectionTest() 
		{
			socketUDP = new DatagramSocket();
			socketUDP.addEventListener(DatagramSocketDataEvent.DATA, onData);
			start();
		}
		
		public function start():void
		{
			try
			{
				failed = false;
				socketUDP.bind(Port.TEST_UDP);
				socketUDP.receive();
			}
			catch (e:Error)
			{
				failed = true;
			}
		}
		
		public function send(id:int, message:String, ip:String):void
		{
			if (!failed)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF("777" + id + message);
				socketUDP.send(b, 0, 0, ip, Port.QUICK_UDP_SERVER);
			}
		}
		
		public function onData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var id:int = parseInt(s.substr(0, 3));
			Main.client.dispatchEvent(new ServerTCPdataEvent(ServerTCPdataEvent.DATA, id, s.substr(3)));
		}
	}
}