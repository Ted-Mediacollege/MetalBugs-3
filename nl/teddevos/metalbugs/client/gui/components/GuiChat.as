package nl.teddevos.metalbugs.client.gui.components 
{
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.NetworkID;
	
	public class GuiChat extends Sprite
	{
		private var textfields:Vector.<GuiText>;
		private var inputField:GuiTextInput;
		
		public function GuiChat() 
		{
			textfields = new Vector.<GuiText>();
			
			for (var i:int = 0; i < 8; i++ )
			{
				var g:GuiText = new GuiText(0, i * 20, 15, 0xFFFFFF, "left");
				g.setText("");
				addChild(g);
				textfields.push(g);
			}
			
			inputField = new GuiTextInput(0, 165, 15, 0xFFFFFF, "left", 50, "a-zA-Z0-9 ?!,./");
			inputField.setText(" ");
			addChild(inputField);
			
			graphics.clear();
			graphics.lineStyle(1, 0x666666, 0);
			graphics.beginFill(0x666666, 0.5);
			graphics.drawRect(0, 0, 760, 160);
			graphics.drawRect(0, 165, 760, 25);
		}
		
		public function send():void
		{
			if (inputField.tf.text.length > 0)
			{
				var f:String = inputField.tf.text.substr(0, 1);
				if (f == " ")
				{
					inputField.tf.text = inputField.tf.text.substr(1);
				}
				
				f = inputField.tf.text.substr(0, 1);
				if (f == "/")
				{
					inputField.tf.text = inputField.tf.text.substr(1);
					var a:Array = inputField.tf.text.split(" ");
					var s:String = "";
					for (var i:int = 0; i < a.length; i++ )
					{
						if (i == 0)
						{
							s += a[i];
						}
						else
						{
							s += ";" + a[i];
						}
					}
					Main.client.connection.sendQuickUDP(NetworkID.TCP_CLIENT_CMD, s);
					inputField.tf.text = "";
				}
				else
				{
					Main.client.connection.sendQuickUDP(NetworkID.QUICK_CLIENT_CHAT_NEW, inputField.tf.text);
					inputField.tf.text = "";
				}
			}
		}
		
		public function chatSync(s:String):void
		{
			var a:Array = s.split("#");
			var l:int = a.length;
			var c:int = 1;
			
			for (var i:int = 7; i > -1; i-- )
			{
				if (c <= l)
				{
					var b:Array = String(a[l - c]).split(";");
					textfields[i].setText(b[1]);
					c++;
				}
			}
		}
	}
}