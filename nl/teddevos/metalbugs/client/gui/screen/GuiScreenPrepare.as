package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.client.network.connection.ServerGameDataEvent;
	
	public class GuiScreenPrepare extends GuiScreen
	{
		private var hosting:Boolean;
		private var serverinfo:GuiText;
		private var infoText:GuiText;
		private var pingText:GuiText;
		private var startTime:Number = 1000000;
		private var gametimeSpam:int;
		private var waiting:Boolean;
		
		public function GuiScreenPrepare(host:Boolean) 
		{
			hosting = host;
			gametimeSpam = 10;
			
			if (hosting)
			{
				gametimeSpam = 10000;
			}
		}
		
		override public function init():void
		{
			Main.client.startWorld();
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.addEventListener(ServerGameDataEvent.DATA, onGameData);
			
			var title:GuiText = new GuiText(400, 260, 35, 0xFFFFFF, "center");
			title.setText("Preparing match");
			addChild(title);
			
			infoText = new GuiText(400, 310, 15, 0xFFFFFF, "center");
			infoText.setText("Waiting for other players.");
			addChild(infoText);
			
			pingText = new GuiText(400, 750, 15, 0xFFFFFF, "center");
			pingText.setText("Lowest ping: 999ms");
			addChild(pingText);
			
			waiting = false;
			
			if (hosting)
			{
				pingText.setText("Lowest ping: 0ms (you are hosting!)");
				Main.client.world.newGameTime(Main.server.world.gameTime_current, 0, true);
				Main.client.connection.sendTCP(NetworkID.TCP_CLIENT_READY);
			}
		}
		
		override public function tick():void 
		{ 
			if (!hosting)
			{
				if (!Main.client.connection.socketTCP.connected)
				{
					client.switchGui(new GuiScreenLost("Lost connection to server!"));
				}
				
				pingText.setText("Lowest ping: " + int(Main.client.world.lowestPing) + "ms");
				
				gametimeSpam--;
				if (gametimeSpam < 0)
				{
					gametimeSpam += 15;
					var d:Date = new Date();
					Main.client.connection.sendGameUDP(NetworkID.GAME_CLIENT_TIME_REQUEST, "" + d.time);
				}
			}
			
			if (waiting && Main.client.world.gameTime > startTime)
			{
				Main.client.world.gameTime -= startTime;
				Main.client.world.playing = true;
				trace("start");
				client.switchGui(new GuiScreenGame());
			}
			else if(waiting)
			{
				infoText.setText("Game will start in " + (int((startTime - Main.client.world.gameTime) / 1000) + 1) + " seconds!");
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.TCP_SERVER_STARTTIME)
			{
				var a:Array = e.data.split("#");
				var b:Array = String(a[0]).split(";");
				
				startTime = parseFloat(b[0]);
				waiting = true;
			}
		}
		
		public function onGameData(e:ServerGameDataEvent):void
		{
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.removeEventListener(ServerGameDataEvent.DATA, onGameData);
		}
	}
}