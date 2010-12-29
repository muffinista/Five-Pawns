package com.muffinlabs {
  /**
   * Based on http://www.rivermanmedia.com/programming/6-object-oriented-game-programming-the-scene-system
   * More info: http://gamedev.michaeljameswilliams.com/2009/04/13/as3-scene-system/
   * @author MichaelJWilliams
   */
  
  public interface IGameScene 
  {
	/**
	 * Update logic for this game scene.
	 */
	function update():void;
	/**
	 * Redraw everything on screen.
	 */
	function redraw():void;
	/**
	 * Load all of the data and graphics that this scene needs to function.
	 */
	function load():void;
	/**
	 * Unload everything that the garbage collector won't unload itself, including graphics.
	 */
	function unload():void;
  }
}