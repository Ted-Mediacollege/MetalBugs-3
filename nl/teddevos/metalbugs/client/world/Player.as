package nl.teddevos.metalbugs.client.world 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
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
			
			art = new Characters();
			addChild(art);
			art.gotoAndStop(evolution);
			
			art.rotation = posD;
		}
		
		public function tick(cX:Number, cY:Number):void
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
			
			x = cX + posX;
			y = cY + posY;
			rotation = posD;
		}
		
		public function playerUpdate(s:String):void
		{
			var a:Array = s.split(";");
			
			posX = Number(parseFloat(a[0]));
			posY = Number(parseFloat(a[1]));
			posD = Number(parseFloat(a[2]));
			posS = Number(parseFloat(a[3]));
			evolution = int(parseInt(a[4]));
			light = String(a[5]) == "true" ? true : false;
		}
	}
}