package nl.teddevos.metalbugs.client.gui.components 
{
	import flash.display.Sprite;
	
	public class GuiButton extends Sprite
	{
		public var text:GuiText;
		
		public var posX:int;
		public var posY:int;
		public var box:Vector.<int>;
		
		public var buttoncolor:int;
		public var id:int;
		public var enabled:Boolean;
		
		public function GuiButton(i:int, px:int, py:int, bh:int, bw:int, c:uint) 
		{
			posX = px;
			posY = py;
			box = new Vector.<int>(2);
			box[0] = bw;
			box[1] = bh;
			
			id = i;
			enabled = false;
			
			buttoncolor = c;
			graphics.clear();
			graphics.lineStyle(3, 0xFFFFFF);
			graphics.beginFill(buttoncolor);
			graphics.drawRoundRect(posX, posY, box[0], box[1], 0);
		}
		
		public function updateBoxColor(c:uint):void
		{
			buttoncolor = c;
			graphics.clear();
			graphics.lineStyle(3, 0xFFFFFF);
			graphics.beginFill(buttoncolor);
			graphics.drawRoundRect(posX, posY, box[0], box[1], 0);
		}
		
		public function setText(t:String, s:int, c:uint):void
		{
			text = new GuiText(posX + int(Math.floor(box[0] / 2)), posY, s, c, "center");
			text.setText(t);
			text.setColor(c);
			addChild(text);
		}
		
		public function updateText(t:String):void
		{
			if (text != null) 
			{
				text.setText(t);
			}
		}
	}
}