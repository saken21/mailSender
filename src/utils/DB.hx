package src.utils;

import js.JQuery;
import jp.saken.utils.Dom;
import jp.saken.utils.Ajax;

class DB {
	
	public static var messages (default,null):Array<Dynamic>;
	public static var staffs   (default,null):Array<Dynamic>;
	public static var staffMap (default,null):Map<Int,Dynamic>;
	public static var supports (default,null):Map<Int,Dynamic>;
	public static var pages    (default,null):Array<Dynamic>;
	public static var ngDomains(default,null):Array<String>;
	public static var stopUsers(default,null):Array<String>;
	
	private static var _func   :Void->Void;
	private static var _map    :Map<String,Dynamic>;
	private static var _counter:Int;
	
	/* =======================================================================
	Public - Load
	========================================================================== */
	public static function load(func:Void->Void):Void {
		
		_func    = func;
		_map     = new Map();
		_counter = 0;
		
		Dom.jWindow.on('loadDB',onLoaded);
		
		ajax('messages',['name','subject','header','body','footer'],getWhere(Main.CAMPAIGN_LIST));
		ajax('staffs',['id','lastname','firstname','mailaddress']);
		ajax('supports',['client_id','staff_id']);
		ajax('pages',['id','url']);
		ajax('ngDomains',['domain']);
		ajax('stopUsers',['mailaddress']);
		
	}
	
		/* =======================================================================
		Public - Insert Support
		========================================================================== */
		public static function insertSupport(clientID:Int,staffID:Int):Void {
			
			Ajax.insertData('supports',['client_id','staff_id'],[clientID,staffID]);

		}
	
	/* =======================================================================
	Get Where
	========================================================================== */
	private static function getWhere(array:Array<String>):String {
		
		var wheres:Array<String> = [];
		
		for (i in 0...array.length) {
			wheres.push('name = "' + array[i] + '"');
		}
		
		return wheres.join(' OR ');
		
	}
	
	/* =======================================================================
	Ajax
	========================================================================== */
	private static function ajax(table:String,columns:Array<String>,where:String = ''):Void {
		
		_counter++;
		
		Ajax.getData(table,columns,function(data:Array<Dynamic>):Void {
			
			if (columns.length > 1) _map[table] = data;
			else _map[table] = getSimpleArray(data,columns[0]);
			
			Dom.jWindow.trigger('loadDB');
		
		},where);
		
	}
	
	/* =======================================================================
	Get Simple Array
	========================================================================== */
	private static function getSimpleArray(data:Array<Dynamic>,key:String):Array<String> {
		
		var array:Array<String> = [];

		for (i in 0...data.length) {
			untyped array.push(data[i][key]);
		}
		
		return array;
		
	}
	
	/* =======================================================================
	On Loaded
	========================================================================== */
	private static function onLoaded(event:JqEvent):Void {
		
		_counter--;
		if (_counter > 0) return;
		
		messages  = _map['messages'];
		staffs    = _map['staffs'];
		staffMap  = getMap(staffs,'id');
		supports  = getMap(_map['supports'],'client_id','staff_id');
		pages     = _map['pages'];
		ngDomains = _map['ngDomains'];
		stopUsers = _map['stopUsers'];
		
		Message.set(messages);
		
		trace(ngDomains);
		trace(stopUsers);
		
		_func();
		
	}
	
	/* =======================================================================
	Get Map
	========================================================================== */
	private static function getMap(data:Array<Dynamic>,key:String,value:String = null):Map<Int,Dynamic> {
		
		var map:Map<Int,Dynamic> = new Map();
		
		for (i in 0...data.length) {
			
			var info:Dynamic = data[i];
			untyped map[info[key]] = (value == null) ? info : info[value];
			
		}
		
		return map;
		
	}
	
}