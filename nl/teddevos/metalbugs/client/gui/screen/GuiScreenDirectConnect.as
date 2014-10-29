package nl.teddevos.metalbugs.client.gui.screen 
{
	import nl.teddevos.metalbugs.client.gui.GuiScreen;
	import nl.teddevos.metalbugs.client.gui.components.GuiText;
	import nl.teddevos.metalbugs.client.gui.components.GuiTextInput;
	import nl.teddevos.metalbugs.client.gui.components.GuiButton;
	import nl.teddevos.metalbugs.client.data.SaveData;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class GuiScreenDirectConnect extends GuiScreen
	{
		private var inputField:GuiTextInput;
		private var oldIP:String;
		
		public function GuiScreenDirectConnect(ip:String = "256.256.256.256") 
		{
			oldIP = ip;
		}
		
		override public function init():void
		{
			client.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			var title:GuiText = new GuiText(400, 140, 45, 0xFFFFFF, "center");
			title.setText("Direct Connect");
			addChild(title);
			
			var help:GuiText = new GuiText(400, 295, 20, 0xFFFFFF, "center");
			help.setText("Enter host ip, example: 127.0.0.1");
			addChild(help);
			
			graphics.lineStyle(3, 0xFFFFFF);
			graphics.drawRect(275, 345, 250, 40);
			
			inputField = new GuiTextInput(280, 345, 30, 0xFFFFFF, "left", 15, "0-9.");
			inputField.setText("" + oldIP);
			addChild(inputField);
			
			var button_join:GuiButton = new GuiButton(0, 275, 400, 50, 250, 0x222222);
			button_join.setText("Join", 35, 0xFFFFFF);
			buttonList.push(button_join);
			addChild(button_join);
			
			var button_menu:GuiButton = new GuiButton(1, 275, 650, 50, 250, 0x222222);
			button_menu.setText("Back to menu", 35, 0xFFFFFF);
			buttonList.push(button_menu);
			addChild(button_menu);
		}
		
		override public function tick():void 
		{ 
		}
		
		override public function action(b:GuiButton):void 
		{ 
			if (b.id == 0)
			{
				SaveData.lastIP = inputField.tf.text;
				client.switchGui(new GuiScreenConnect(inputField.tf.text, true, false));
			}
			if (b.id == 1)
			{
				client.switchGui(new GuiScreenMenu());
			}
		}
		
		public function onKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				SaveData.lastIP = inputField.tf.text;
				client.switchGui(new GuiScreenConnect(inputField.tf.text, true, false));
			}
		}
		
		override public function destroy():void
		{
			client.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
	}
}