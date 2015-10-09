package src.components;

import js.JQuery;
import jp.saken.utils.Handy;
import jp.saken.utils.Dom;
import jp.saken.ui.DragAndDrop;
import src.utils.Data;
import src.utils.Csv;
import src.utils.ER;
import src.utils.Test;

class View {
	
	private static var _jAll        :JQuery;
	private static var _jSubmit     :JQuery;
	private static var _jLocalNG    :JQuery;
	private static var _jGlobalNG   :JQuery;
	private static var _jSliceLength:JQuery;
	private static var _jCsv        :JQuery;
	private static var _jScreened   :JQuery;
	private static var _jMergeCSV   :JQuery;
	private static var _jSendMail   :JQuery;
	
	/* =======================================================================
	Public - Init
	========================================================================== */
	public static function init():Void {
		
		_jAll         = new JQuery('#all').show();
		_jSubmit      = new JQuery('#submit');
		_jLocalNG     = new JQuery('#localNG');
		_jGlobalNG    = new JQuery('#globalNG');
		_jSliceLength = new JQuery('#sliceLength');
		_jCsv         = new JQuery('#csv');
		_jScreened    = new JQuery('#screened');
		_jMergeCSV    = new JQuery('#mergeCSV');
		_jSendMail    = new JQuery('#sendMail');
		
		var jFilename = new JQuery('#filename');
		var dragAndDrop:DragAndDrop = new DragAndDrop(Dom.jWindow,onLoadedFile);
		
		Dom.jWindow.on('onDrop',function(event:JqEvent):Void {
			
			empty();
			jFilename.text(dragAndDrop.getFilename());
		
		});
		
		_jMergeCSV.on('click',function(event:JqEvent):Void { Csv.merge(); });
		_jSubmit.on('click',submit);
		_jSendMail.on('click',sendMail);
		
	}
	
		/* =======================================================================
		Public - Set Screened
		========================================================================== */
		public static function setScreened(html:String):Void {
			
			_jScreened.html(html);
			
		}
		
		/* =======================================================================
		Public - Append CSV
		========================================================================== */
		public static function appendCSV(jAnchor:JQuery):Void {
			
			_jCsv.append(jAnchor);
			_jSubmit.removeClass('screening');
			
			if (_jCsv.find('a').length > 1) _jMergeCSV.show();
			
		}
		
		/* =======================================================================
		Public - Set Sliced CSV
		========================================================================== */
		public static function setSlicedCSV(data:Array<Dynamic>):Void {
			
			var html:String = '';

			for (p in 0...data.length) {
				html += '<a class="slicedData" data-id="' + p + '">No.' + Handy.getFilledNumber(p) + ' (' + data[p].length + ')</a>';
			}
			
			_jCsv.html(html + '<p class="empty"></p>').find('a').on('click',function(event:JqEvent):Void {

				if (Screener.getBusy()) {

					Handy.alert('処理中です。しばらくお待ちください。');
					return;

				}

				var id:Int = JQuery.cur.data('id');

				Csv.setCurrent(id);
				Screener.startGlobal(data[id]);

			});
			
		}
		
		/* =======================================================================
		Public - Get Slice Length
		========================================================================== */
		public static function getSliceLength():Int {
			
			return Std.parseInt(_jSliceLength.prop('value'));
			
		}
	
	/* =======================================================================
	On Loaded File
	========================================================================== */
	private static function onLoadedFile(data:String):Void {
		
		var array:Array<String> = data.split('\n');
		
		empty();
		Data.setRaw(array);
		
		Test.traceHeader(array[0].split('\t'));
		trace('All : ' + array.length);
		
	}
	
	/* =======================================================================
	Submit
	========================================================================== */
	private static function submit(event:JqEvent):Void {
		
		if (_jSubmit.hasClass('screening') || !Data.hasRaw()) return untyped false;
		
		empty();
		
		_jSubmit.addClass('screening');
		Data.shiftRaw();
		
		ER.set(_jLocalNG.prop('value'),_jGlobalNG.prop('value'));
		Screener.start();
		
		return untyped false;
		
	}
	
	/* =======================================================================
	Send Mail
	========================================================================== */
	private static function sendMail(event:JqEvent):Void {
		
		var isOK:Bool = Dom.window.confirm('メールを送信します。\nよろしいですか？');
		if (isOK) Mailer.send();
		
	}
	
	/* =======================================================================
	Empty
	========================================================================== */
	private static function empty():Void {
		
		_jCsv.find('a').unbind();
		_jScreened.add(_jCsv).empty();
		_jMergeCSV.hide();
		
	}
	
}