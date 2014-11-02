package nl.teddevos.metalbugs.client.world 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class ClientPickup extends Sprite
	{
		public var posX:Number;
		public var posY:Number;
		public var id:int;
		
		private var art:MovieClip;
		
		public function ClientPickup(world:WorldClient, px:Number, py:Number, i:int) 
		{
			posX = px;
			posY = py;
			id = i;
			
			x = world.cameraX + posX;
			y = world.cameraY + posY;
			
			var art:MovieClip = new Collectable1();
			addChild(art);
		}
		
		public function tick(world:WorldClient):void
		{
			x = world.cameraX + posX;
			y = world.cameraY + posY;
		}
	}
}