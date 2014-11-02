package nl.teddevos.metalbugs.common 
{
	public class NetworkID 
	{
		public static var PING:int = 900;							//X -
		public static var KEEP_ALIVE:int = 901;						//X -
		public static var LOCAL_IP_TEST:int = 902;					//X -
		
		//========== TCP ======================================
		
		//CLIENT
		public static var TCP_CLIENT_INFO_UPDATE:int = 100;			//X - name
		public static var TCP_CLIENT_CMD:int = 101;					//X - type;arg1;arg2;arg3...
		public static var TCP_CLIENT_READY:int = 102;				//X - 0=false 1=true
		
		//SERVER
		public static var TCP_SERVER_WELCOME:int = 100;				//X - playerID#serverName#maxplayers
		public static var TCP_SERVER_REJECT_FULL:int = 101;			//X - 
		public static var TCP_SERVER_REJECT_PLAYING:int = 102;		//X - 
		public static var TCP_SERVER_REJECT_NAME:int = 103;			//X - 
		public static var TCP_SERVER_ACCEPT:int = 104;				//X - player;id;ping;ready#player;id;ping;ready#player;id;ping;ready...
		public static var TCP_SERVER_KICK:int = 105;				//X - reason
		public static var TCP_SERVER_END:int = 106;					//X - 
		public static var TCP_SERVER_PREPARE:int = 107;				//X - 
		public static var TCP_SERVER_STARTTIME:int = 108;			//X - time
		public static var TCP_SERVER_PLAYERSPAWNS:int = 109;		//X - 1;name;X;Y;D;S;E;L#...
		public static var TCP_SERVER_GROW:int = 110;				//X - time
		
		//========== QUICK ====================================
		
		//CLIENT
		public static var QUICK_CLIENT_CHAT_NEW:int = 200;			//X - message
		public static var QUICK_CLIENT_READY:int = 201;				//X - 0=false 1=true
		
		//SERVER
		public static var QUICK_SERVER_LIST_UPDATE:int = 200;		//X - player;id;ping;ready#player;id;ping;ready#player;id;ping;ready...
		public static var QUICK_SERVER_CHAT_UPDATE:int = 201;		//X - id;message#id;message#id;message...
		
		//========== GAME =====================================
		
		//CLIENT
		public static var GAME_CLIENT_TIME_REQUEST:int = 300;		//X - gametime;starttime
		public static var GAME_CLIENT_PLAYER_UPDATE:int = 301;		//X - time;X;Y;D;S;E;L
		
		//SERVER
		public static var GAME_SERVER_TIME:int = 300;				//X - time(double);ping(half)
		public static var GAME_SERVER_UPDATE_PLAYERS:int = 301;		//X - time#0$X;Y;D;S;E;L#1$X;Y;D;S;E;L#...
		public static var GAME_SERVER_PICKUP_SPAWN:int = 302;		//X	- X;Y;ID
		public static var GAME_SERVER_PICKUP_DESTROY:int = 303;		//X - ID
		public static var GAME_SERVER_GROW:int = 304;				//X - time
		
		//========== RESP =====================================
		
		//CLIENT
		public static var RESP_CLIENT_REQUEST:int = 100;			//X - 
		
		//SERVER
		public static var RESP_SERVER_AWNSER:int = 100;				//X - 
	}
}