package nl.teddevos.metalbugs.client.world 
{
	import nl.teddevos.metalbugs.Main;
	import nl.teddevos.metalbugs.common.util.MathHelper;
	import nl.teddevos.metalbugs.common.NetworkID;
	
	public class ClientPlayer extends Player
	{
		public var sendDelay:int;
		public var mX:Number;
		public var mY:Number;
		public var lastGrow:Number;
		
		public function ClientPlayer(i:int, p:String, x:Number, y:Number, d:Number, s:Number, e:int, l:Boolean) 
		{
			super(i, p, x, y, d, s, e, l);
			mX = Main.main.mouseX;
			mY = Main.main.mouseY;
			sendDelay = 15;
			lastGrow = 0;
		}
		
		override public function tick(world:WorldClient):void
		{	
			mX = Main.main.mouseX;
			mY = Main.main.mouseY;
			
			posS = MathHelper.dis2(x, y, mX, mY) / 20;
			posS = posS > 3 - (evolution / 6) ? 3 - (evolution / 6) : posS;
			if (posS > 0.1)
			{
				posD = MathHelper.pointToDegree(x, y, mX, mY);
			}

			posX += (posS / 33) * world.time * Math.cos(posD * Math.PI / 180.0);
			posY += (posS / 33) * world.time * Math.sin(posD * Math.PI / 180.0);
			
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
			
			x = world.cameraX + posX;
			y = world.cameraY + posY;
			rotation = posD;
			smoothD = posD;
			
			sendDelay--;
			if (sendDelay < 0)
			{
				sendDelay += 8;
				Main.client.connection.sendGameUDP(NetworkID.GAME_CLIENT_PLAYER_UPDATE, world.gameTime + ";" + posX + ";" + posY + ";" + posD + ";" + posS + ";" + evolution + ";" + light);
			}
		}
		
		override public function playerUpdate(world:WorldClient, t:Number, s:String):void
		{
		}
	}
}