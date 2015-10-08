package src.utils;

class Test {
	
	/* =======================================================================
	Public - Trace Header
	========================================================================== */
	public static function traceHeader(array:Array<String>):Void {
		
		var string:String = '';
		
		for (p in 0...array.length) {
			string += p + ':' + array[p] + ',';
		}
		
		trace(string);
		
	}
	
}