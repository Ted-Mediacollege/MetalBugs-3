package nl.teddevos.metalbugs.client.network.serverlist 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import nl.teddevos.metalbugs.common.PHPdatabase;
	import nl.teddevos.metalbugs.Main;
	
	public class ServerListRequest 
	{
		public static var loading:Boolean = false;
		public static var loader:URLLoader;
		
		public static function requestData():void
		{
			if (!loading)
			{
				loading = true;
				
				try
				{
					loader = new URLLoader;
					var urlreq:URLRequest = new URLRequest(PHPdatabase.CLIENT_REQ);
					var urlvars: URLVariables = new URLVariables;
					loader.dataFormat = URLLoaderDataFormat.TEXT;
					loader.addEventListener(Event.COMPLETE, onListData);
					loader.load(urlreq);				
				}
				catch (e:Error)
				{
				}
			}
		}
		
		private static function onListData(e:Event):void
		{
			if (loading)
			{
				try
				{
					var reciever:URLLoader = URLLoader(e.target);
					var s:String = reciever.data;		
					
					Main.client.dispatchEvent(new ServerListEvent(ServerListEvent.DATA, true, s));
				}
				catch (e:Error)
				{
					Main.client.dispatchEvent(new ServerListEvent(ServerListEvent.DATA, false, ""));
				}
				
				loader.removeEventListener(Event.COMPLETE, onListData);
				loading = false;
			}
		}
		
		public static function cancel():void
		{
			if (loading)
			{
				loading = false;
			}
		}
	}
}