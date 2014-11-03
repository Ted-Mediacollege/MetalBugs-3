package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.components.GuiButtonServer;
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.network.serverlist.ServerListEvent;
	import nl.teddevos.metalbugs.client.network.serverlist.ServerListRequest;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.data.SaveData;

	public class GuiScreenServerList extends GuiScreen
	{
		public var servers:Vector.<GuiButtonServer>;
		private var nextID:int = 100;
		private var refreshDelay:int = -1;
		private var loading_text:GuiText;
		
		public function GuiScreenServerList() 
		{
			
		}
		
		override public function init():void 
		{ 
			servers = new Vector.<GuiButtonServer>();
			ServerListRequest.requestData();
			
			loading_text = new GuiText(400, 200, 30, 0xFFFFFF, "center");
			loading_text.setText("Loading server list...");
			addChild(loading_text);
			
			var title:GuiText = new GuiText(400, 20, 55, 0xFFFFFF, "center");
			title.setText("Server list");
			addChild(title);
			
			var text_name:GuiText = new GuiText(30, 110, 18, 0xFFFFFF, "left");
			text_name.setText("Server name:");
			addChild(text_name);
			
			var text_state:GuiText = new GuiText(460, 110, 18, 0xFFFFFF, "left");
			text_state.setText("Game state:");
			addChild(text_state);
			
			var text_players:GuiText = new GuiText(610, 110, 18, 0xFFFFFF, "left");
			text_players.setText("Players:");
			addChild(text_players);
			
			var text_ping:GuiText = new GuiText(700, 110, 18, 0xFFFFFF, "left");
			text_ping.setText("Ping:");
			addChild(text_ping);
			
			var button_refresh:GuiButton = new GuiButton(0, 20, 730, 50, 250, 0x222222);
			button_refresh.setText("Refresh list", 35, 0xFFFFFF);
			buttonList.push(button_refresh);
			addChild(button_refresh);
			
			var button_direct:GuiButton = new GuiButton(1, 280, 730, 50, 250, 0x222222);
			button_direct.setText("Direct Connect", 35, 0xFFFFFF);
			buttonList.push(button_direct);
			addChild(button_direct);
			
			var button_menu:GuiButton = new GuiButton(2, 540, 730, 50, 250, 0x222222);
			button_menu.setText("Back", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
			
			client.addEventListener(ServerListEvent.DATA, onListData);
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata); 
		}
		
		override public function tick():void
		{ 
			if (refreshDelay > -1)
			{
				refreshDelay--;
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id > 99)
			{
				for (var i:int = servers.length - 1; i > -1; i--)
				{
					if (servers[i].id == b.id)
					{
						client.switchGui(new GuiScreenConnect(servers[i].useIP, false, false));
					}
				}
			}
			else if (b.id == 0)
			{
				if (refreshDelay < 0)
				{
					if (Main.client.connectionTester.failed)
					{
						Main.client.connectionTester.start();
					}
					
					for (var j:int = buttonList.length - 1; j > -1; j--)
					{
						if (buttonList[j] is GuiButtonServer)
						{
							buttonList.splice(j, 1);
						}
					}
					
					for (var k:int = servers.length - 1; k > -1; k--)
					{
						removeChild(servers[k]);
						servers.splice(k, 1);
					}
					ServerListRequest.requestData();
					refreshDelay = 60;
					loading_text.setText("Loading server list...");
				}
			}
			else if (b.id == 1)
			{
				client.switchGui(new GuiScreenDirectConnect(SaveData.lastIP));
			}
			else if (b.id == 2)
			{
				client.switchGui(new GuiScreenMenu());
			}
		}
		
		public function onListData(e:ServerListEvent):void
		{
			if (ServerListRequest.offline)
			{
				loading_text.setText("Cannot connect to internet.");
			}
			else if (Main.client.connectionTester.failed)
			{
				loading_text.setText("Failed to setup request socket, Try restarting your game");
			}
			else if (e.succes)
			{
				if (e.data.length > 2)
				{
					var a:Array = e.data.split("#");
					var l:int = a.length;
					var d:Date = new Date();
					for (var i:int = 0; i < l; i++ )
					{
						var b:Array = String(a[i]).split(";");
						var ipRemote:String = String(b[0]).replace(new RegExp(/D/g), ".");
						var ipLocal:String = String(b[1]).replace(new RegExp(/D/g), ".");
						
						Main.client.connectionTester.send(NetworkID.RESP_CLIENT_REQUEST, d.time + "#" + ipRemote + "#" + ipLocal + "#" + ipLocal, ipLocal); //LOCAL
						Main.client.connectionTester.send(NetworkID.RESP_CLIENT_REQUEST, d.time + "#" + ipRemote + "#" + ipLocal + "#" + ipRemote, ipRemote); //REMOTE
					}
					
					loading_text.setText("No servers found, try refreshing in a minute");
				}
				else
				{
					loading_text.setText("No servers found, try refreshing in a minute");
				}
			}
			else
			{
				loading_text.setText("Cannot load server list, try refreshing");
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.RESP_SERVER_AWNSER)
			{
				var a:Array = e.data.split("#");
				var startTime:Number = parseFloat(a[0]);
				var d:Date = new Date();
				
				var found:Boolean = false;
				var ipie1:String = String(a[1]);
				var ipie2:String = String(a[2]);
				var ipie3:String = String(a[3]);
				var serverN:String = String(a[4]);
				for (var j:int = servers.length - 1; j > -1; j--)
				{
					if (ipie1 == servers[j].remoteIP && ipie2 == servers[j].localIP && serverN == servers[j].serverName)
					{
						found = true;
						if (servers[j].useIP == servers[j].remoteIP && ipie3 != servers[j].remoteIP)
						{
							servers[j].useIP = ipie3;
						}
						break;
					}
				}
				
				if (!found)
				{
					var b:GuiButtonServer = new GuiButtonServer(nextID, 20, 0, String(a[1]), String(a[2]), String(a[3]), String(a[4]), String(a[5]) + "/" + String(a[6]), d.time - startTime, int(parseInt(a[7])));
					servers.push(b);
					buttonList.push(b);
					addChild(b);
					nextID++;
					loading_text.setText("");
				}
			}
			
			for (var i:int = servers.length - 1; i > -1; i--)
			{
				servers[i].y = 140 + (i * 60);
				servers[i].posY = 140 + (i * 60);
				trace(i);
			}
		}
		
		override public function destroy():void 
		{ 
			client.removeEventListener(ServerListEvent.DATA, onListData);
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
		}
	}
}