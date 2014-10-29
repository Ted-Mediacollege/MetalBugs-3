package nl.teddevos.metalbugs.client.gui.components 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class GuiText extends Sprite
	{
		public var tf:TextField;
		public var fo:TextFormat;
		
		public function GuiText(px:int, py:int, s:int, c:uint, a:String, font:String = "Arial") 
		{
			fo = new TextFormat();
			fo.size = s;
			fo.align = a;
			fo.color = c;
			fo.font = font;
			
			tf = new TextField();
			tf.x = px;
			tf.y = py;
			tf.width = 800;
			tf.setTextFormat(fo);
			tf.selectable = false;
			
			if (fo.align == "center") 
			{ 
				tf.x = tf.x - (tf.width / 2); 
			}
			else 
			{
				tf.x = tf.x; 
			}
			
			addChild(tf);
		}	
		
		public function setText(s:String):void
		{
			tf.text = s;
			tf.setTextFormat(fo);
		}
		
		public function setColor(c:uint):void
		{
			fo.color = c;
			tf.setTextFormat(fo);
		}
	}
}