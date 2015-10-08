package src.utils;

class Data {
	
	private static var _raw     :Array<String>;
	private static var _screened:Array<Dynamic>;
	private static var _saved   :Array<Dynamic>;
	
	/* =======================================================================
	Public - Set Raw
	========================================================================== */
	public static function setRaw(array:Array<String>):Void {
		
		_raw = array;
		
	}
	
	/* =======================================================================
	Public - Get Raw
	========================================================================== */
	public static function getRaw():Array<String> {
		
		return _raw;
		
	}
	
	/* =======================================================================
	Public - Has Raw
	========================================================================== */
	public static function hasRaw():Bool {
		
		return _raw != null;
		
	}
	
	/* =======================================================================
	Public - Shift Raw
	========================================================================== */
	public static function shiftRaw():Void {
		
		_raw.shift();
		
	}
	
	/* =======================================================================
	Public - Set Screened
	========================================================================== */
	public static function setScreened(data:Array<Dynamic>):Void {
		
		_screened = data;
		
	}
	
	/* =======================================================================
	Public - Get Screened
	========================================================================== */
	public static function getScreened():Array<Dynamic> {
		
		return _screened;
		
	}
	
	/* =======================================================================
	Public - Push Screened
	========================================================================== */
	public static function pushScreened(value:Dynamic):Void {
		
		_screened.push(value);
		
	}
	
	/* =======================================================================
	Public - Clear Screened
	========================================================================== */
	public static function clearScreened():Void {
		
		_screened = [];
		
	}
	
	/* =======================================================================
	Public - Get Saved
	========================================================================== */
	public static function getSaved():Array<Dynamic> {
		
		return _saved;
		
	}
	
	/* =======================================================================
	Public - Has Saved
	========================================================================== */
	public static function hasSaved():Bool {
		
		return _saved != null && _saved.length > 0;
		
	}
	
	/* =======================================================================
	Public - Concat Saved
	========================================================================== */
	public static function concatSaved():Void {
		
		_saved = _saved.concat(_screened);
		
	}
	
	/* =======================================================================
	Public - Clear Saved
	========================================================================== */
	public static function clearSaved():Void {
		
		_saved = [];
		
	}
	
}