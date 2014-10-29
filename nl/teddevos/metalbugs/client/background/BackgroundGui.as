package nl.teddevos.metalbugs.client.background 
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Shape;
	
	public class BackgroundGui extends Sprite
	{
		public var art:MovieClip;
		private var background:Background;
		public var topMask:Shape;
		private var inside:Boolean;
		
		public var lightVelocity:Number;
		public var lightDirection:Number;
		
		public var light:Boolean = true;
		public var nextTime:int = 15;
			
		public function BackgroundGui() 
		{
			background = new Background();
			background.x = -170;
			background.y = -240;
			addChild(background);
			
			art = new Characters();
			addChild(art);
			art.gotoAndStop(1);
			
			respawn(true);
			
			addEventListener(Event.ENTER_FRAME, tick);
			
			topMask = new Shape();
			addChild(topMask);
			this.mask = topMask;
		}
		
		public function tick(e:Event):void
		{
			art.x = nextX(art.x, art.rotation, 1.5);
			art.y = nextY(art.y, art.rotation, 1.5);
			
			if (lightDirection > 0)
			{
				lightVelocity -= 3;
			}
			else
			{
				lightVelocity += 3;
			}
			lightDirection += lightVelocity;
			
			if (!light)
			{
				if (Math.random() * 3 < 2)
				{
					light = true;
					
					if (Math.random() * 3 < 1)
					{
						nextTime = int(Math.random() * 70) + 50;
					}
					else
					{
						if (Math.random() * 3 < 2)
						{
							nextTime = int(Math.random() * 10);
						}
						else
						{
							nextTime = int(Math.random() * 3);
						}
					}
				}
			}
			
			nextTime--;
			if (nextTime < 0)
			{
				light = false;
			}
			
			if (dis2(art.x, art.y, 400, 400) > 600)
			{
				if (inside)
				{
					respawn();
				}
			}
			else
			{
				inside = true;
			}
			
			topMask.graphics.clear();
			
			if (light)
			{
				drawLight(art.x, art.y, art.rotation + lightDirection / 16);
			}
		}
		
		public function close():void
		{
			removeEventListener(Event.ENTER_FRAME, tick);
		}
		
		public function respawn(first:Boolean = false):void
		{
			inside = false;
			
			var randDirection:Number = -180 + (Math.random() * 360);
			
			art.x = nextX(400, randDirection, first ? 480 : 970);
			art.y = nextY(400, randDirection, first ? 480 : 970);
			art.rotation = pointToDegree(art.x, art.y, 400, 400) - 15 + Math.random() * 30;
			art.gotoAndStop(1 + int(Math.random() * 8));
			
			lightDirection = 0;
			lightVelocity = 4;
		}
		
		public function drawLight(px:int, py:int, d:Number):void
		{
			topMask.graphics.beginFill(0x000000, 1);
			topMask.graphics.drawCircle(nextX(px, d, 50), nextY(py, d, 50), 60);
			topMask.graphics.drawCircle(nextX(px, d, 290), nextY(py, d, 290), 120);
			var vecs:Vector.<Number> = new Vector.<Number>(8);
			vecs[0] = nextX(nextX(px, d, 42), d - 90, 60);
			vecs[2] = nextX(nextX(px, d, 275), d - 90, 120);
			vecs[4] = nextX(nextX(px, d, 275), d + 90, 120);
			vecs[6] = nextX(nextX(px, d, 42), d + 90, 60);
			vecs[1] = nextY(nextY(py, d, 42), d - 90, 60);
			vecs[3] = nextY(nextY(py, d, 275), d - 90, 120);
			vecs[5] = nextY(nextY(py, d, 275), d + 90, 120);
			vecs[7] = nextY(nextY(py, d, 42), d + 90, 60);
			topMask.graphics.moveTo(vecs[6], vecs[7]);
			for (var i:int = 0; i < 8; i+=2 )
			{
				topMask.graphics.lineTo(vecs[i], vecs[1 + i]);
			}
			topMask.graphics.endFill();
		}
		
		public static function nextX(x:Number, direction:Number, speed:Number):Number 
		{
			return x + (speed * Math.cos(direction * Math.PI / 180.0));
		}

		public static function nextY(y:Number, direction:Number, speed:Number):Number 
		{
			return y + (speed * Math.sin(direction * Math.PI / 180.0));
		}
		
		public static function dis2(x1:Number, y1:Number, x2:Number, y2:Number):Number 
		{
			return Math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
		}
		
		public static function pointToDegree(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return Math.atan2((y2 - y1), (x2 - x1)) * 180 / Math.PI;
		}
	}
}