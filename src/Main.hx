/**
* ================================================================================
*
* MailSender ver 1.01.00
*
* Author : KENTA SAKATA
* Since  : 2015/07/24
* Update : 2015/10/08
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

class Main {
	
	public static function main():Void {
		
		Dom.jWindow.on('beforeunload',onBeforeunload);
		new JQuery('document').ready(init);
		
    }

	private static function init(event:JqEvent):Void {
		
		View.init();
		Screener.init();
		Mailer.init();
		
	}
	
	private static function onBeforeunload(event:JqEvent):Void {
		
		new Http('files/php/deleteCSV.php').request(true);
		
	}

}