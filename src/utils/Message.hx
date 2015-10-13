package src.utils;

import js.JQuery;
import jp.saken.utils.Dom;
import jp.saken.utils.Ajax;

class Message {
	
	public static var normal:Map<String,String>;
	public static var first :Map<String,String>;
	
	private static var _counter:Int;
	
	/* =======================================================================
	Public - Set
	========================================================================== */
	public static function set(data:Array<Dynamic>):Void {
		
		_counter = 0;
		
		var map:Map<String,Map<String,String>> = new Map();
		var ampm:String = (Date.now().getHours() > 12) ? 'pm' : 'am';
		
		for (i in 0...data.length) {
			
			var info:Dynamic = data[i];
			var name:String  = info.name;
			var body:String  = info.header + '\n\n' + info.body + '\n\n' + info.footer;
			
			map[name] = [
			
				'subject' => info.subject,
				'body'    => getURLReplaced(body,name,ampm)
				
			];
			
		}
		
		normal = map[Main.CAMPAIGN_LIST[0]];
		first  = map[Main.CAMPAIGN_LIST[1]];
		
	}
	
	/* =======================================================================
	Get URL Replaced
	========================================================================== */
	private static function getURLReplaced(body:String,name:String,ampm:String):String {
		
		for (i in 0...DB.pages.length) {

			var info  :Dynamic = DB.pages[i];
			var id    :String  = info.id;
			var param1:String  = '?utm_source=' + name + '&utm_content=' + id;
			var param2:String  = '&utm_medium=mail_' + ampm + '&utm_campaign=lp';
			
			var eReg   :EReg = new EReg('##' + id,'');
			var counter:Int  = 1;
			
			while (eReg.match(body)) {
				body = eReg.replace(body,info.url + param1 + (counter++) + '_##6_##7' + param2);
			}

		}
		
		return body;
		
	}
	
}