package nl.teddevos.metalbugs.client.world 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.Main;
	
	public class Player extends Sprite
	{
		public var id:int;
		public var playerName:String;
		
		public var posX:Number;
		public var posY:Number;
		public var posD:Number;
		public var posS:Number;
		public var evolution:int;
		public var light:Boolean;
		
		public var targetX:Number;
		public var targetY:Number;
		public var smoothD:Number;
		
		public var art:MovieClip;
		
		public function Player(i:int, p:String, x:Number, y:Number, d:Number, s:Number, e:int, l:Boolean) 
		{
			id = i;
			playerName = p;
			
			posX = x;
			posY = y;
			posD = d;
			posS = s;
			evolution = e;
			light = l;
			
			targetX = 0;
			targetY = 0;
			smoothD = posD;
			
			art = new Characters();
			addChild(art);
			art.gotoAndStop(evolution);
			
			art.rotation = posD;
		}
		
		public function tick(world:WorldClient):void
		{
			posX += posS * Math.cos(posD * Math.PI / 180.0);
			posY += posS * Math.sin(posD * Math.PI / 180.0);
			
			if (posX > 920)
			{
				posX = 920;
			}
			if (posY > 920)
			{
				posY = 920;
			}
			if (posX < -920)
			{
				posX = -920;
			}
			if (posY < -920)
			{
				posY = -920;
			}
			
			posX = (posX * 9 + targetX) / 10;
			posY = (posY * 9 + targetY) / 10;
			
			if (posD > 90 && smoothD < -90)
			{
				smoothD = (smoothD * 9 + (posD - 360)) / 10;
			}
			else if (posD < -90 && smoothD > 90)
			{
				smoothD = (smoothD * 9 + (posD + 360)) / 10;
			}
			else
			{
				smoothD = (smoothD * 9 + posD) / 10;
			}
			
			if (smoothD > 180)
			{
				smoothD -= 360;
			}
			if (smoothD < -180)
			{
				smoothD += 360;
			}
			
			x = world.cameraX + posX;
			y = world.cameraY + posY;
			rotation = smoothD;
		}
		
		public function playerUpdate(t:Number, s:String):void
		{
			var a:Array = s.split(";");
			
			targetX = Number(parseFloat(a[0]));
			targetY = Number(parseFloat(a[1]));
			posD = Number(parseFloat(a[2]));
			posS = Number(parseFloat(a[3]));
			evolution = int(parseInt(a[4]));
			light = String(a[5]) == "true" ? true : false;
			
			//targetX += (posS / 33) * (Main.client.world.gameTime - t) * Math.cos(posD * Math.PI / 180.0);
			//targetY += (posS / 33) * (Main.client.world.gameTime - t) * Math.sin(posD * Math.PI / 180.0);
		}	
	}
}