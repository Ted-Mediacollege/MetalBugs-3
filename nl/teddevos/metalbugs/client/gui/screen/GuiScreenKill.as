package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.NetworkID;

	public class GuiScreenKill extends GuiScreen
	{
		private var hosting:Boolean;
		private var frame:int;
		
		public function GuiScreenKill(host:Boolean) 
		{
			hosting = host;
			frame = 4;
		}
		
		override public function init():void 
		{ 
			if (hosting)
			{
				var t:GuiText = new GuiText(400, 380, 30, 0xFFFFFF, "center");
				t.setText("Shutting down server... (might take a few seconds)");
				addChild(t);
			}
			else
			{
				var t2:GuiText = new GuiText(400, 380, 30, 0xFFFFFF, "center");
				t2.setText("Returning to main menu... (might take a few seconds)");
				addChild(t2);
			}
		}
		
		override public function tick():void 
		{ 
			if (frame > -1)
			{
				frame--;
				if (frame == 1)
				{
					if (hosting)
					{
						Main.server.clientManager.sendQuickUDPtoAll(NetworkID.TCP_SERVER_END, "end");
						Main.killServer();
					}
					client.connection.kill();
				}
				else if (frame == 0)
				{
					client.switchGui(new GuiScreenMenu());
				}
			}
		}
	}
}