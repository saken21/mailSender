package src.utils;

import js.JQuery;
import jp.saken.utils.Dom;
import jp.saken.utils.Ajax;

class Message {
	
	public static var normal:Map<String,String>;
	public static var first :Map<String,String>;
	
	/* =======================================================================
	Public - Set
	========================================================================== */
	public static function set(data:Array<Dynamic>):Void {
		
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
			var params:String  = '?utm_source=' + name + '_' + (i + 1);
			
			params += '&utm_medium=mail_' + ampm + '&utm_campaign=lp';
			
			body = StringTools.replace(body,'##' + info.id,info.url + params);

		}
		
		return body;
		
	}
	
}