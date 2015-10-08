package src.utils;

import jp.saken.utils.Dom;

class Util {
	
	/* =======================================================================
	Public - Get EReg By Textarea
	========================================================================== */
	public static function getERegByTextarea(value:String):EReg {
		
		value = ~/\n/g.replace(value,'');
		return new EReg(~/,/g.replace(value,'|'),'i');
		
	}
	
	/* =======================================================================
	Public - Get EReg By Array
	========================================================================== */
	public static function getERegByArray(data:Array<Dynamic>,key:String):EReg {
		
		var array:Array<String> = [];
		
		for (i in 0...data.length) {
			untyped array.push(data[i][key]);
		}
		
		var join:String = array.join('|');
		trace(join);
		
		return new EReg(join,'i');
		
	}
	
	/* =======================================================================
	Public - Alert
	========================================================================== */
	public static function alert(value:String):Void {
		
		Dom.window.alert(value);
		
	}
	
	/* =======================================================================
	Public - Check
	========================================================================== */
	public static function check(array:Array<Dynamic>):Void {
		
		for (i in 0...array.length) {
			
			if (array[i] == null) {
				
				alert('データ読み込み中です。');
				break;
				
			}
			
		}
		
	}
	
}