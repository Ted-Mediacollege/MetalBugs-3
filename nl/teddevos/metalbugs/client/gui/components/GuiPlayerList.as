package nl.teddevos.metalbugs.client.gui.components 
{
	import flash.display.Sprite;
	import nl.teddevos.metalbugs.Main;
	
	public class GuiPlayerList extends Sprite
	{
		private var playerList:Vector.<GuiPlayerListPlayer>;
		private var max:int;
		
		public function GuiPlayerList() 
		{
			playerList = new Vector.<GuiPlayerListPlayer>();
			
			var text_name:GuiText = new GuiText(0, 0, 20, 0xFFFFFF, "left");
			var text_score:GuiText = new GuiText(460, 0, 20, 0xFFFFFF, "left");
			var text_ping:GuiText = new GuiText(590, 0, 20, 0xFFFFFF, "left");
			var text_ready:GuiText = new GuiText(690, 0, 20, 0xFFFFFF, "left");
			
			text_name.setText("PLAYER");
			text_score.setText("SCORE");
			text_ping.setText("PING");
			text_ready.setText("READY");
			
			max = Main.client.connection.maxPlayers;
			
			addChild(text_name);
			addChild(text_score);
			addChild(text_ping);
			addChild(text_ready);
			
			if (max > 8)
			{
				scaleY = 390 / (48.75 * max);
			}
		}
		
		public function update(list:String):void
		{
			var a:Array = list.split("#");
			var l:int = 0;
			var al:int = a.length;
			var sortAgain:Boolean = false;
			
			l = playerList.length;
			if (l == 0)
			{
				for (var ai2:int = 0; ai2 < 1; ai2++)
				{
					var info3:Array = a[ai2].split(";");
					var plp2:GuiPlayerListPlayer = new GuiPlayerListPlayer(info3[0], parseInt(info3[1]), parseInt(info3[2]), parseInt(info3[3]), parseInt(info3[4]), parseInt(info3[5]));
					playerList.push(plp2);
					addChild(plp2);
					sortAgain = true;
				}
			}
			
			for (var ai:int = 0; ai < al; ai++)
			{
				var lastRank:int = -1;
				var place:int = -1;
				var f:Boolean = false;
				
				l = playerList.length;
				var info:Array = a[ai].split(";");
				
				for (var pi:int = 0; pi < l; pi++)
				{
					lastRank = playerList[pi].rank;
					
					if (info[0] == playerList[pi].playerName)
					{
						playerList[pi].update(parseInt(info[2]), parseInt(info[3]));
						playerList[pi].updated = true;
						lastRank = playerList[pi].rank;
						break;
					}
					
					if (lastRank > parseInt(info[5]) && !f)
					{
						place = pi;
						f = true;
					}

					if (pi == l - 1)
					{
						var plp:GuiPlayerListPlayer = new GuiPlayerListPlayer(info[0], parseInt(info[1]), parseInt(info[2]), parseInt(info[3]), parseInt(info[4]), parseInt(info[5]));
						
						if (place == -1)
						{
							playerList.push(plp);
						}
						else
						{
							playerList.splice(place, 0, plp);
						}
						
						addChild(plp);
						sortAgain = true;
						break;
					}
				}
			}
			
			l = playerList.length;
			for (var pi2:int = l - 1; pi2 > -1; pi2--)
			{
				if (playerList[pi2].updated == false)
				{
					removeChild(playerList[pi2]);
					playerList.splice(pi2, 1);
					sortAgain = true;
				}
				else
				{
					playerList[pi2].updated = false;
				}
			}
			
			if (sortAgain)
			{
				l = playerList.length;
				for (var pi3:int = 0; pi3 < l; pi3++)
				{
					playerList[pi3].y = 30 + (pi3 * 45);
				}
			}
			
			l = playerList.length;
			graphics.clear();
			for (var ov:int = l; ov < max; ov++ )
			{
				graphics.lineStyle(0, 0x444444, 0);
				graphics.beginFill(0x444444, 0.5);
				graphics.drawRect(0, 30 + (ov * 45), 760, 40);
			}
		}
	}
}