package nl.teddevos.metalbugs.client.world 
{
	import flash.events.MouseEvent;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.client.network.connection.ServerGameDataEvent;
	import nl.teddevos.metalbugs.common.NetworkID;
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.client.util.MathHelper;
	
	public class WorldClient extends Sprite
	{
		public var gameTimeDifference:int = 1000;
		public var gameTime:int;
		private var time_old:int;
		private var time:int;
		private var ticking:Boolean;
		public var playing:Boolean;
		
		public var lowestPing:Number = 100000;
		
		public var clientPlayer:ClientPlayer;
		public var players:Vector.<Player>;
		
		public var cameraX:Number;
		public var cameraY:Number;
		
		private var background:Background;
		
		public function WorldClient() 
		{
			players = new Vector.<Player>();
			
			Main.client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			cameraX = 400;
			cameraY = 400;
			
			background = new Background();
			background.x = cameraX - 1024;
			background.y = cameraY - 1024;
			addChild(background);
		}
		
		public function tick():void
		{
			if (ticking)
			{
				var d:Date = new Date();
				time = d.time - time_old;
				time_old = d.time;
				gameTime += time;
			}
			
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
					players[i].tick(cameraX, cameraY);
				}
			}
			
			background.x = cameraX - 1024;
			background.y = cameraY - 1024;
		}
		
		public function onMouseMove(e:MouseEvent):void
		{
			if (playing)
			{
				clientPlayer.posD = MathHelper.pointToDegree(clientPlayer.x, clientPlayer.y, e.stageX, e.stageY);
				clientPlayer.posS = 4;
			}
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
			
			for (var i:int = 0; i < l; i++ )
			{
				var b:Array = s.split("$");
				var id:int = int(parseInt(b[0]));
				
				for (var j:int = 0; j < pl; j++ )
				{
					if (id == players[j].id)
					{
						players[j].playerUpdate(b[1]);
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
		}
		
		public function onGameData(e:ServerGameDataEvent):void
		{
			
		}
		
		public function destroy():void
		{
			Main.client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			Main.client.removeEventListener(ServerGameDataEvent.DATA, onGameData);
			Main.client.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}
}