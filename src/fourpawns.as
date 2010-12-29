package {
  import flash.display.Sprite;
  import com.muffinlabs.*;

  import com.google.analytics.GATracker;
  import com.google.analytics.AnalyticsTracker;
  
  // width * 80 + 80
  // height * 80 + 120

   [SWF(width="400", height="440", frameRate="30", backgroundColor="#000000")]
   public class fourpawns extends Sprite {
	 //	 [Embed(source='../assets/junction.otf', fontName="abstract", mimeType="application/x-font-truetype")]
	 [Embed(source='../assets/orbitron-medium.ttf', fontName="abstract", mimeType="application/x-font-truetype")]
	   private var _font:String;

	 [Embed(source="../assets/fourpawns-move-data.txt", mimeType="application/octet-stream")] public static const DataSrc:Class;

	 [Embed(source="../assets/board4.png")]
	   private var boardBack:Class;


	 public var gameManager:GameSceneManager;
	 private var loader:Background;

	 private function loadData():void {
	   Scores.process();
	 }

	 public function fourpawns() {
	   var _tracker:AnalyticsTracker;
	   _tracker = new GATracker(this, "UA-XXXXX-XX", "AS3", false );
	   _tracker.trackEvent("Games", "fourpawns", "intro");


	   PlayScreen.boardBack = boardBack;
	   Scores.init();
	   Scores.data_source = DataSrc;
	   loader = new Background(this, 0.8);
	   loader.addFunction(loadData);

	   // MochiBot.com -- Version 8
	   // Tested with Flash 9-10, ActionScript 3
	   MochiBot.track(this, "123abc");

	   Board.height = 4;
	   Board.width = 4;
	   gameManager = GameSceneManager.getInstance(this);

	   MenuScreen.displayWidth = 400;
	   MenuScreen.displayHeight = 440;

	   var menuScene:MenuScreen = new MenuScreen();
	   GameSceneManager.changeScene(menuScene);
	 }
   } // quadpawn
}
