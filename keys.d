/**
 * Keys struct, handle each key press
 */
import jeca.all;

import base;

/**
 * Key press handler
 */
struct Key {
	bool keydown = false;
	int tkey;
	
	/// Handle key press
	bool keyHit() {
		if ( key[ tkey ] ) {
			//if ( ! keydown || timer > 0 ) { //#under construction - (repeating keys)
			if ( ! keydown ) {
				keydown = true;
				
				return true;
			}
		} else 
			keydown = false;

		return false;
	}
}
