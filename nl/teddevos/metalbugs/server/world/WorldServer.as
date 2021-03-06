package nl.teddevos.metalbugs.server.world 
{
	import nl.teddevos.metalbugs.server.data.Settings;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.server.network.connection.ClientConnection;
	import nl.teddevos.metalbugs.server.network.connection.ClientManager;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.common.util.MathHelper;
	
	public class WorldServer 
	{
		public var gameTime_start:Number;
		public var gameTime_prev:Number;
		public var gameTime_current:Number;
		public var gameTime_past:Number;
		public var startTime:Number;
		
		public var sendDelay:int;
		
		public var playing:Boolean;
		
		public var clientManager:ClientManager;
		
		public var nextPickupID:int = 0;
		public var pickUps:Vector.<Pickup>;
		public var spawnDelay:int;
		
		public function WorldServer() 
		{
			var d:Date = new Date();
			gameTime_start = d.time;
			gameTime_prev = 0;
			gameTime_current = gameTime_start;
			gameTime_past = 0;
			startTime = gameTime_start + 20000;
			
			pickUps = new Vector.<Pickup>();
			
			clientManager = Main.server.clientManager;
			var l:int = clientManager.clients.length;
			for (var i:int = 0; i < l; i++)
			{
				getSpawnpoint(clientManager.clients[i]);
				clientManager.clients[i].death = false;
				clientManager.clients[i].posD = 0;
				clientManager.clients[i].posS = 0;
				clientManager.clients[i].evolution = 1;
				clientManager.clients[i].light = true;
			}
			
			sendDelay = 15;
			spawnDelay = 30;
		}
		
		public function start():void
		{
			playing = true;
		}
		
		public function createPickup(x:Number, y:Number):void
		{
			pickUps.push(new Pickup(nextPickupID, x, y));
			Main.server.clientManager.sendGameUDPtoAll(NetworkID.GAME_SERVER_PICKUP_SPAWN, x + ";" + y + ";" + nextPickupID);
			Main.server.clientManager.sendTCPtoAll(NetworkID.TCP_SERVER_PICKUP_SPAWN, x + ";" + y + ";" + nextPickupID);
			nextPickupID++;
		}
		
		public function getSpawnpoint(client:ClientConnection):void
		{
			var minDist:Number = 320;
			var found:Boolean = true;
			var l:int = clientManager.clients.length;
			while (true)
			{
				minDist -= 20;
				var rX:Number = -900 + (Math.random() * 1800);
				var rY:Number = -900 + (Math.random() * 1800);
				
				found = true;
				for (var i:int = 0; i < l; i++ )
				{
					if (!clientManager.clients[i].death && clientManager.clients[i] != client)
					{
						if (MathHelper.dis2(rX, rY, clientManager.clients[i].posX, clientManager.clients[i].posY) < minDist)
						{
							found = false;
						}
					}
				}
				
				if (found || minDist < 0)
				{
					client.posX = rX;
					client.posY = rY;
					break;
				}
			}
		}
		
		public function tick():void
		{
			var d:Date = new Date();
			
			gameTime_prev = gameTime_current;
			gameTime_current = d.time - gameTime_start;
			gameTime_past = gameTime_current - gameTime_prev;
			
			if (playing)
			{
				var l:int = clientManager.clients.length;
				var pl:int = pickUps.length;
				var highest:int = 1;
				for (var i:int = 0; i < l; i++)
				{
					highest = clientManager.clients[i].evolution > highest ? clientManager.clients[i].evolution : highest;
					clientManager.clients[i].playerMove(this);
					for (var q:int = 0; q < pl; q++ )
					{
						if (MathHelper.dis2(clientManager.clients[i].posX, clientManager.clients[i].posY, pickUps[q].posX, pickUps[q].posY) < 30)
						{
							pl--;
							Main.server.clientManager.sendGameUDPtoAll(NetworkID.GAME_SERVER_PICKUP_DESTROY, pickUps[q].id + "");
							Main.server.clientManager.sendGameUDPtoAll(NetworkID.TCP_SERVER_PICKUP_DESTROY, pickUps[q].id + "");
							Main.server.clientManager.sendGameUDP(clientManager.clients[i], NetworkID.GAME_SERVER_GROW, gameTime_current + "");
							Main.server.clientManager.sendTCP(clientManager.clients[i], NetworkID.TCP_SERVER_GROW, gameTime_current + "");
							pickUps.splice(q, 1);
							break;
						}
					}
				}
				
				for (var col1:int = 0; col1 < l; col1++)
				{
					for (var col2:int = 0; col2 < l; col2++)
					{
						if (col1 != col2 && MathHelper.dis2(clientManager.clients[col1].posX, clientManager.clients[col1].posY, clientManager.clients[col2].posX, clientManager.clients[col2].posY) < 60)
						{
							if (clientManager.clients[col1].evolution > clientManager.clients[col2].evolution)
							{
								getSpawnpoint(clientManager.clients[col2]);
								clientManager.clients[col2].evolution = 0;
								Main.server.clientManager.sendTCPtoAll(NetworkID.TCP_SERVER_RESET, gameTime_current + ";" + clientManager.clients[col1].clientID + ";" + clientManager.clients[col2].clientID + ";" + clientManager.clients[col2].posX + ";" + clientManager.clients[col2].posY);
								Main.server.clientManager.sendGameUDPtoAll(NetworkID.GAME_SERVER_RESET, gameTime_current + ";" + clientManager.clients[col1].clientID + ";" + clientManager.clients[col2].clientID + ";" + clientManager.clients[col2].posX + ";" + clientManager.clients[col2].posY);
								Main.server.clientManager.sendGameUDP(clientManager.clients[col1], NetworkID.GAME_SERVER_GROW, gameTime_current + "");
								Main.server.clientManager.sendTCP(clientManager.clients[col1], NetworkID.TCP_SERVER_GROW, gameTime_current + "");
								trace(col1);
							}
						}
					}
				}
				
				sendDelay--;
				if (sendDelay < 0)
				{
					sendDelay += 8;
					
					var s:String = gameTime_current + "";
					var ll:int = clientManager.clients.length;
					for (var c:int = 0; c < ll; c++)
					{
						if (!clientManager.clients[c].death)
						{
							s += "#" + clientManager.clients[c].clientID + "$" + clientManager.clients[c].posX + ";" + clientManager.clients[c].posY + ";" + clientManager.clients[c].posD + ";" + clientManager.clients[c].posS + ";" + clientManager.clients[c].evolution + ";" + clientManager.clients[c].light;
						}
					}
					
					clientManager.sendGameUDPtoAll(NetworkID.GAME_SERVER_UPDATE_PLAYERS, s);
				}
				
				spawnDelay--;
				if (spawnDelay < 0)
				{
					spawnDelay += 15;
					pl = pickUps.length;
					if (pl < 5 - highest || pl < 1)
					{
						var tr:int = 0;
						while (tr < 20)
						{
							tr++;
							
							var rx:Number = -900 + (Math.random() * 1800);
							var ry:Number = -900 + (Math.random() * 1800);
							var spawn:Boolean = true;
							
							for (var j:int = 0; j < l; j++)
							{
								if (MathHelper.dis2(clientManager.clients[j].posX, clientManager.clients[j].posY, rx, ry) < 150)
								{
									spawn = false;
								}
							}
							
							if (spawn)
							{
								createPickup(rx, ry);
								break;
							}
						}
					}
				}
			}
		}
		
		public function end():void
		{
		}
	}
}