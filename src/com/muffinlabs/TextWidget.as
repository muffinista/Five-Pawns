package com.muffinlabs {
  import flash.display.*;
  import flash.text.*;

  public class TextWidget extends Sprite {
	private var _text:String = null;

	private var _field:TextField = null;
	private var _format:TextFormat = null;


	public function TextWidget(t:String = null, c:uint=0xffffff, f:String=null, s:uint=24) {
	  _text = t;

	  _field = new TextField();
	  _field.textColor = c;

	  _format = new TextFormat();
	  _format.color = c;
	  _format.size = s;


	  if ( f != null ) {
		_format.font = f;
		_field.embedFonts = true;
	  }

	  _field.autoSize = TextFieldAutoSize.LEFT;
	  _field.antiAliasType = AntiAliasType.ADVANCED;
	  _field.defaultTextFormat = _format;
	  _field.setTextFormat(_format);

	  _field.text = t;
	  _field.selectable = false;
	  
	  addChild(_field);

	}

	private function reset():void {
	  _field.defaultTextFormat = _format;
	  _field.setTextFormat(_format);
	}

	public function set font(f:String):void {
	  _format.font = f;
	  reset();
	}

	public function set align(a:String):void {
	  _format.align = a;
	  reset();
	}

	public function set color(c:uint):void {
	  _format.color = c;
	  reset();
	}
	public function set size(s:uint):void {
	  _format.size = s;
	  reset();
	}

	public function set text(t:String):void {
	  _text = t;
	  _field.text = t;
	}
	public function get text():String {
	  return _text;
	}
  }
}