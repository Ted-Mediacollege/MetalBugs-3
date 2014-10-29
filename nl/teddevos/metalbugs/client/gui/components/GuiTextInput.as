package nl.teddevos.metalbugs.client.gui.components 
{
	public class GuiTextInput extends GuiText
	{
		public function GuiTextInput(px:int, py:int, s:int, c:uint, a:String, max:int, inputs:String) 
		{
			super(px, py, s, c, a);
			tf.selectable = true;
			tf.type = "input";
			tf.maxChars = max; 
			tf.restrict = inputs;
		}
	}
}