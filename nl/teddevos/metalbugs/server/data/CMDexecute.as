package nl.teddevos.metalbugs.server.data 
{
	public class CMDexecute 
	{
		import nl.teddevos.metalbugs.Main;
		import nl.teddevos.metalbugs.common.NetworkID;
		
		public static function Execute(s:String):void
		{
			var cmd:Array = s.split(";");
			for (var i:int = cmd.length - 1; i > -1; i-- )
			{
				cmd[i] = String(cmd[i]).toLowerCase();
			}
			
			//commands zijn disabled omdat ted te lui is om een functie te maken die kijkt of een client met clientID x wel bestaat.
			//en de reason van kick te fixen.
			//en de weergave van naam in serverLog (probably omdat de player is gekikt en dan de default uit clients array wordt gehaald)
			
			/*
			if (cmd[0] == "mute")
			{
				var id1:int = int(parseInt(cmd[1]));
				if (Main.server.clientManager.clients.length <= id1 || Main.server.clientManager.clients[id1] == null || Main.server.clientManager.clients[id1].disconnected) { return; }
				Main.server.clientManager.clients[id1].muted = true;
				ServerLog.addMessage("Host muted " + Main.server.clientManager.clients[id1].playerName);
			}
			else if (cmd[0] == "unmute")
			{
				var id2:int = int(parseInt(cmd[1]));
				if (Main.server.clientManager.clients[id2] == null || Main.server.clientManager.clients[id2].disconnected) { return; }
				Main.server.clientManager.clients[id2].muted = false;
				ServerLog.addMessage("Host unmuted " + Main.server.clientManager.clients[id1].playerName);
			}
			else if (cmd[0] == "kick")
			{
				var id3:int = int(parseInt(cmd[1]));
				if (Main.server.clientManager.clients[id3] == null || Main.server.clientManager.clients[id3].disconnected) { return; }
				Main.server.clientManager.sendTCP(Main.server.clientManager.clients[id3], NetworkID.SERVER_KICK, cmd.length == 3 ? cmd[2] : "None");
				ServerLog.addMessage("Host kicked " + Main.server.clientManager.clients[id1].playerName);
			}
			*/
		}
	}
}