package com.muffinlabs {
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
	
  /**
   * Based on http://www.rivermanmedia.com/programming/6-object-oriented-game-programming-the-scene-system
   * More info: http://gamedev.michaeljameswilliams.com/2009/04/13/as3-scene-system/
   * Singleton template from here: http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
   * @author MichaelJWilliams
   */

  public class GameSceneManager {
	private static var _instance:GameSceneManager;
	private static var _allowInstantiation:Boolean;
	private static var _currentScene:IGameScene;
	private static var _sceneContainer:DisplayObjectContainer;

	public static function getInstance( p_sceneContainer:DisplayObjectContainer = null ):GameSceneManager 
	  {
		if ( _instance == null ) 
		  {
			_allowInstantiation = true;
			_instance = new GameSceneManager();
			_allowInstantiation = false;
		  }
			
		if ( p_sceneContainer )
		  {
			setSceneContainer( p_sceneContainer );
		  }
			
		return _instance;
	  }

	/**
	 * 
	 * @param	p_sceneContainer	Object that is parent of each scene -- for example, the document class
	 */
	public function GameSceneManager():void 
	{
	  if ( !_allowInstantiation ) 
		{
		  throw new Error("Error: Instantiation failed: Use GameSceneManager.getInstance() instead of new.");
		}
	}
	
	public static function setSceneContainer( p_sceneContainer:DisplayObjectContainer ):void
	{
	  _sceneContainer = p_sceneContainer;
	}
	
	/**
	 * Update logic for the current scene.
	 */
	public static function update():void
	{
	  _currentScene.update();
	}
	
	/**
	 * Redraw everything on screen.
	 */
	public static function redraw():void
	{
	  _currentScene.redraw();
	}
	
	/**
	 * A simplified way of loading and unloading scenes
	 * Notice that the method is static so that anyone can call it.
	 * @param	p_newScene	The scene to switch to.
	 */
	public static function changeScene( p_newScene:IGameScene ):void
	{
	  if ( ( p_newScene is DisplayObject ) && ( _sceneContainer ) )
		{
		  if ( _currentScene != null )
			{
			  _sceneContainer.removeChild( _currentScene as DisplayObject );
			  _currentScene.unload();
			}
		  p_newScene.load();
		  _currentScene = p_newScene;
		  _sceneContainer.addChild( _currentScene as DisplayObject );
		}
	  else
		{
		  throw new Error("Error: game scenes must be of type DisplayObject and scene container must be set.");
		}
	}
  }
}
