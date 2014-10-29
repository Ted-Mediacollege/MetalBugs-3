package nl.teddevos.metalbugs.server.network.policy 
{
	import flash.geom.Point;
	import flash.net.ServerSocket;
	import flash.events.ServerSocketConnectEvent;
	import flash.events.ProgressEvent;
	import nl.teddevos.metalbugs.server.data.ServerLog;
	
	public class PolicyManager 
	{
		public var policySocket:ServerSocket;
		public var requests:Vector.<PolicyRequest>;
		
		public function PolicyManager(port:int = 843) 
		{
			ServerLog.addMessage("[NETWORK]: Setting up policy manager...");
			
			policySocket = new ServerSocket();
			policySocket.addEventListener(ServerSocketConnectEvent.CONNECT, onPolicyRequest);
			policySocket.bind(port);
			policySocket.listen();
			
			if (!policySocket.listening || !policySocket.bound)
			{
				ServerLog.addMessage("[WARNING]: Cannot setup policy manager on port " + port + "!");
			}
			
			requests = new Vector.<PolicyRequest>();
		}
		
		public function destroy():void
		{
			policySocket.removeEventListener(ServerSocketConnectEvent.CONNECT, onPolicyRequest);
			policySocket.close();
			
			for (var i:int = requests.length - 1; i > -1; i-- )
			{
				requests[i].forceClose();
				requests.splice(i, 1);
			}
		}
		
		public function onPolicyRequest(e:ServerSocketConnectEvent):void
		{
			requests.push(new PolicyRequest(e.socket));
		}
		
		public function tick():void
		{
			for (var i:int = requests.length - 1; i > -1; i-- )
			{
				if (requests[i].done)
				{
					requests.splice(i, 1);
				}
			}
		}
	}
}