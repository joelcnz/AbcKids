/**
 * World module
 * 
 * Has World class
 */
module world;

//version = ChangingFonts;

import std.stdio;
import std.string;

import jeca.all;
import jtools.misc;

import keyhandling, current;

/**
 * Main loop handler
 */
class World {
public:
	/**
	 * Constructor:
	 * 
	 * Setup display title,
	 * 
	 * Load media,
	 * 
	 * and setup Input instance
	 */
	this() {
		al_set_window_title( DISPLAY, "Abc - Type, Hear, and See! :-)" );
		
		_current = new Current;
		_keyHandling = new KeyHandling;
	}
	
	/**
	 * Main program loop
	 */
	void run() {
		auto exit = false, exitTrue = true;
		while( ! exit ) {
			if ( _keyHandling.doKeysAndCloseHandling == exitTrue )
				exit = true;
			
			with( _current )
				_current.logic,
				_current.draw;
	
			al_rest( 0.001 ) ;
		}
	}
private:
	Current _current; /// handles the current state (current picture and display)
	KeyHandling _keyHandling;
}
