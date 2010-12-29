package com.muffinlabs {
  import com.muffinlabs.*;
  import flash.display.*;
  import caurina.transitions.Tweener;
  import flash.text.*;

  import flash.events.*;

  import flash.net.URLRequest;
  import flash.net.navigateToURL;

  public class MenuScreen extends Sprite implements IGameScene {

	private var _title:TextWidget;
	private var _footer:TextWidget;

	private var startButton:SpriteButton;
	private var footerButton:SpriteButton;
	//	private var aboutButton:SpriteButton;

	private var buttonSpacing:uint = 25;

	public static var _width:uint = 400;
	public static var _height:uint = 440;

	private var pawnStr:String = Board.width == 5 ? "five" : "four";
	private var myText:String = "<p>Each player starts with " + pawnStr + " pawns. Pieces can move forward one space or capture opponent diagonally.</p><br /><p>How to win:<ul><li> Get a pawn to the other side</li><li> Block your opponent from moving</li><li> Capture the opponent's pieces</li></ul></p><br /><p><b>Good luck!</b></p>";

	private var myTextBox:TextField; 

	public static function set displayWidth(x:uint):void {
	  _width = x;
	}
	public static function set displayHeight(x:uint):void {
	  _height = x;
	}


	public function MenuScreen() {
	  if ( Board.width == 4 ) {
		_title = new TextWidget("Four Pawns", 0x0000ff, "abstract");
		_title.size = 48;
	  }
	  else {
		_title = new TextWidget("Five Pawns", 0x0000ff, "abstract");
		_title.size = 60;
	  }
	  ///_title.align = TextFormatAlign.CENTER;

	  startButton = new SpriteButton(
									 new TextWidget("Play Game", 0x00ff00, "abstract", 28),
									 new TextWidget("Play Game", 0xff0000, "abstract", 28));

	  footerButton = new SpriteButton(
									  new TextWidget("A muffinlabs production 2011", 0xaaaaaa, "abstract", 14),
									  new TextWidget("A muffinlabs production 2011", 0xff0000, "abstract", 14));

	}
	
	public function update():void {

	}
	public function redraw():void {

	}

	public function load():void {
	  _title.x = (_width -_title.width) / 2;
	  _title.y = 10;
	  addChild(_title);

	  myTextBox = new TextField();
	  myTextBox.textColor = 0xff0000;
	  myTextBox.selectable = false;



	  myTextBox.x = 10;

	  if ( Board.width == 4 ) {
		myTextBox.y = 100;
	  }
	  else {
		myTextBox.y = 120;
	  }

	  myTextBox.width = _width - 20; 
	  myTextBox.height = 300; 
	  myTextBox.multiline = true; 
	  myTextBox.wordWrap = true; 
	  myTextBox.border = true; 

	  myTextBox.htmlText = myText; 

	  var _format:TextFormat = new TextFormat();
	  _format.color = 0xff0000;
	  if ( Board.width == 4 ) {
		_format.size = 16;
	  }
	  else {
		_format.size = 18;
	  }
	  _format.font = "abstract";
	  myTextBox.embedFonts = true;

		//myTextBox.autoSize = TextFieldAutoSize.LEFT;
		//myTextBox.antiAliasType = AntiAliasType.ADVANCED;
	  myTextBox.defaultTextFormat = _format;
	  myTextBox.setTextFormat(_format);
	  addChild(myTextBox); 

	  startButton.addEventListener("click", onGameStart);
	  startButton.x = (_width - startButton.width)/2;
	  if ( Board.width == 4 ) {
		startButton.y = _height - 75;
	  }
	  else {
		startButton.y = _height - 125;
	  }


	  addChild(startButton);

	  footerButton.addEventListener("click", onHyperLinkEvent);
	  footerButton.x = (_width - footerButton.width)/2;
	  footerButton.y = _height - 25;
	  addChild(footerButton);
	}

	private function onHyperLinkEvent(evt:Event):void {
	  navigateToURL(new URLRequest("http://muffinlabs.com/fivepawns"), "_new");
	}

	private function onGameStart(e:Event):void {
	  Tweener.addTween(this, { _autoAlpha:0, time:0.1, transition:"linear", onComplete:startGame} );
	}

	private function startGame():void {
	  var playScene:PlayScreen = new PlayScreen();
	  GameSceneManager.changeScene(playScene);
	}
	private function showHelpScreen():void {
	  var helpScene:HelpScreen = new HelpScreen();
	  GameSceneManager.changeScene(helpScene);
	}
	private function showAboutScreen():void {
	  var aboutScene:AboutScreen = new AboutScreen();
	  GameSceneManager.changeScene(aboutScene);
	}

	public function unload():void {

	}
	
	
  } // MenuScreen
}