package nl.teddevos.metalbugs 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.client.Client;
	import nl.teddevos.metalbugs.server.Server;
	import flash.events.Event;
	import nl.teddevos.metalbugs.client.data.SaveData;
	import nl.teddevos.metalbugs.client.input.Mouse;
	
	public class Main extends Sprite
	{
		public static var main:Main;
		
		public static var client:Client;
		public static var server:Server;
		
		public static var hosting:Boolean;
		
		public function Main() 
		{
			Mouse.init(this.stage);
			
			main = this;
			
			SaveData.playerName = "Guy" + (int(Math.random() * 89999) + 10000);
			
			client = new Client();
			addChild(client);
			
			stage.stageFocusRect = false;
			hosting = false;
			
			addEventListener(Event.ENTER_FRAME, tick);
			stage.addEventListener(Event.ACTIVATE, onFocus);
			stage.addEventListener(Event.DEACTIVATE, unFocus);
		}
		
		public function tick(e:Event):void
		{
			client.tick();
			
			if (hosting)
			{
				server.tick();
			}
		}
		
		public static function startServer(s:String):void
		{
			if (!hosting)
			{
				server = new Server(s);
				server.start();
				hosting = true;
			}
		}
		
		public static function killServer():void
		{
			if (hosting)
			{
				server.kill();
				server = null;
				hosting = false;
			}
		}
		
		private function onFocus(e:Event):void
		{
			stage.focus = client;
			stage.stageFocusRect = false;
		}
		
		private function unFocus(e:Event):void
		{
		}
	}
}