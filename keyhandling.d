//#may be not needed after a library fix
//#not sure about having this class
/**
 * Handling closing the program - at the moment
 */
module keyhandling;

import jeca.all;

//#not sure about having this class, maybe use struct
class KeyHandling {
private:
	ALLEGRO_EVENT event;
	bool getNextEvent() {
		return al_get_next_event( QUEUE, &event );
	}
public:
	auto doKeysAndCloseHandling() {
		auto
			exitFalse = false,
			exitTrue = true;
		
		poll_input; //#may be not needed after a library fix
		
		if ( key[ ALLEGRO_KEY_ESCAPE ] )
			return exitTrue;
		
		// keep going through current events till none left, in which case contiune
		while( getNextEvent )
		{
			switch( event.type )
			{
				// close button includes Alt + F4 etc
				case ALLEGRO_EVENT_DISPLAY_CLOSE:
					return exitTrue;
					
				default:
				break;
			}
		}
		
		return exitFalse;
	}
}
