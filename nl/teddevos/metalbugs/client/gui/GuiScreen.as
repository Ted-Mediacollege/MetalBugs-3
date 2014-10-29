package nl.teddevos.metalbugs.client.gui 
{
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.client.Client;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	
	public class GuiScreen extends Sprite
	{
		protected var client:Client;
		public var buttonList:Vector.<GuiButton>;
		
		public function init():void { }
		public function tick():void { }
		public function action(b:GuiButton):void { }
		public function destroy():void { }
		
		public function preInit(c:Client):void
		{
			buttonList = new Vector.<GuiButton>();
			client = c;
		}
		
		public function checkButtons(posX:int, posY:int):void
		{
			for (var i:int = 0; i < buttonList.length; i++ )
			{
				if (posX > buttonList[i].posX &&
					posY > buttonList[i].posY && 
					posX < buttonList[i].posX + buttonList[i].box[0] && 
					posY < buttonList[i].posY + buttonList[i].box[1] )
				{
					action(buttonList[i]);
					break;
				}
			}
		}
	}
}