package com.muffinlabs {
  import flash.utils.*;

  public class Scores {
	public static var table:Dictionary = null;
	public static var data_source:Class = null;
	public static var doneLoading:Boolean = false;

	public static var wins:uint = 0;
	public static var losses:uint = 0;

	private static var incoming:Array = null;
	private static var loadIndex:int = 0;

	public static function init():void {
	  if ( table == null ) {
		table = new Dictionary();
	  }
	  if ( data_source != null && incoming == null ) {
		var text_source:ByteArray = new data_source as ByteArray;
		incoming = text_source.toString().split("\n");
	  }
	} // init

	public static function loadAll():void {
	  while (loadIndex < incoming.length) {
		process();
	  }
	}

	public static function process():void {
	  if ( incoming == null ) {
		init();
		return;
	  }

	  if ( loadIndex < incoming.length ) {
		//trace(loadIndex + "/" + incoming.length);
		var tmp:Array = incoming[loadIndex].split(",");
		for(var i:int = 0; i < tmp.length; i++) {
		  var row:Array = tmp[i].split(":");
		  table[row[0]] = int(row[1]);
		}
		loadIndex++;
	  }
	  else {
		doneLoading = true;
	  }
	} // process

  } // class Scores
} // namespace
