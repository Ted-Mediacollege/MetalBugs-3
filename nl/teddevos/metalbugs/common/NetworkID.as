package nl.teddevos.metalbugs.common 
{
	public class NetworkID 
	{
		public static var PING:int = 900;							//0 -
		public static var KEEP_ALIVE:int = 901;						//0 -
		public static var LOCAL_IP_TEST:int = 902;					//0 -
		
		//========== TCP ======================================
		
		//CLIENT
		public static var TCP_CLIENT_INFO_UPDATE:int = 100;			//0 - 
		public static var TCP_CLIENT_CMD:int = 101;					//0 - 
		
		//SERVER
		public static var TCP_SERVER_WELCOME:int = 100;				//0 - 
		public static var TCP_SERVER_REJECT_FULL:int = 101;			//0 - 
		public static var TCP_SERVER_REJECT_PLAYING:int = 102;		//0 - 
		public static var TCP_SERVER_REJECT_NAME:int = 103;			//0 - 
		public static var TCP_SERVER_ACCEPT:int = 104;				//0 - 
		public static var TCP_SERVER_KICK:int = 105;				//0 - 
		public static var TCP_SERVER_END:int = 106;					//0 - 
		public static var TCP_SERVER_PREPARE:int = 107;				//0 -
		
		//========== QUICK ====================================
		
		//CLIENT
		public static var QUICK_CLIENT_CHAT_NEW:int = 200;			//0 - 
		public static var QUICK_CLIENT_READY:int = 201;				//0 - 
		
		//SERVER
		public static var QUICK_SERVER_LIST_UPDATE:int = 200;		//0 - 
		public static var QUICK_SERVER_CHAT_UPDATE:int = 201;		//0 - 
		
		//========== GAME =====================================
		
		//CLIENT
		
		//SERVER
		
		//========== RESP =====================================
		
		//CLIENT
		public static var RESP_CLIENT_REQUEST:int = 100;			//0 - 
		
		//SERVER
		public static var RESP_SERVER_AWNSER:int = 100;				//0 - 
	}
}