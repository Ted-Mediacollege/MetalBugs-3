package nl.teddevos.metalbugs.client.input 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import nl.teddevos.metalbugs.Main;
	
	public class Mouse 
	{
		public static var mouseX:int;
		public static var mouseY:int;
		public static var mouseDown:Boolean;
		
		public static function init(stage:Stage):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public static function onMouseDown(e:MouseEvent):void
		{
			mouseDown = true;
			if (Main.client.gui != null)
			{
				Main.client.gui.checkButtons(mouseX, mouseY);
			}
			
			if (Main.client.inWorld)
			{
				Main.main.stage.focus = Main.client;
			}
		}
		
		public static function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
		}
		
		public static function onMouseMove(e:MouseEvent):void
		{
			mouseX = e.stageX;
			mouseY = e.stageY;
		}
	}
}