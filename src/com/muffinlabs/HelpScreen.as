package com.muffinlabs {
  import com.muffinlabs.*;
  import flash.display.*;
  import caurina.transitions.Tweener;
  import flash.events.Event;
  import flash.text.*;

  public class HelpScreen extends Sprite implements IGameScene {
	private var _title:TextWidget;
	private var _footer:TextWidget;
	private var backButton:SpriteButton;

	private var myText:String = "<p>Each player starts with " +
	  (Board.width == 4 ? "four" : "five") +
	  " pawns.  Pieces can move forward one space or capture opponent diagonally.</p><br /><p>How to win:<br>* Get a pawn to the other side<br>* Block your opponent from moving<br>* Capture the opponent's pieces</p><br /><p><b>Good luck!</b></p>";

	private var myTextBox:TextField; 


	public function HelpScreen() {
	  _title = new TextWidget("How to Play", 0x0000ff, "abstract");
	  _title.size = 26;

	  backButton = new SpriteButton(
									 new TextWidget("Back", 0xdddddd, "abstract"),
									 new TextWidget("Back", 0xff0000, "abstract"));

	}
	
	public function update():void {

	}
	public function redraw():void {

	}
	public function load():void {
	  _title.x = (400 -_title.width) / 2;
	  _title.y = 25;
	  addChild(_title);

	  myTextBox = new TextField();
	  myTextBox.textColor = 0xff0000;
	  myTextBox.selectable = false;

	  myTextBox.x = 25;
	  myTextBox.y = 100;
	  addChild(myTextBox); 

	  myTextBox.width = 350; 
	  myTextBox.height = 300; 
	  myTextBox.multiline = true; 
	  myTextBox.wordWrap = true; 
	  myTextBox.border = true; 

	  myTextBox.htmlText = myText; 

	  var _format:TextFormat = new TextFormat();
	  _format.color = 0xff0000;
	  _format.size = 18;
	  _format.font = "abstract";
	  myTextBox.embedFonts = true;

		//myTextBox.autoSize = TextFieldAutoSize.LEFT;
		//myTextBox.antiAliasType = AntiAliasType.ADVANCED;
	  myTextBox.defaultTextFormat = _format;
	  myTextBox.setTextFormat(_format);


	  backButton.addEventListener("click", onBack);
	  backButton.x = (400 - backButton.width)/2;
	  backButton.y = 400 - backButton.height;
	  addChild(backButton);
	}

	private function onBack(e:Event):void {
	  Tweener.addTween(this, { _autoAlpha:0, time:0.1, transition:"linear", onComplete:backToMenu} );
	}
	private function backToMenu():void {
	  var menuScene:MenuScreen = new MenuScreen();
	  GameSceneManager.changeScene(menuScene);
	}

	public function unload():void {

	}
	
	
  } // MenuScreen
}