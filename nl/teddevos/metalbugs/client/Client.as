package nl.teddevos.metalbugs.client 
{
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.client.background.BackgroundGui;
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.screen.GuiScreenMenu;
	import nl.teddevos.metalbugs.client.network.test.ConnectionTest;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.client.network.connection.Connection;
	import flash.display.Shape;
	
	public class Client extends Sprite
	{
		public var gui:GuiScreen;
		public var inWorld:Boolean = false;
		
		public var connection:Connection;
		public var connectionTester:ConnectionTest;
		
		public var backgroundGui:BackgroundGui;
		
		public function Client() 
		{
			backgroundGui = new BackgroundGui();
			addChild(backgroundGui);
			
			switchGui(new GuiScreenMenu());
			
			connectionTester = new ConnectionTest();
			
			var s:Shape = new Shape();
			addChild(s);
			s.graphics.beginFill(0xFFFFFF);
			s.graphics.drawRect(0, 0, 800, 800);
			mask = s;
		}
		
		public function tick():void
		{
			if (connection != null)
			{
				connection.tick();
			}
			gui.tick();
		}
		
		public function startWorld():void
		{
			
		}
		
		public function endWorld():void
		{
			
		}
		
		public function switchGui(g:GuiScreen):void
		{
			if (gui != null)
			{
				gui.destroy();
				removeChild(gui);
			}
			gui = g;
			addChild(gui);
			gui.preInit(this);
			Main.main.stage.focus = this;
			gui.init();
		}
	}
}