package src.utils;

import haxe.Http;
import js.JQuery;
import jp.saken.utils.Handy;
import src.components.View;

class Csv {
	
	private static var _current :Int;
	private static var _filename:String;
	
	private static inline var PHP_URL:String = 'files/php/exportCSV.php';
	
	/* =======================================================================
	Public - Export
	========================================================================== */
	public static function export(data:Array<Dynamic>):Void {
		
		ajax(getAdjusted(data).join('\n'));
		
	}
	
		/* =======================================================================
		Public - Set Current
		========================================================================== */
		public static function setCurrent(value:Int):Void {

			_current = value;

		}
	
		/* =======================================================================
		Public - Merge CSV
		========================================================================== */
		public static function merge():Void {

			if (!Data.hasSaved()) {

				Handy.alert('CSVがありません。');
				return;

			}

			_current = null;
			
			var data:Array<Dynamic> = Data.getSaved();
			
			export(data);
			
			Data.setScreened(data);
			Data.clearSaved();

		}
	
	/* =======================================================================
	Get Adjusted
	========================================================================== */
	private static function getAdjusted(data:Array<Dynamic>):Array<String> {
		
		var length:Int    = data.length;
		var html  :String = '<dt>' + length + '件ヒットしました</dt>';
		
		var array:Array<String> = [];
		
		for (i in 0...length) {
			
			var info     :Dynamic = data[i];
			var id       :String  = info.id;
			var subID    :String  = info.subID;
			var date     :String  = info.date;
			var corporate:String  = info.corporate;
			var name     :String  = info.name;
			var mail     :String  = info.mail;
			var staffName:String  = info.staffName;
			
			html += getSingleHTML(corporate,name,mail);
			array.push(id + '\t' + subID + '\t' + date + '\t' + corporate + '\t' + name + '\t' + mail + '\t' + staffName);
			
		}
		
		View.setScreened(html);
		
		return array;
		
	}
	
	/* =======================================================================
	Get Single HTML
	========================================================================== */
	private static function getSingleHTML(corporate:String,name:String,mail:String):String {
		
		return '
		<dd>
			<span class="corporate">' + corporate + '</span>
			<span class="name">' + name + '様</span>
			<span class="mail">' + mail + '</span>
		</dd>';
		
	}
	
	/* =======================================================================
	Ajax
	========================================================================== */
	private static function ajax(data:String):Void {
		
		var num:String = (_current == null) ? '' : Handy.getFilledNumber(_current);
		_filename = 'data' + num + '.csv';
		
		var http:Http = new Http(PHP_URL);

		http.onData = onExported;
		
		http.setParameter('data',data);
		http.setParameter('filename',_filename);
		
		http.request(true);
		
	}
	
	/* =======================================================================
	On Exported
	========================================================================== */
	private static function onExported(result:String):Void {
		
		var filename:String = 'data.csv';
		var jAnchor :JQuery = new JQuery('<a>');
		
		jAnchor.prop('download',_filename);
		jAnchor.prop('href','files/php/csv/' + _filename);
		jAnchor.prop('target','_blank');
		
		jAnchor.addClass('download').text('→ Download ' + _filename);
		View.appendCSV(jAnchor);
		
		Handy.alert('CSVの書き出しが完了しました。');
		
	}
	
}