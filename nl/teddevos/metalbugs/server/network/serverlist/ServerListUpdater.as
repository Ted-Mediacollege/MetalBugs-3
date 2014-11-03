package nl.teddevos.metalbugs.server.network.serverlist 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import nl.teddevos.metalbugs.server.data.ServerLog;
	import nl.teddevos.metalbugs.common.PHPdatabase;
	import nl.teddevos.metalbugs.Main;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	public class ServerListUpdater 
	{
		public static var firstMessage:Boolean;
		
		public static function update(first:Boolean):void
		{
			if (Main.hosting)
			{
				firstMessage = first;
				
				try 
				{
					var ipLocal:String = Main.server.localIP.replace(new RegExp(/([.]+)/g), "D");
					var serverName:String = Main.server.serverName.replace(new RegExp(/ /g), "_");
					
					var loader:URLLoader = new URLLoader;
					var urlreq:URLRequest = new URLRequest(PHPdatabase.SERVER_SEND + "/?s=1&l=" + ipLocal + "&n=" + serverName);
					var urlvars: URLVariables = new URLVariables;
					loader.dataFormat = URLLoaderDataFormat.TEXT;
					loader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, secError);
					loader.load(urlreq);					
				}
				catch (e:Error)
				{
					trace("[SERVER]: Failed to contact main server.");
				}
			}
		}	
		
		private static function ioError(e:IOErrorEvent):void
		{
			if (firstMessage)
			{
				ServerLog.addMessage("[SERVER]: cannot send info to main server, your server won't be visible on the serverlist.");
			}
		}
		
		private static function secError(e:SecurityErrorEvent):void
		{
			if (firstMessage)
			{
				ServerLog.addMessage("[SERVER]: cannot send info to main server, your server won't be visible on the serverlist.");
			}
		}
	}
}