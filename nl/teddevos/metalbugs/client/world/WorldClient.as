package nl.teddevos.metalbugs.client.world 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.client.network.connection.ServerGameDataEvent;
	import nl.teddevos.metalbugs.common.NetworkID;
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.common.util.MathHelper;
	import flash.display.Shape;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class WorldClient extends Sprite
	{
		public var gameTimeDifference:int = 1000;
		public var gameTime:int;
		private var time_old:int;
		public var time:int;
		private var ticking:Boolean;
		public var playing:Boolean;
		
		public var lowestPing:Number = 100000;
		private var lastUpdate:Number = 0;
		
		public var clientPlayer:ClientPlayer;
		public var players:Vector.<Player>;
		
		public var pickups:Vector.<ClientPickup>;
		
		public var cameraX:Number;
		public var cameraY:Number;
		
		private var background:Background;
		public var topMask:Shape;
		
		private var up:Boolean;
		
		public function WorldClient() 
		{
			players = new Vector.<Player>();
			pickups = new Vector.<ClientPickup>();
			
			Main.client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.client.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			cameraX = 400;
			cameraY = 400;
			
			background = new Background();
			background.x = cameraX - 1024;
			background.y = cameraY - 1024;
			addChild(background);
			
			up = true;
						
			topMask = new Shape();
			addChild(topMask);
			this.mask = topMask;
		}
		
		public function tick():void
		{
			topMask.graphics.clear();
			
			if (ticking)
			{
				var d:Date = new Date();
				time = d.time - time_old;
				time_old = d.time;
				gameTime += time;
			}
			
			background.x = cameraX - 1024;
			background.y = cameraY - 1024;
			
			if (playing)
			{
				cameraX = -clientPlayer.posX + 400;
				cameraY = -clientPlayer.posY + 400;
						
				if (-clientPlayer.posX > 620)
				{
					cameraX = 620 + 400;
				}
				if (-clientPlayer.posY > 620)
				{
					cameraY = 620 + 400;
				}
				if (-clientPlayer.posX < -620)
				{
					cameraX = -620 + 400;
				}
				if (-clientPlayer.posY < -620)
				{
					cameraY = -620 + 400;
				}
				
				var l:int = players.length;
				for (var i:int = 0; i < l; i++ )
				{
					players[i].tick(this);
					
					if (players[i].light)
					{
						drawLight(players[i].x, players[i].y, players[i].posD);
					}
				}
				
				var pl:int = pickups.length;
				for (var p:int = 0; p < pl; p++ )
				{
					pickups[p].tick(this);
				}
			}
		}	
		
		public function drawLight(px:int, py:int, d:Number):void
		{
			topMask.graphics.beginFill(0x000000, 1);
			topMask.graphics.drawCircle(MathHelper.nextX(px, d, 50), MathHelper.nextY(py, d, 50), 60);
			topMask.graphics.drawCircle(MathHelper.nextX(px, d, 290), MathHelper.nextY(py, d, 290), 120);
			var vecs:Vector.<Number> = new Vector.<Number>(8);
			vecs[0] = MathHelper.nextX(MathHelper.nextX(px, d, 42), d - 90, 60);
			vecs[2] = MathHelper.nextX(MathHelper.nextX(px, d, 275), d - 90, 120);
			vecs[4] = MathHelper.nextX(MathHelper.nextX(px, d, 275), d + 90, 120);
			vecs[6] = MathHelper.nextX(MathHelper.nextX(px, d, 42), d + 90, 60);
			vecs[1] = MathHelper.nextY(MathHelper.nextY(py, d, 42), d - 90, 60);
			vecs[3] = MathHelper.nextY(MathHelper.nextY(py, d, 275), d - 90, 120);
			vecs[5] = MathHelper.nextY(MathHelper.nextY(py, d, 275), d + 90, 120);
			vecs[7] = MathHelper.nextY(MathHelper.nextY(py, d, 42), d + 90, 60);
			topMask.graphics.moveTo(vecs[6], vecs[7]);
			for (var i:int = 0; i < 8; i+=2 )
			{
				topMask.graphics.lineTo(vecs[i], vecs[1 + i]);
			}
			topMask.graphics.endFill();
		}
		
		public function newGameTime(t:Number, time:Number, host:Boolean = false):void
		{
			var d:Date = new Date();
			var p:Number = host ? 0 : Number(d.time - time) / 2.0;
			
			if (!ticking)
			{
				gameTime = t + p;
				ticking = true;
				lowestPing = p;
				gameTimeDifference = p;
				
				time_old = d.time;
			}
			else
			{
				if (p < lowestPing)
				{
					lowestPing = p;
					var diff:Number = gameTime - (t + p);
					gameTimeDifference = int(Math.abs(diff));
					gameTime = t + p;
				}
			}
		}
		
		public function playersUpdate(s:String):void
		{
			var a:Array = s.split("#");
			var l:int = a.length;
			var pl:int = players.length;
			var t:Number = parseFloat(a[0]);
			
			if (t > lastUpdate)
			{
				lastUpdate = t;
				for (var i:int = 1; i < l; i++ )
				{
					var b:Array = a[i].split("$");
					var id:int = int(parseInt(b[0]));
					
					for (var j:int = 0; j < pl; j++ )
					{
						if (id == players[j].id)
						{
							players[j].playerUpdate(t, b[1]);
							break;
						}
					}
				}
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.TCP_SERVER_PLAYERSPAWNS)
			{
				var a:Array = e.data.split("#");
				
				var l:int = a.length;
				for (var i:int = 0; i < l; i++)
				{
					var d:Array = String(a[i]).split(";");
					var id:int = int(parseInt(d[0]));
					if (id == Main.client.connection.playerID)
					{
						clientPlayer = new ClientPlayer(id, new String(d[1]), Number(parseFloat(d[2])), Number(parseFloat(d[3])), Number(parseFloat(d[4])), Number(parseFloat(d[5])), int(parseInt(d[6])), String(d[7]) == "true" ? true : false);
						players.push(clientPlayer);
						addChild(clientPlayer);
					}
					else
					{
						var pla:Player = new Player(id, new String(d[1]), Number(parseFloat(d[2])), Number(parseFloat(d[3])), Number(parseFloat(d[4])), Number(parseFloat(d[5])), int(parseInt(d[6])), String(d[7]) == "true" ? true : false);
						players.push(pla);
						addChild(pla);
					}
				}
			}
			else if (e.id == NetworkID.TCP_SERVER_GROW)
			{
				if (parseFloat(e.data) > clientPlayer.lastGrow)
				{
					clientPlayer.lastGrow = parseFloat(e.data);
					if (clientPlayer.evolution < 8)
					{
						clientPlayer.evolution++;
						clientPlayer.art.gotoAndStop(clientPlayer.evolution);
					}
				}
			}
		}
		
		public function onGameData(e:ServerGameDataEvent):void
		{
			if (e.id == NetworkID.GAME_SERVER_PICKUP_SPAWN)
			{
				var a:Array = e.data.split(";");
				
				var pickup:ClientPickup = new ClientPickup(this, parseFloat(a[0]), parseFloat(a[1]), int(parseInt(a[2])));
				pickups.push(pickup);
				addChildAt(pickup, 1);
			}
			else if (e.id == NetworkID.GAME_SERVER_PICKUP_DESTROY)
			{
				var pickupID:int = int(parseInt(e.data));
				
				var l:int = pickups.length;
				for (var j:int = 0; j < l; j++)
				{
					if (pickupID == pickups[j].id)
					{
						removeChild(pickups[j]);
						pickups.splice(j, 1);
						break;
					}
				}
			}
			else if (e.id == NetworkID.GAME_SERVER_GROW)
			{
				if (parseFloat(e.data) > clientPlayer.lastGrow)
				{
					clientPlayer.lastGrow = parseFloat(e.data);
					if (clientPlayer.evolution < 8)
					{
						clientPlayer.evolution++;
						clientPlayer.art.gotoAndStop(clientPlayer.evolution);
					}
				}
			}
		}
		
		public function onKeyDown(e:KeyboardEvent):void
		{
			if (up && e.keyCode == Keyboard.SPACE)
			{
				clientPlayer.light = !clientPlayer.light;
				up = false;
			}
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			up = true;
		}
		
		public function destroy():void
		{
			Main.client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.removeEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Main.client.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}
}