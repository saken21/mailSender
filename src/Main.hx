/**
* ================================================================================
*
* MailSender ver 1.01.05
*
* Author : KENTA SAKATA
* Since  : 2015/07/24
* Update : 2015/11/25
*
* Licensed under the MIT License
* Copyright (c) Kenta Sakata
* http://saken.jp/
*
* ================================================================================
*
**/
package src;

import haxe.Http;
import js.JQuery;
import jp.saken.utils.Dom;
import src.components.*;
import src.utils.DB;

class Main {
	
	public static var CAMPAIGN_LIST:Array<String> = ['151008_a','151125_a_f'];
	public static inline var TEST_MAIL:String = '';
	
	public static function main():Void {
		
		Dom.jWindow.on('beforeunload',onBeforeunload);
		new JQuery('document').ready(init);
		
    }

	private static function init(event:JqEvent):Void {
		
		if (TEST_MAIL.length > 0) {
			trace('\n--\nTest - ' + TEST_MAIL + '\n--\n');
		}
		
		DB.load(View.init);
		
	}
	
	private static function onBeforeunload(event:JqEvent):Void {
		
		new Http('files/php/deleteCSV.php').request(true);
		
	}

}