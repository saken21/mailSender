package src.components;

import js.JQuery;
import jp.saken.utils.Handy;
import jp.saken.utils.Ajax;
import src.utils.Data;
import src.utils.Util;
import src.utils.Csv;

class Screener {
	
	private static var _mains       :Map<String,Dynamic>;
	private static var _ngDomainEReg:EReg;
	private static var _stopUserEReg:EReg;
	private static var _localEReg   :EReg;
	private static var _globalEReg  :EReg;
	private static var _counter     :Int;
	private static var _isBusy      :Bool;
	
	private static inline var HEAD_LENGTH:Int = 9;
	
	/* =======================================================================
	Public - Init
	========================================================================== */
	public static function init():Void {
		
		Ajax.getData('ngDomains',['domain'],function(data:Array<Dynamic>):Void {
			_ngDomainEReg = Util.getERegByArray(data,'domain');
		});
		
		Ajax.getData('stopUsers',['mailaddress'],function(data:Array<Dynamic>):Void {
			_stopUserEReg = Util.getERegByArray(data,'mailaddress');
		});
		
	}
	
		/* =======================================================================
		Public - Start
		========================================================================== */
		public static function start(localNG:String,globalNG:String):Void {
			
			Util.check([_ngDomainEReg,_stopUserEReg]);

			_mains      = new Map();
			_localEReg  = Util.getERegByTextarea(localNG);
			_globalEReg = Util.getERegByTextarea(globalNG);

			var localScreenedData:Array<Dynamic> = getLocalScreenedData();
			Data.setScreened(localScreenedData);

			if (globalNG.length > 0) checkGlobalNG(localScreenedData);
			else Csv.export(localScreenedData);

		}
		
		/* =======================================================================
		Public - Get Busy
		========================================================================== */
		public static function getBusy():Bool {

			return _isBusy;

		}
		
		/* =======================================================================
		Public - Set Counter
		========================================================================== */
		public static function setCounter(value:Int):Void {

			_counter = value;

		}
		
		/* =======================================================================
		Public - Start Global
		========================================================================== */
		public static function startGlobal(data:Array<Dynamic>):Void {
			
			_isBusy  = true;
			_counter = data.length;
			
			Data.clearScreened();

			for (p in 0...data.length) {
				accessDomain(data[p]);
			}

		}
	
	/* =======================================================================
	Get Local Screened Data
	========================================================================== */
	private static function getLocalScreenedData():Array<Dynamic> {
		
		_mains = new Map();
		
		var results:Array<Dynamic> = [];
		var rawData:Array<String>  = Data.getRaw();
		
		for (p in 0...rawData.length) {
			
			var string:String = rawData[p];
			var info:Array<String> = getInfo(string.split('\t'));
			
			if (info != null) results.push(info);
			
		}
		
		trace('Local Screened : ' + results.length);
		
		return results;
		
	}
	
	/* =======================================================================
	Get Info
	========================================================================== */
	private static function getInfo(array:Array<String>):Dynamic {
		
		if (array.length < HEAD_LENGTH) return null;
		
		var id       :String = array[0];
		var subID    :Int    = Std.parseInt(array[1]);
		var lastdate :String = array[2];
		var count    :String = array[3];
		var price    :String = array[4];
		var corporate:String = array[5];
		var name     :String = array[6] + ' ' + array[7];
		var address  :String = array[8];
		var mail     :String = array[9];
		var datetime :String = array[10];
		
		if (corporate.length > 0) {
			if (_localEReg.match(corporate)) return null;
		} else {
			return null;
		}
		
		corporate = getReplaced(corporate);
		
		if (name.length == 0) return null;
		if (!(mail.length > 0 && ~/@/.match(mail))) return null;
		if (_ngDomainEReg.match(mail.split('@')[1])) return null;
		if (_stopUserEReg.match(mail)) return null;
		
		name = getReplaced(name);
		
		if (name.indexOf('株式会社') > -1) name = 'ご担当者';
		
		if (subID > 1) {
			
			var main:Dynamic = _mains[id];
			if (main == null) return null;
			
			var co    :String        = main.co;
			var domain:String        = main.domain;
			var mails :Array<String> = main.mails;
			
			if (co == null || domain == null) return null;
			
			if (corporate.indexOf(co) < 0 || mail.indexOf(domain) < 0) return null;
			if (mails.indexOf(mail) > -1) return null;
			
			mails.push(mail);
			
		} else {
			
			_mains.set(id,{ co:corporate, domain:mail.split('@')[1], mails:[mail] });
			
		}
		
		return { id:id, subID:subID, date:lastdate, corporate:corporate, name:name, mail:mail };
		
	}
	
	/* =======================================================================
	Get Replaced
	========================================================================== */
	private static function getReplaced(value:String):String {
		
		value = StringTools.replace(value,'⑭','（株）');
		value = StringTools.replace(value,'&amp;','&');
		value = StringTools.replace(value,'&#039;','\'');
		value = StringTools.replace(value,'&#8226;','・');
		
		return value;
		
	}
	
	/* =======================================================================
	Check Global NG
	========================================================================== */
	private static function checkGlobalNG(localScreenedData:Array<Dynamic>):Void {
		
		Data.clearSaved();
		
		var sliceLength:Int = View.getSliceLength();
		
		if (sliceLength > 0) View.setSlicedCSV(Handy.getSlicedArray(localScreenedData,sliceLength));
		else startGlobal(localScreenedData);
		
	}
	
	/* =======================================================================
	Access Domain
	========================================================================== */
	private static function accessDomain(info:Dynamic):Void {
		
		var domain:String = info.mail.split('@')[1];

		untyped $.ajax({
			
			type : 'GET',
			url  : 'http://' + domain
			
		}).done(function(data:Dynamic):Void {
			
			analyzeKeyword(data.results[0],info);
			removeCounter();
			
		}).fail(removeCounter);

	}
	
	/* =======================================================================
	Analyze Keyword
	========================================================================== */
	private static function analyzeKeyword(value:String,info:Dynamic):Void {

		if (value == null) return;

		var jHead       :JQuery = new JQuery('<div>' + value.split('<body')[0] + '</div>');
		var jKeywords   :JQuery = jHead.find('meta[name*="eyword"]');
		var jDescription:JQuery = jHead.find('meta[name*="escription"]');
		
		if (jKeywords.length == 0) jKeywords = jHead.find('meta[name="KEYWORDS"]');
		if (jDescription.length == 0) jDescription = jHead.find('meta[name="DESCRIPTION"]');
		
		var keywords:String = jKeywords.prop('content') + jDescription.prop('content');
		
		trace('Keyword : ' + keywords);

		if (!_globalEReg.match(keywords)) Data.pushScreened(info);
		
	}
	
	/* =======================================================================
	Remove Counter
	========================================================================== */
	private static function removeCounter():Void {
		
		_counter--;

		if (_counter == 0) {

			Data.concatSaved();
			Csv.export(Data.getScreened());

			_isBusy = false;

		}
		
		trace(_counter);
		
	}
	
}