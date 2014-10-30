package nl.teddevos.metalbugs.server.world 
{
	import nl.teddevos.metalbugs.server.data.Settings;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.server.network.connection.ClientConnection;
	import nl.teddevos.metalbugs.server.network.connection.ClientManager;
	import nl.teddevos.metalbugs.common.NetworkID;
	
	public class WorldServer 
	{
		public var gameTime_start:Number;
		public var gameTime_prev:Number;
		public var gameTime_current:Number;
		public var gameTime_past:Number;
		public var startTime:Number;
		
		public var playing:Boolean;
		
		public var clientManager:ClientManager;
		
		public function WorldServer() 
		{
			var d:Date = new Date();
			gameTime_start = d.time;
			gameTime_prev = 0;
			gameTime_current = gameTime_start;
			gameTime_past = 0;
			startTime = gameTime_start + 20000;
			
			clientManager = Main.server.clientManager;
			var l:int = clientManager.clients.length;
			for (var i:int = 0; i < l; i++)
			{
				clientManager.clients[i].posX = 0;
				clientManager.clients[i].posY = 0;
				clientManager.clients[i].posD = 0;
				clientManager.clients[i].posS = 0;
				clientManager.clients[i].evolution = 0;
				clientManager.clients[i].light = false;
			}
		}
		
		public function start():void
		{
			playing = true;
		}
		
		public function tick():void
		{
			var d:Date = new Date();
			
			gameTime_prev = gameTime_current;
			gameTime_current = d.time - gameTime_start;
			gameTime_past = gameTime_current - gameTime_prev;
			
			if (playing)
			{
				
			}
		}
		
		public function end():void
		{
		}
	}
}