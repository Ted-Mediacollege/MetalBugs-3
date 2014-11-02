package nl.teddevos.metalbugs.server.network.connection 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.DatagramSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.common.Port;
	import nl.teddevos.metalbugs.server.data.ServerLog;
	import nl.teddevos.metalbugs.server.data.CMDexecute;
	import nl.teddevos.metalbugs.server.world.WorldServer;
	
	public class ClientConnection 
	{
		public var socket:Socket;
		public var remoteAdress:String;
		public var disconnected:Boolean;
		public var clientID:int;
		
		public var playerName:String = "player";
		public var ping:int = 0;
		public var pingAverage:Number = 0;
		
		public var ready:int = 0;
		public var loadReady:Boolean = false;
		
		public var muted:Boolean = false;
		
		public var posX:Number;
		public var posY:Number;
		public var posD:Number;
		public var posS:Number;
		public var evolution:int;
		public var light:Boolean;
		public var death:Boolean;
		
		public var score:int = 0;
		public var deathFrame:int;
		public var rank:int;
		
		public function ClientConnection(s:Socket, id:int, ra:int) 
		{
			socket = s;
			socket.addEventListener(Event.CLOSE, onClientLost);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onNetworkError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onRecieveData);
			socket.timeout = 2000;
			pingAverage = 0;
			ping = 0;
			
			clientID = id;
			rank = ra;
			
			remoteAdress = socket.remoteAddress;
			disconnected = false;
		}
		
		public function forceClose():void
		{
			socket.removeEventListener(Event.CLOSE, onClientLost);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onNetworkError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onRecieveData);
			socket.close();
			disconnected = true;
		}
		
		public function onClientLost(e:Event):void
		{
			ServerLog.addMessage(playerName + " disconnected");
			disconnected = true;
		}
		
		public function onNetworkError(e:IOErrorEvent):void
		{
			ServerLog.addMessage(playerName + " disconnected");
			socket.close();
			disconnected = true;
		}
		
		public function onRecieveData(e:ProgressEvent):void
		{
			var s:String = socket.readUTF();
			var id:int = parseInt(s.substr(0, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(3);
			Main.client.dispatchEvent(new ClientTCPdataEvent(ClientTCPdataEvent.DATA, clientID, id, message));
			
			if (id == NetworkID.TCP_CLIENT_INFO_UPDATE)
			{
				var accepted:Boolean = true;
				var l:int = Main.server.clientManager.clients.length;
				
				for (var i:int = 0; i < l; i++)
				{
					if (Main.server.clientManager.clients[i].playerName == message)
					{
						accepted = false;
					}
				}
				
				if (accepted)
				{
					playerName = message;
					sendTCP(NetworkID.TCP_SERVER_ACCEPT, Main.server.clientManager.getPlayerListString());
					ServerLog.addMessage(playerName + " joined the game!");
				}
				else
				{
					sendTCP(NetworkID.TCP_SERVER_REJECT_NAME, "name");
				}
			}
			else if (id == NetworkID.TCP_CLIENT_CMD && clientID == 0)
			{
				CMDexecute.Execute(message);
			}
			else if (id == NetworkID.TCP_CLIENT_READY)
			{
				loadReady = true;
			}
		}
		
		public function onQuickUDPdata(id:int, message:String):void
		{
			if (id == NetworkID.QUICK_CLIENT_CHAT_NEW && !muted)
			{
				ServerLog.addMessage(playerName + ": " + message);
			}
			else if (id == NetworkID.QUICK_CLIENT_READY)
			{
				ready = parseInt(message);
			}
			else
			{
				Main.client.dispatchEvent(new ClientTCPdataEvent(ClientTCPdataEvent.DATA, clientID, id, message));
			}
		}
		
		public function onGameUDPdata(id:int, message:String):void
		{
		}
		
		public function sendTCP(id:int, message:String):void
		{
			if (!disconnected)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF(id + message);
				socket.writeBytes(b);
				socket.flush();
			}
		}
		
		public function pingClient(pingSocket:DatagramSocket):void
		{
			var d:Date = new Date();
			var b:ByteArray = new ByteArray();
			b.writeUTF(NetworkID.PING + "" + d.time);
			pingSocket.send(b, 0, 0, remoteAdress, Port.QUICK_UDP_CLIENT);
		}
		
		public function playerUpdate(s:String):void
		{
			var a:Array = s.split(";");
			var t:Number = parseFloat(a[0]);
			
			posX = parseFloat(a[1]);
			posY = parseFloat(a[2]);
			posD = parseFloat(a[3]);
			posS = parseFloat(a[4]);
			evolution = int(parseInt(a[5]));
			light = String(a[6]) == "true" ? true : false;
			
			posX += (posS / 33) * (Main.client.world.gameTime - t) * Math.cos(posD * Math.PI / 180.0);
			posY += (posS / 33) * (Main.client.world.gameTime - t) * Math.sin(posD * Math.PI / 180.0);
		}
		
		public function playerMove(world:WorldServer):void
		{
			posX += (posS / 33) * world.gameTime_past * Math.cos(posD * Math.PI / 180.0);
			posY += (posS / 33) * world.gameTime_past * Math.sin(posD * Math.PI / 180.0);
		}
		
		public function calculatePing(pingStart:Number):void
		{
			var d:Date = new Date();
			var p:int = d.time - pingStart;
			
			if (p > 0 && pingStart > 0)
			{
				ping = p;
				if (pingAverage == 0)
				{
					pingAverage = ping;
				}
				else
				{
					pingAverage = (pingAverage * 9 + ping) / 10;
				}
			}
		}
		
		public function resetVariables():void
		{
			ready = 0;
			loadReady = false;
			
			posX = 0;
			posY = 0;
			posD = 0;
			death = false;
		}
	}
}