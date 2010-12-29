package com.muffinlabs {
  import com.muffinlabs.*;
  import flash.display.*;
  import caurina.transitions.Tweener;
  import flash.events.*;
  import flash.text.*;
  import flash.net.URLRequest;
  import flash.net.navigateToURL;  

  public class AboutScreen extends Sprite implements IGameScene {
	private var _title:TextWidget;
	private var _footer:TextWidget;

	private var backButton:SpriteButton;

	private var myText:String = "<p>Written by Colin Mitchell.<br><br>Learn more at <a href='http://muffinlabs.com/'>muffinlabs.com</a></p>";
	private var footerText:String = "for han";

	private var myTextBox:TextField; 
	private var myFooter:TextField; 

	public function AboutScreen() {
	  _title = new TextWidget("About", 0x0000ff, "abstract");
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

	  myTextBox.x = 45;
	  myTextBox.y = 80;
	  addChild(myTextBox); 

	  myTextBox.width = 350; 
	  myTextBox.height = 300; 
	  myTextBox.multiline = true; 
	  myTextBox.wordWrap = true; 
	  //myTextBox.border = true; 

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
	  myTextBox.addEventListener(TextEvent.LINK, onHyperLinkEvent);

	  backButton.addEventListener("click", onBack);
	  backButton.x = (400 - backButton.width)/2;
	  backButton.y = 380 - backButton.height;
	  addChild(backButton);


	  myFooter = new TextField();
	  myFooter.textColor = 0xff0000;
	  myFooter.selectable = false;

	  myFooter.x = (400 - myFooter.width)/2 + 10;
	  myFooter.y = backButton.y - 60;
	  addChild(myFooter); 

	  //	  myFooter.width = 350; 
	  myFooter.height = 60; 
	  myFooter.text = footerText; 

	  var _format2:TextFormat = new TextFormat();
	  _format2.color = 0xff0000;
	  _format2.size = 18;
	  _format2.font = "abstract";
	  myFooter.embedFonts = true;

		//myFooter.autoSize = TextFieldAutoSize.LEFT;
		//myFooter.antiAliasType = AntiAliasType.ADVANCED;
	  myFooter.defaultTextFormat = _format;
	  myFooter.setTextFormat(_format);
	}

	private function onHyperLinkEvent(evt:TextEvent):void {
	  navigateToURL(new URLRequest(evt.text), "_new");
	}
 

	public function unload():void {

	}
	
	private function onBack(e:Event):void {
	  Tweener.addTween(this, { _autoAlpha:0, time:0.1, transition:"linear", onComplete:backToMenu} );
	}

	private function backToMenu():void {
	  var menuScene:MenuScreen = new MenuScreen();
	  GameSceneManager.changeScene(menuScene);
	}

	
  } // MenuScreen
}