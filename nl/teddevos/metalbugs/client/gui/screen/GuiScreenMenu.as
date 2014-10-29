package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.components.GuiTextInput;
	import nl.teddevos.metalbugs.client.data.SaveData;
	
	public class GuiScreenMenu extends GuiScreen
	{
		private var inputField:GuiTextInput;
		
		public function GuiScreenMenu() 
		{
			
		}
		
		override public function init():void
		{
			var title:GuiText = new GuiText(400, 80, 55, 0xFFFFFF, "center");
			title.setText("MetalBugs Multiplayer");
			addChild(title);
			
			var info:GuiText = new GuiText(400, 150, 15, 0xFFFFFF, "center");
			info.setText("Multiplayer ports: 843, 2020-2030 UDP and TCP");
			addChild(info);
			
			var button_host:GuiButton = new GuiButton(0, 275, 250, 50, 250, 0x222222);
			button_host.setText("Host Game", 35, 0xFFFFFF);
			buttonList.push(button_host);
			addChild(button_host);
			
			var button_join:GuiButton = new GuiButton(1, 275, 335, 50, 250, 0x222222);
			button_join.setText("Join Game", 35, 0xFFFFFF);
			buttonList.push(button_join);
			addChild(button_join);
			
			var button_direct:GuiButton = new GuiButton(2, 275, 415, 50, 250, 0x222222);
			button_direct.setText("Direct Connect", 35, 0xFFFFFF);
			buttonList.push(button_direct);
			addChild(button_direct);
			
			var help:GuiText = new GuiText(271, 530, 22, 0xFFFFFF, "left");
			help.setText("Player name:");
			addChild(help);
			
			graphics.lineStyle(3, 0xFFFFFF);
			graphics.drawRect(275, 565, 250, 40);
			
			inputField = new GuiTextInput(280, 565, 30, 0xFFFFFF, "left", 15, "a-zA-Z0-9_ ");
			inputField.setText(SaveData.playerName);
			addChild(inputField);
		}
		
		override public function action(b:GuiButton):void
		{
			if (inputField.tf.text.length == 0)
			{
				inputField.tf.text = "Guy" + (int(Math.random() * 89999) + 10000);
			}
			SaveData.playerName = inputField.tf.text;
			
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenConnect("127.0.0.1", false, true));
			}
			else if (b.id == 1)
			{
				client.switchGui(new GuiScreenServerList());
			}
			else if (b.id == 2)
			{
				client.switchGui(new GuiScreenDirectConnect(SaveData.lastIP));
			}
		}
	}
}