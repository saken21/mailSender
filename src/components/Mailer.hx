package src.components;

import haxe.Http;
import jp.saken.utils.Handy;
import jp.saken.utils.Ajax;
import src.utils.Data;
import src.utils.Util;
import src.utils.Csv;

class Mailer {
	
	private static var _staffs       :Array<Dynamic>;
	private static var _messages     :Map<String,Map<String,String>>;
	private static var _normalSubject:String;
	private static var _normalMessage:String;
	private static var _firstSubject :String;
	private static var _firstMessage :String;
	private static var _staffCounter :Map<String,Int>;
	
	private static var CAMPAIGN_LIST:Array<String> = ['150910_abc','150910_abc_f'];
	private static inline var TEST_MAIL:String = 'sakata@graphic.co.jp';
	
	/* =======================================================================
	Public - Init
	========================================================================== */
	public static function init():Void {
		
		if (TEST_MAIL.length > 0) trace('\n--\nTest Mailaddress\n--\n');
		
		setStaffs('staffs',['lastname','firstname','mailaddress']);
		
		Ajax.getData('lp',['id','url'],function(data:Array<Dynamic>):Void {
			setMessage('messages',['name','subject','header','body','footer'],data);
		});
		
	}
	
		/* =======================================================================
		Public - Send
		========================================================================== */
		public static function send():Void {
			
			Util.check([_staffs,_messages]);

			var data:Array<Dynamic> = [];
			var screenedData:Array<Dynamic> = Data.getScreened();
			
			_staffCounter = new Map();

			for (p in 0...screenedData.length) {
				
				var client :Dynamic = screenedData[p];
				var isFirst:Bool    = (client.date.length == 0);
				
				var staff        :Dynamic = choiceStaff(_staffs,client.id);
				var staffFullname:String  = staff.lastname + staff.firstname;
				var staffMail    :String  = staff.mailaddress + '@graphic.co.jp';
				
				var counter:Int = _staffCounter[staffFullname];
				if (counter == null) counter = 0;

				_staffCounter[staffFullname] = ++counter;
				
				var subject:String;
				var message:String;
				
				trace(isFirst);
				
				if (_firstSubject != null && _firstMessage != null && isFirst) {
					
					subject = _firstSubject;
					message = _firstMessage;
					
				} else {
					
					subject = _normalSubject;
					message = _normalMessage;
					
				}

				message = StringTools.replace(message,'##1',client.corporate);
				message = StringTools.replace(message,'##2',client.name);
				message = StringTools.replace(message,'##3',staff.lastname);
				message = StringTools.replace(message,'##4',staffFullname);
				message = StringTools.replace(message,'##5',staffMail);

				request(staffFullname,staffMail,client.mail,subject,message);

				client.staffName = staff.lastname;
				data.push(client);

			}
			
			trace(_staffCounter);
			Csv.export(data);

		}
	
	/* =======================================================================
	Set Staffs
	========================================================================== */
	private static function setStaffs(table:String,columns:Array<String>):Void {
		
		Ajax.getData(table,columns,function(data:Array<Dynamic>):Void {
			_staffs = data;
		});
		
	}
	
	/* =======================================================================
	Set Message
	========================================================================== */
	private static function setMessage(table:String,columns:Array<String>,urlList:Array<Dynamic>):Void {
		
		var where:Array<String> = [];
		
		for (i in 0...CAMPAIGN_LIST.length) {
			where.push('name = "' + CAMPAIGN_LIST[i] + '"');
		}
		
		Ajax.getData(table,columns,function(data:Array<Dynamic>):Void {
			
			setMessageMap(data,urlList);
			setNormalMessage();
			
			if (CAMPAIGN_LIST.length > 1) setFirstMessage();
			
		},where.join(' OR '));
		
	}
	
	/* =======================================================================
	Set Normal Message
	========================================================================== */
	private static function setNormalMessage():Void {
		
		var map:Map<String,String> = _messages[CAMPAIGN_LIST[0]];
		
		_normalSubject = map['subject'];
		_normalMessage = map['message'];
		
	}
	
	/* =======================================================================
	Set First Message
	========================================================================== */
	private static function setFirstMessage():Void {
		
		var map:Map<String,String> = _messages[CAMPAIGN_LIST[1]];
		if (map == null) return;
		
		_firstSubject = map['subject'];
		_firstMessage = map['message'];
		
	}
	
	/* =======================================================================
	Set Message Map
	========================================================================== */
	private static function setMessageMap(data:Array<Dynamic>,urlList:Array<Dynamic>):Void {
		
		var ampm:String = (Date.now().getHours() > 12) ? 'pm' : 'am';
		
		_messages = new Map();
		
		for (i in 0...data.length) {
			
			var info   :Dynamic = data[i];
			var name   :String  = info.name;
			var message:String  = info.header + '\n\n' + info.body + '\n\n' + info.footer;
			
			_messages[name] = ['subject'=>info.subject,'message'=>getURLReplaced(message,name,urlList,ampm)];
			
		}
		
	}
	
	/* =======================================================================
	Get URL Replaced
	========================================================================== */
	private static function getURLReplaced(message:String,name:String,urlList:Array<Dynamic>,ampm:String):String {
		
		for (i in 0...urlList.length) {

			var info  :Dynamic = urlList[i];
			var params:String  = '?utm_source=' + name + '_' + (i + 1);
			
			params += '&utm_medium=mail_' + ampm + '&utm_campaign=lp';
			
			message = StringTools.replace(message,'##' + info.id,info.url + params);

		}
		
		return message;
		
	}
	
	/* =======================================================================
	Choice Staff
	========================================================================== */
	private static function choiceStaff(array:Array<Dynamic>,num:Int):Dynamic {
		
		var length:Int = array.length;
		var value :Int = num % length;
		
		return array[value];
		
	}
	
	/* =======================================================================
	Request
	========================================================================== */
	private static function request(staffFullname:String,staffMail:String,to:String,subject:String,message:String):Void {
		
		if (TEST_MAIL.length > 0) to = TEST_MAIL;
		
		trace(to);
		
		var http:Http = new Http('files/php/sendMail.php');
		
		http.setParameter('staffFullname',staffFullname);
		http.setParameter('staffMail',staffMail);
		http.setParameter('to',to);
		http.setParameter('subject',subject);
		http.setParameter('message',message);
		
		http.request(true);
		
	}
	
}