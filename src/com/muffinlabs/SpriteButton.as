package com.muffinlabs {
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	public class SpriteButton extends SimpleButton {
		public function SpriteButton(
									 _off:DisplayObject,
									 _over:DisplayObject = null,
									 _click:DisplayObject = null ){
			useHandCursor = true;

			if ( _over == null ) {
				_over = _off;
			}
			if ( _click == null ) {
				_click = _over;
			}

			upState = _off;
			overState = _over;
			downState = _click;
			hitTestState = _off;
		}
	}
}