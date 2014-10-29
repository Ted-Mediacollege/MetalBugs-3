package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.Connection;
	
	public class GuiScreenLost extends GuiScreen
	{
		private var connectText:GuiText;
		private var reason:String;
		private var frame:int;
		
		public function GuiScreenLost(r:String) 
		{
			reason = r;
			frame = 4;
		}
		
		override public function init():void
		{
			connectText = new GuiText(400, 295, 40, 0xFFFFFF, "center");
			connectText.setText("Losing connection...");
			addChild(connectText);
		}
		
		override public function tick():void 
		{ 
			if (frame > -1)
			{
				frame--;
				if (frame == 2)
				{
					if (Main.client.inWorld)
					{
						Main.client.endWorld();
					}
					
					if (Main.hosting)
					{
						Main.killServer();
					}
					
					Main.client.connection.kill();
				}
				else if (frame == 0)
				{
					connectText.setText(reason);
					
					var button_menu:GuiButton = new GuiButton(0, 275, 650, 50, 250, 0x333333);
					button_menu.setText("Back to menu", 35, 0xFFFFFF);
					buttonList.push(button_menu);
					addChild(button_menu);
				}
			}
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				client.switchGui(new GuiScreenMenu());
			}
		}
	}
}