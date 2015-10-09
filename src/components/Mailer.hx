package src.components;

import haxe.Http;
import jp.saken.utils.Handy;
import src.utils.Data;
import src.utils.Csv;
import src.utils.DB;
import src.utils.Message;

class Mailer {
	
	private static var _counters:Map<String,Int>;
	
	/* =======================================================================
	Public - Send
	========================================================================== */
	public static function send():Void {

		var data:Array<Dynamic> = [];
		var screenedData:Array<Dynamic> = Data.getScreened();
		
		_counters = new Map();

		for (p in 0...screenedData.length) {
			data.push(ready(screenedData[p]));
		}
		
		trace(_counters);
		
		Csv.export(data);

	}
	
	/* =======================================================================
	Ready
	========================================================================== */
	private static function ready(info:Dynamic):Dynamic {
		
		var staff        :Dynamic = getStaff(info.id);
		var staffLastname:String  = staff.lastname;
		var staffFullname:String  = staffLastname + staff.firstname;
		var staffMail    :String  = staff.mailaddress + '@graphic.co.jp';
		
		var message:Map<String,String> = getMessage(info.date.length == 0);
		
		var subject:String = message['subject'];
		var body   :String = message['body'];

		body = StringTools.replace(body,'##1',info.corporate);
		body = StringTools.replace(body,'##2',info.name);
		body = StringTools.replace(body,'##3',staffLastname);
		body = StringTools.replace(body,'##4',staffFullname);
		body = StringTools.replace(body,'##5',staffMail);

		request(staffFullname,staffMail,info.mail,subject,body);
		
		info.staffName = staffLastname;
		
		return info;
		
	}
	
	/* =======================================================================
	Get Staff
	========================================================================== */
	private static function getStaff(clientID:Int):Dynamic {
		
		var staffID:Int = Std.parseInt(DB.supports[clientID]);
		var staff:Dynamic;
		
		if (staffID == null) {
			
			staff   = Handy.shuffleArray(DB.staffs)[0];
			staffID = staff.id;
			
			DB.supports[clientID] = staffID;
			DB.insertSupport(clientID,staffID);
			
		} else {
			
			staff = DB.staffMap[staffID];
			
		}
		
		serCounters(staff.lastname + staff.firstname);
		
		return staff;
		
	}
	
	/* =======================================================================
	Set Counter
	========================================================================== */
	private static function serCounters(value:String):Void {
		
		var counter:Int = _counters[value];
		if (counter == null) counter = 0;

		_counters[value] = ++counter;
		
	}
	
	/* =======================================================================
	Get Message
	========================================================================== */
	private static function getMessage(isFirst:Bool):Map<String,String> {
		
		if (Message.first != null && isFirst) {
			return Message.first;
		}
		
		return Message.normal;
		
	}
	
	/* =======================================================================
	Request
	========================================================================== */
	private static function request(staffFullname:String,staffMail:String,to:String,subject:String,body:String):Void {
		
		if (Main.TEST_MAIL.length > 0) {
			to = Main.TEST_MAIL;
		}
		
		trace(to);
		
		var http:Http = new Http('files/php/sendMail.php');
		
		http.setParameter('staffFullname',staffFullname);
		http.setParameter('staffMail',staffMail);
		http.setParameter('to',to);
		http.setParameter('subject',subject);
		http.setParameter('body',body);
		
		http.request(true);
		
	}
	
}