package nl.teddevos.metalbugs.client.gui.components 
{
	public class GuiButtonServer extends GuiButton
	{
		public var remoteIP:String;
		public var localIP:String;
		public var useIP:String;
		public var serverName:String;
		private var ping:int;
		private var players:String;
		private var lobby:int;
		
		private var text_name:GuiText;
		private var text_lobby:GuiText;
		private var text_ping:GuiText;
		private var text_players:GuiText;
		
		public function GuiButtonServer(i:int, px:int, py:int, rip:String, lip:String, ip:String, n:String, pl:String, pi:int, lo:int) 
		{
			super(i, px, py, 50, 760, 0x555555);
			
			remoteIP = rip;
			localIP = lip;
			useIP = ip;
			serverName = n;
			ping = pi;
			players = pl;
			lobby = lo;
		
			text_name = new GuiText(px + 10, py + 10, 20, 0xFFFFFF, "left");
			text_name.setText(serverName);
			addChild(text_name);
			
			text_lobby = new GuiText(px + 440, py + 10, 20, lobby == 1 ? 0x00FF00 : 0xFF0000, "left");
			text_lobby.setText(lobby == 1 ? "IN LOBBY" : "IN GAME");
			addChild(text_lobby);
			
			text_players = new GuiText(px + 590, py + 10, 20, 0xFFFFFF, "left");
			text_players.setText(players);
			addChild(text_players);
			
			text_ping = new GuiText(px + 680, py + 10, 20, 0xFFFFFF, "left");
			text_ping.setText(ping + "ms");
			addChild(text_ping);
		}
	}
}