package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.components.GuiChat;
	import nl.teddevos.metalbugs.client.gui.components.GuiPlayerList;
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.client.network.connection.Connection;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class GuiScreenLobby extends GuiScreen
	{
		private var playerList:GuiPlayerList;
		private var chatbox:GuiChat;
		private var hosting:Boolean;
		private var ready:Boolean = false;
		private var button_ready:GuiButton;
		private var ip_text:GuiText;
		
		public function GuiScreenLobby(host:Boolean, pl:String) 
		{
			hosting = host;

			playerList = new GuiPlayerList();
			playerList.update(pl);
			playerList.x = 20;
			playerList.y = 130;
			addChild(playerList);
			
			chatbox = new GuiChat();
			chatbox.x = 20;
			chatbox.y = 585;
			addChild(chatbox);
		}
		
		override public function init():void
		{
			if (hosting)
			{
				var title:GuiText = new GuiText(400, 20, 35, 0xFFFFFF, "center");
				title.setText("Lobby - " + client.connection.serverName);
				addChild(title);
				
				ip_text = new GuiText(400, 70, 20, 0xCCCCCC, "center");
				ip_text.setText("Server running on ip: ?");
				addChild(ip_text);
			}
			else
			{
				var title2:GuiText = new GuiText(400, 50, 35, 0xFFFFFF, "center");
				title2.setText("Lobby - " + client.connection.serverName);
				addChild(title2);
			}
			
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			button_ready = new GuiButton(1, 20, 525, 50, 150, 0xFF7777);
			button_ready.setText("Ready", 35, 0xFFFFFF);
			buttonList.push(button_ready);
			addChild(button_ready);
			
			var button_menu:GuiButton = new GuiButton(0, 190, 525, 50, 250, 0x333333);
			button_menu.setText("Back to menu", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
		}
		
		override public function tick():void 
		{ 
			if (!Main.client.connection.socketTCP.connected)
			{
				client.switchGui(new GuiScreenLost("Lost connection to server!"));
			}
			
			if (hosting)
			{
				if (Main.server.localIPfound)
				{
					ip_text.setText("Server running on ip: " + Main.server.localIP);
				}
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenKill(hosting));
			}
			else if (b.id == 1)
			{
				ready = !ready;
				client.connection.sendQuickUDP(NetworkID.QUICK_CLIENT_READY, ready ? 1 + "" : 0 + "");
				button_ready.updateBoxColor(ready ? 0x77FF77 : 0xFF7777);
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (e.id == NetworkID.QUICK_SERVER_LIST_UPDATE)
			{
				playerList.update(e.data);
			}
			else if (e.id == NetworkID.QUICK_SERVER_CHAT_UPDATE)
			{
				chatbox.chatSync(e.data);
			}
			else if (e.id == NetworkID.TCP_SERVER_KICK && !hosting)
			{
				client.switchGui(new GuiScreenLost("You have been kicked by the host, Reason: " + e.data));
			}
			else if (e.id == NetworkID.TCP_SERVER_END && !hosting)
			{
				client.switchGui(new GuiScreenLost("Host quit the game!"));
			}
			else if (e.id == NetworkID.TCP_SERVER_PREPARE)
			{
				client.switchGui(new GuiScreenPrepare(hosting));
			}
		}
		
		public function updatePlayerList(playerString:String):void
		{
			
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			client.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				chatbox.send();
			}
		}
	}
}