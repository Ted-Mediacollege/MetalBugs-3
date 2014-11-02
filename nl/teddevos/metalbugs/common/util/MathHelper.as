package nl.teddevos.metalbugs.common.util {
	public class MathHelper 
	{
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