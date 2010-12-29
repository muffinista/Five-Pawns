package {
  import flash.display.Sprite;
  import com.muffinlabs.*;

  import com.google.analytics.GATracker;
  import com.google.analytics.AnalyticsTracker;
  
   [SWF(width="480", height="520", frameRate="30", backgroundColor="#000000")]
   public class fivepawns extends Sprite {
	 //	 [Embed(source='../assets/junction.otf', fontName="abstract", mimeType="application/x-font-truetype")]
	 [Embed(source='../assets/orbitron-medium.ttf', fontName="abstract", mimeType="application/x-font-truetype")]
	   private var _font:String;

	 [Embed(source="../assets/fivepawns-move-data.txt", mimeType="application/octet-stream")] public static const DataSrc:Class;

	 [Embed(source="../assets/board5.png")]
	   private var boardBack:Class;


	 public var gameManager:GameSceneManager;
	 private var loader:Background;

	 public function fivepawns() {
	   var _tracker:AnalyticsTracker;
	   _tracker = new GATracker(this, "UA-XXXXXX-XX", "AS3", false );
	   _tracker.trackEvent("Games", "fivepawns", "intro");

	   PlayScreen.boardBack = boardBack;

	   Scores.data_source = DataSrc;
	   Scores.init();

	   loader = new Background(this, 0.8);
	   loader.addFunction(loadData);

	   // MochiBot.com -- Version 8
	   // Tested with Flash 9-10, ActionScript 3
	   MochiBot.track(this, "123abc");

	   Board.height = 5;
	   Board.width = 5;
	   //	   Board.MAX_DEPTH = 8;
	   //	   Board.CURRENT_DEPTH = 8;

	   gameManager = GameSceneManager.getInstance(this);

	   MenuScreen.displayWidth = 480;
	   MenuScreen.displayHeight = 520;

	   var menuScene:MenuScreen = new MenuScreen();
	   GameSceneManager.changeScene(menuScene);
	 }

	 private function loadData():void {
	   Scores.process();

	   // unload the background proc once it's finished
	   if ( Scores.doneLoading ) {
		 loader.removeFunction(loadData);
	   }
	 } // loadData

   } // fivepawns
}
