package nl.teddevos.metalbugs.server.network.connection 
{
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.net.ServerSocket;
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.ByteArray;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.server.data.Settings;
	import nl.teddevos.metalbugs.common.Port;
	import nl.teddevos.metalbugs.server.data.ServerLog;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.server.network.connection.ClientTCPdataEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	
	public class ClientManager 
	{
		public var socketTCP:ServerSocket;
		public var socketUDP_GAME:DatagramSocket;
		public var socketUDP_QUICK:DatagramSocket;
		
		private var updateTimer:int = 5;
		private var countDown:int = 150;
		private var waiting:Boolean = false;
		private var soloTesting:Boolean = false;
		
		public var clients:Vector.<ClientConnection>;
		
		public var LOBBY:Boolean = true;
		public var PREPARE:Boolean = false;
		public var GAME:Boolean = false;
		public var SCORE:Boolean = false;
		
		public function ClientManager() 
		{
			socketTCP = new ServerSocket();
			socketTCP.addEventListener(ServerSocketConnectEvent.CONNECT, onIncommingConnection);
			socketTCP.bind(Port.MAIN_TCP);
			socketTCP.listen();
			ServerLog.addMessage("[NETWORK]: TCP connection is ready!");
			
			socketUDP_GAME = new DatagramSocket();
			socketUDP_GAME.addEventListener(DatagramSocketDataEvent.DATA, onGameData);
			socketUDP_GAME.bind(Port.GAME_UDP_SERVER);
			socketUDP_GAME.receive();
			
			socketUDP_QUICK = new DatagramSocket();
			socketUDP_QUICK.addEventListener(DatagramSocketDataEvent.DATA, onQuickData);
			socketUDP_QUICK.bind(Port.QUICK_UDP_SERVER);
			socketUDP_QUICK.receive();

			ServerLog.addMessage("[NETWORK]: UDP connections are ready!");
			
			clients = new Vector.<ClientConnection>();
			
			var netInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var l:int = netInterfaces.length;
			for (var i:int = 0; i < l; i++ )
			{
				try
				{
					if (netInterfaces[i].addresses[0].address.length > 5)
					{
						var b:ByteArray = new ByteArray();
						b.writeUTF("777" + NetworkID.LOCAL_IP_TEST + "" + netInterfaces[i].addresses[0].address);
						socketUDP_QUICK.send(b, 0, 0, netInterfaces[i].addresses[0].address, Port.QUICK_UDP_SERVER);
					}
				}
				catch (e:Error)
				{
				}
			}
		}
		
		public function destroy():void
		{
			socketTCP.close();
			socketTCP.removeEventListener(ServerSocketConnectEvent.CONNECT, onIncommingConnection);

			socketUDP_GAME.close();
			socketUDP_GAME.removeEventListener(DatagramSocketDataEvent.DATA, onGameData);
			
			socketUDP_QUICK.close();
			socketUDP_QUICK.removeEventListener(DatagramSocketDataEvent.DATA, onQuickData);
			
			for (var i:int = clients.length - 1; i > -1; i-- )
			{
				clients[i].forceClose();
			}
		}

		public function onIncommingConnection(e:ServerSocketConnectEvent):void
		{
			var b:ByteArray = new ByteArray();
			if (!LOBBY)
			{
				b.writeUTF(NetworkID.TCP_SERVER_REJECT_PLAYING + "empty");
			}
			else if (clients.length < Settings.MAX_PLAYERS)
			{
				var id:int = getNextAvailibleID();
				b.writeUTF(NetworkID.TCP_SERVER_WELCOME + "" + id + "#" + Main.server.serverName + "#" + Settings.MAX_PLAYERS);
				clients.push(new ClientConnection(e.socket, id, getHighestRank()));
			}
			else 
			{
				b.writeUTF(NetworkID.TCP_SERVER_REJECT_FULL + "empty");
			}
			e.socket.writeBytes(b);
			e.socket.flush();
		}
		
		public function onGameData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var player:int = parseInt(s.substr(0, 3)) - 100;
			var id:int = parseInt(s.substr(3, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(6);
			
			if (PREPARE)
			{
				if (id == NetworkID.GAME_CLIENT_TIME_REQUEST)
				{
					for (var b:int = clients.length - 1; b > -1; b-- )
					{
						if (clients[b].clientID == player)
						{
							sendGameUDP(clients[b], NetworkID.GAME_SERVER_TIME, Main.server.world.gameTime_current + ";" + message);
						}
					}
				}
			}
			else if (GAME)
			{
			}
		}
		
		public function onQuickData(e:DatagramSocketDataEvent):void
		{
			var s:String = e.data.readUTF();
			var player:int = parseInt(s.substr(0, 3)) - 100;
			var id:int = parseInt(s.substr(3, 3));
			if (id == NetworkID.KEEP_ALIVE) { return; }
			var message:String = s.substr(6);
			
			if (id == NetworkID.LOCAL_IP_TEST) 
			{ 
				if (!Main.server.localIPfound)
				{
					ServerLog.addMessage("[SERVER]: running on ip " + message);
					Main.server.localIP = message;
					Main.server.localIPfound = true;
				}
				return; 
			}
			else if (id == NetworkID.RESP_CLIENT_REQUEST)
			{
				var b:ByteArray = new ByteArray();
				b.writeUTF(NetworkID.RESP_SERVER_AWNSER + message + "#" + Main.server.serverName + "#" + clients.length + "#" + Settings.MAX_PLAYERS + "#" + (LOBBY ? "1" : "0"));
				socketUDP_QUICK.send(b, 0, 0, e.srcAddress, Port.TEST_UDP);
			}
			else
			{
				for (var i:int = clients.length - 1; i > -1; i-- )
				{
					if (clients[i].clientID == player)
					{			
						if (id == NetworkID.PING)
						{
							clients[i].calculatePing(Number(parseFloat(message)));
						}
						else
						{
							clients[i].onQuickUDPdata(id, message);
						}
						break;
					}
				}
			}
		}
		
		public function tick():void
		{
			for (var i:int = clients.length - 1; i > -1; i-- )
			{
				if (clients[i] != null)
				{
					if (clients[i].disconnected)
					{
						clients[i] = null;
						clients.splice(i, 1);
					}
				}
				else
				{
					clients.splice(i, 1);
				}
			}
			
			if (LOBBY)
			{
				var allReady:Boolean = true;
				var rl:int = clients.length;
				if (rl == 0) { allReady = false; }
				for (var j:int = rl - 1; j > -1; j-- )
				{
					if (clients[j].ready == 0)
					{
						allReady = false;
					}
				}
			
				if (allReady)
				{
					if (countDown < 1)
					{
						sendTCPtoAll(NetworkID.TCP_SERVER_PREPARE);
						Main.server.startWorld();
						LOBBY = false;
						PREPARE = true;
						updateTimer += 10;
										
						for (var lr:int = clients.length - 1; lr > -1; lr-- )
						{
							clients[lr].loadReady = false;
							clients[lr].death = false;
							clients[lr].score = 0;
						}
						
						if (clients.length < 2)
						{
							soloTesting = true;
						}
					}
					else
					{
						if (countDown % 30 == 0)
						{
							ServerLog.addMessage("The game will start in " + int(countDown / 30) + " seconds!");
						}
					}
					countDown--;
				}
				else
				{
					if (countDown < 150)
					{
						ServerLog.addMessage("Countdown interrupted!");
					}
					countDown = 150;
				}
			
				updateTimer--;
				if (updateTimer < 0)
				{
					var s:String = getPlayerListString();
					var c:String = ServerLog.getServerLogString();
					updateTimer += 15;
					for (var p:int = clients.length - 1; p > -1; p-- )
					{
						if (!clients[p].disconnected)
						{
							sendQuickUDP(clients[p], NetworkID.QUICK_SERVER_LIST_UPDATE, s);
							sendQuickUDP(clients[p], NetworkID.QUICK_SERVER_CHAT_UPDATE, c);
							clients[p].pingClient(socketUDP_QUICK);
						}
					}
				}
			}
			else if (PREPARE)
			{
				var loaded:Boolean = true;
				for (var n:int = clients.length - 1; n > -1; n-- )
				{
					if (clients[n].loadReady == false)
					{
						loaded = false;
					}
				}
				
				if (loaded && !waiting)
				{
					waiting = true;
					Main.server.world.startTime = Main.server.world.gameTime_current + 2000;
					Main.server.clientManager.sendTCPtoAll(NetworkID.TCP_SERVER_STARTTIME, Main.server.world.startTime + "");
					
					var pString:String = "";
					var ml:int = clients.length;
					for (var m:int = 0; m < ml; m++)
					{
						if (m > 0)
						{
							pString += "#";
						}
						pString += clients[m].clientID + ";" + clients[m].playerName + ";" + clients[m].posX + ";" + clients[m].posY + ";" + clients[m].posD + ";" + clients[m].posS + ";" + clients[m].evolution + ";" + clients[m].light;
					}
					Main.server.clientManager.sendTCPtoAll(NetworkID.TCP_SERVER_PLAYERSPAWNS, pString);
					
					//1;name;X;Y;D;S;E;L
				}
				
				if (waiting && Main.server.world.gameTime_current > Main.server.world.startTime)
				{
					PREPARE = false;
					GAME = true;
					Main.server.world.gameTime_current -= Main.server.world.startTime;
					Main.server.world.start();
					countDown = 90;
				}
			}
			else if (GAME)
			{
			}
		}
		
		public function sendGameUDPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendGameUDP(clients[i], id, message);
				}
			}
		}
		
		public function sendGameUDP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			var b:ByteArray = new ByteArray();
			b.writeUTF(id + message);
			socketUDP_GAME.send(b, 0, 0, client.remoteAdress, Port.GAME_UDP_CLIENT);
		}
		
		public function sendQuickUDPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendQuickUDP(clients[i], id, message);
				}
			}
		}
		
		public function sendQuickUDP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			var b:ByteArray = new ByteArray();
			b.writeUTF(id + message);
			socketUDP_QUICK.send(b, 0, 0, client.remoteAdress, Port.QUICK_UDP_CLIENT);
		}
		
		public function sendTCPtoAll(id:int, message:String = "empty", except:int = -1):void
		{
			var l:int = clients.length;
			for (var i:int = 0; i < l; i++ )
			{
				if (clients[i].clientID != except)
				{
					sendTCP(clients[i], id, message);
				}
			}
		}
		
		public function sendTCP(client:ClientConnection, id:int, message:String = "empty"):void
		{
			client.sendTCP(id, message);
		}
		
		public function getPlayerListString():String
		{
			var l:int = clients.length;
			var s:String = "";
			for (var i:int = 0; i < l; i++ )
			{
				s += clients[i].playerName + ";" + clients[i].clientID + ";" + int(clients[i].pingAverage) + ";" + clients[i].ready + ";" + clients[i].score + ";" + clients[i].rank;
				if (i < l - 1)
				{
					s += "#";
				}
			}
			
			return s;
		}
		
		public function getNextAvailibleID():int
		{
			if (clients.length == 0)
			{
				return 0;
			}
			
			for (var id:int = 0; id < 100; id++ )
			{
				var l:int = clients.length;
				for (var p:int = 0; p < l; p++ )
				{
					if (id == clients[p].clientID)
					{
						break;
					}
					if (p == l - 1)
					{
						return id;
					}
				}
			}
			return -1;
		}
		
		public function getHighestRank():int
		{
			if (clients.length == 0)
			{
				return 0;
			}
			
			var highest:int = 0;
			var l:int = clients.length;
			for (var p:int = 0; p < l; p++ )
			{
				if (clients[p].rank > highest)
				{
					highest = clients[p].rank;
				}
			}
			return highest + 1;
		}
	}
}