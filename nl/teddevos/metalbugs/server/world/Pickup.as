package nl.teddevos.metalbugs.server.world 
{
	public class Pickup 
	{
		public var posX:Number;
		public var posY:Number;
		public var id:int;
		
		public function Pickup(i:int, x:Number, y:Number) 
		{
			posX = x;
			posY = y;
			id = i;
		}
	}
}