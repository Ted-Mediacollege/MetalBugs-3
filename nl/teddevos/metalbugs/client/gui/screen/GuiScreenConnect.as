package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.NetworkID;
	import nl.teddevos.metalbugs.client.network.connection.ServerTCPdataEvent;
	import nl.teddevos.metalbugs.client.network.connection.Connection;
	import nl.teddevos.metalbugs.client.data.SaveData;
	import nl.teddevos.metalbugs.client.gui.components.GuiTextInput;
	
	public class GuiScreenConnect extends GuiScreen
	{
		private var hosting:Boolean = false;
		private var ipaddress:String;
		private var connectText:GuiText;
		private var errorText:GuiText;
		private var frameDelay:Boolean = false;
		private var killed:Boolean = false;
		private var direct:Boolean = false;
		
		private var hostText:GuiText;
		private var inputField:GuiTextInput;
		private var connecting:Boolean;
		private var button_host:GuiButton;
		
		public function GuiScreenConnect(ip:String, d:Boolean, h:Boolean = false) 
		{
			hosting = h
			ipaddress = ip;
			direct = d;
		}
		
		override public function init():void
		{
			client.addEventListener(ServerTCPdataEvent.DATA, onTCPdata);
			
			if (hosting)
			{
				hostText = new GuiText(400, 295, 25, 0xFFFFFF, "center");
				hostText.setText("Server name?");
				addChild(hostText);
				
				inputField = new GuiTextInput(230, 340, 30, 0xFFFFFF, "left", 25, "a-zA-Z0-9_ ");
				if (SaveData.serverName.length == 0)
				{
					inputField.setText(SaveData.playerName + "s server");
					SaveData.serverName = SaveData.playerName + "s server";
				}
				else
				{
					inputField.setText(SaveData.serverName);
				}
				addChild(inputField);
				
				graphics.lineStyle(3, 0xFFFFFF);
				graphics.drawRect(225, 340, 350, 40);
				
				button_host = new GuiButton(1, 275, 440, 50, 250, 0x222222);
				button_host.setText("Host Game", 35, 0xFFFFFF);
				buttonList.push(button_host);
				addChild(button_host);
				
				connecting = false;
			}
			else
			{
				connectText = new GuiText(400, 295, 20, 0xFFFFFF, "center");
				connectText.setText("Connecting to " + ipaddress);
				addChild(connectText);
				
				errorText = new GuiText(400, 335, 20, 0xFFFFFF, "center");
				errorText.setText("");
				addChild(errorText);
				
				var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x222222);
				button_menu.setText("Cancel", 35, 0xFFFFFF);
				buttonList.push(button_menu);
				addChild(button_menu);
			}
		}
		
		override public function tick():void 
		{ 
			if (hosting)
			{
				if (connecting && Main.client.connection.failed)
				{
					hostText.setText("Failed to create server!");
					if (client.connection.socketTCP.connected)
					{
						client.connection.kill();
					}
					Main.killServer();
					connecting = false;
					
					var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x222222);
					button_menu.setText("Back to menu", 35, 0xFFFFFF);
					buttonList.push(button_menu);
					addChild(button_menu);
				}
			}
			else
			{
				if (!frameDelay)
				{
					frameDelay = true;
					Main.client.connection = new Connection();
					Main.client.connection.connect(ipaddress);
				}

				if (Main.client.connection.failed && !killed)
				{
					killed = true;
					connectText.setText("Connection failed!");
					errorText.setText("Reason: " + Main.client.connection.error);
					client.connection.kill();
				}
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (hosting)
			{
				if (b.id == 0)
				{
					client.switchGui(new GuiScreenMenu());
				}
				else if (b.id == 1)
				{	
					if (inputField.tf.text.length == 0)
					{
						inputField.tf.text = SaveData.playerName + " server";
						SaveData.serverName = inputField.tf.text;
					}
					
					graphics.clear();
					removeChild(inputField);
					button_host.enabled = false;
					removeChild(button_host);
					
					hostText.setText("Creating server... ");		
					Main.startServer(inputField.tf.text);
					Main.client.connection = new Connection();
					Main.client.connection.connect("127.0.0.1");
					connecting = true;
				}
			}
			else
			{
				if (b.id == 0)
				{
					if (!killed)
					{
						client.connection.kill();
					}
					
					if (direct)
					{
						client.switchGui(new GuiScreenDirectConnect(ipaddress));
					}
					else
					{
						client.switchGui(new GuiScreenServerList());
					}
				}
			}
		}
		
		public function onTCPdata(e:ServerTCPdataEvent):void
		{
			if (hosting)
			{
				if (e.id == NetworkID.TCP_SERVER_WELCOME)
				{
					var qq:Array = e.data.split("#");
					client.connection.serverName = qq[1];
					client.connection.maxPlayers = int(parseInt(qq[2]));
					client.connection.playerID = parseInt(qq[0]);
					hostText.setText("Sending data...");
					client.connection.sendTCP(NetworkID.TCP_CLIENT_INFO_UPDATE, SaveData.playerName + "");
				}
				else if (e.id == NetworkID.TCP_SERVER_ACCEPT)
				{
					client.switchGui(new GuiScreenLobby(true, e.data));
				}
			}
			else
			{
				if (e.id == NetworkID.TCP_SERVER_WELCOME)
				{
					var q:Array = e.data.split("#");
					client.connection.serverName = q[1];
					client.connection.maxPlayers = int(parseInt(q[2]));
					client.connection.playerID = parseInt(q[0]);
					connectText.setText("Sending data...");
					client.connection.sendTCP(NetworkID.TCP_CLIENT_INFO_UPDATE, SaveData.playerName + "");
				}
				else if (e.id == NetworkID.TCP_SERVER_ACCEPT)
				{
					client.switchGui(new GuiScreenLobby(false, e.data));
				}
				else if (e.id == NetworkID.TCP_SERVER_REJECT_FULL)
				{
					killed = true;
					connectText.setText("Cannot join game!");
					errorText.setText("Reason: Server is full!");
					client.connection.kill();
				}
				else if (e.id == NetworkID.TCP_SERVER_REJECT_PLAYING)
				{
					killed = true;
					connectText.setText("Cannot join game!");
					errorText.setText("Reason: Cannot join during game!");
					client.connection.kill();
				}
				else if (e.id == NetworkID.TCP_SERVER_REJECT_NAME)
				{
					killed = true;
					connectText.setText("Cannot join game!");
					errorText.setText("Reason: Name already in use!");
					client.connection.kill();
				}
			}
		}
		
		override public function destroy():void
		{
			client.removeEventListener(ServerTCPdataEvent.DATA, onTCPdata);
		}
	}
}