package nl.teddevos.metalbugs.server 
{
	import nl.teddevos.metalbugs.server.data.ServerLog;
	import nl.teddevos.metalbugs.server.network.policy.PolicyManager;
	import nl.teddevos.metalbugs.server.network.serverlist.ServerListUpdater;
	import nl.teddevos.metalbugs.server.network.connection.ClientManager;
	import nl.teddevos.metalbugs.server.world.WorldServer;
	
	public class Server 
	{
		private var policyManager:PolicyManager;
		public var clientManager:ClientManager;
		
		public var world:WorldServer;
		public var inWorld:Boolean;
		
		public var lastServerListUpdate:int;
		
		public var serverName:String = "Server Name";
		public var localIP:String = "127.0.0.1";
		public var localIPfound:Boolean = false;
		
		public function Server(s:String) 
		{
			serverName = s;
		}
		
		public function tick():void
		{
			clientManager.tick();
			if (inWorld)
			{
				world.tick();
			}
			
			if (localIPfound)
			{
				var d:Date = new Date();
				if (int(d.getMinutes()) != lastServerListUpdate)
				{
					if (lastServerListUpdate == -99)
					{
						ServerLog.addMessage("[SERVER]: Sending message to main server.");
					}
					lastServerListUpdate = int(d.getMinutes());
					
					ServerListUpdater.update();
				}
			}
		}
		
		public function start():void
		{
			ServerLog.init();
			ServerLog.addMessage("[SERVER]: starting server...");
			localIPfound = false;
			policyManager = new PolicyManager();
			clientManager = new ClientManager();
			lastServerListUpdate = -99;
		}
		
		public function kill():void
		{
			ServerLog.addMessage("[SERVER]: shutting down server...");
			policyManager.destroy();
			policyManager = null;
			clientManager.destroy();
			clientManager = null;
		}
		
		public function startWorld():void
		{
			inWorld = true;
			world = new WorldServer();
		}
		
		public function endWorld():void
		{
			if (inWorld)
			{
				inWorld = false;
				world.end();
				world = null;
			}
		}
	}
}