package nl.teddevos.metalbugs.client.network.connection 
{
	import flash.net.DatagramSocket;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.Port;
	import nl.teddevos.metalbugs.common.NetworkID;
	
	public class Connection 
	{
		public var connected:Boolean;
		public var failed:Boolean;
		public var error:String = "";
		
		public var serverName:String = "";
		public var maxPlayers:int = 8;
		public var playerID:int;
		public var address:String;
		
		public var socketTCP:Socket;
		public var socketUDP_GAME:DatagramSocket;
		public var socketUDP_QUICK:DatagramSocket;
		
		public var keepAlive:int = 15;
		
		public function Connection() 
		{
			socketTCP = new Socket();
			socketTCP.addEventListener(Event.CONNECT, onConnect);
			socketTCP.addEventListener(Event.CLOSE, onDisconnect);
			socketTCP.addEventListener(ProgressEvent.SOCKET_DATA, onRecieveData);
			socketTCP.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socketTCP.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			socketUDP_GAME = new DatagramSocket();
			socketUDP_GAME.addEventListener(DatagramSocketDataEvent.DATA, onGameData);
			
			socketUDP_QUICK = new DatagramSocket();
			socketUDP_QUICK.addEventListener(DatagramSocketDataEvent.DATA, onQuickData);
		}
		
		public function connect(ip:String):void
		{
			try
			{
				connected = false;
				failed = false;
				error = "";
				address = ip;
				
				keepAlive = 15;
				
				socketTCP.timeout = 2000;
				socketTCP.connect(ip, Port.MAIN_TCP);
				
				socketUDP_GAME.bind(Port.GAME_UDP_CLIENT);
				socketUDP_GAME.receive();
				
				socketUDP_QUICK.bind(Port.QUICK_UDP_CLIENT);
				socketUDP_QUICK.receive();
			}
			catch (e:Error)
			{
				trace("[CLIENT]: Cannot connect!");
				error = "Cannot connect";
				failed = true;
				connected = false;
			}
		}
		
		public function kill():void
		{
			try
			{
				socketTCP.close();
				socketUDP_GAME.close();
				socketUDP_QUICK.close();
			}
			catch (e:Error)
			{
				trace("failed to close some sockets");
			}
			connected = false;
		}
		
		public function onConnect(e:Event):void
		{
			connected = true;
		}
		
		public function onDisconnect(e:Event):void
		{
			connected = false;
			kill();
			trace("[CLIENT]: UDP ERROR");
			error = "Failed to start udp connection";
			failed = true;
		}
		
		public function onIOError(e:IOErrorEvent):void
		{
			trace("[CLIENT]: NETWORK IO ERROR");
			error = "Network io error";
			failed = true;
			connected = false;
			kill();
		}
		
		public function onSecurityError():void
		{
			trace("[CLIENT]: SECURITY ERROR");
			error = "Security error";
			failed = true;
			connected = false;
			kill();
		}
		
		public function onRecieveData(e:ProgressEvent):void
		{
			while (socketTCP.bytesAvailable)
			{
				var s:String = socketTCP.readUTF();
				var id:int = parseInt(s.substr(0, 3));
				Main.client.dispatchEvent(new ServerTCPdataEvent(ServerTCPdataEvent.DATA, id, s.substr(3)));
			}
		}
		
		public function onQuickData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var id:int = parseInt(s.substr(0, 3));
			
			if (id == NetworkID.PING)
			{
				sendQuickUDP(NetworkID.PING, s.substr(3));
			}
			else
			{
				Main.client.dispatchEvent(new ServerTCPdataEvent(ServerTCPdataEvent.DATA, id, s.substr(3)));
			}
		}
		
		public function onGameData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var id:int = parseInt(s.substr(0, 3));
			
			if (id == NetworkID.GAME_SERVER_TIME)
			{
				if (Main.client.inWorld)
				{
					var a:Array = s.substr(3).split(";");
					Main.client.world.newGameTime(parseInt(a[0]), parseInt(a[1]));
				}
			}
			else if (id == NetworkID.GAME_SERVER_UPDATE_PLAYERS)
			{
				if (Main.client.inWorld)
				{
					Main.client.world.playersUpdate(s.substring(3));
				}
			}
			else
			{
				Main.client.dispatchEvent(new ServerGameDataEvent(ServerGameDataEvent.DATA, id, s.substr(3)));
			}
		}
		
		public function tick():void
		{
			if (connected)
			{
				keepAlive--;
				if (keepAlive < 0)
				{
					keepAlive = 60;
					sendGameUDP(NetworkID.KEEP_ALIVE, "keep-alive");
					sendQuickUDP(NetworkID.KEEP_ALIVE, "keep-alive");
				}
			}
		}
		
		public function sendTCP(id:int, message:String = "empty"):void
		{
			if (connected)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF(id + message);
				socketTCP.writeBytes(b);
				socketTCP.flush();
			}
		}
		
		public function sendGameUDP(id:int, message:String = "empty"):void
		{
			if (connected)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF((playerID + 100) + "" + id + message);
				socketUDP_GAME.send(b, 0, 0, address, Port.GAME_UDP_SERVER);
			}
		}
		
		public function sendQuickUDP(id:int, message:String = "empty"):void
		{
			if (connected)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF((playerID + 100) + "" + id + message);
				socketUDP_QUICK.send(b, 0, 0, address, Port.QUICK_UDP_SERVER);
			}
		}
	}
}