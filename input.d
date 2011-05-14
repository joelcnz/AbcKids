//#under construction - (repeating keys)
//#should break this method into two
//#speed (pitch?)
module input;

import std.stdio;
import std.string;
import std.file;
import std.conv;
import std.traits: EnumMembers; // for foreach enums
import std.array; // for empty

import jeca.all;

import base, texthandling;

/**
 * Key press handler
 */
struct Key {
	bool keydown = false;
	int tkey;
	
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

/**
 * For typing in the words to activate
 */
class Input {
public:
	this() {
		_text = new Text(
			/* xpos: */ 0,
			/* ypos: */ al_get_display_height( DISPLAY ) - al_get_font_line_height( g_font ),
			/* fat colour: */ Colour.blue,
			/* slim colour: */ Colour.cyan
		);
		
		// setup the keys
		foreach( keyIndex; keysStart .. keysEnd ) {
			_keys[ keyIndex ].tkey = keyIndex;
		}
		
		// go through the letters of the alphabet
		immutable a = 0, z = 26;
		// Use this sound in the case of each letter sound fails to load
		auto blowSnd = new Snd(  g_playBackFolder ~ "/blow.wav" );
		foreach( letter; a .. z ) {
			auto fileName = g_voicesFolder ~ `/` ~ lowercase[ letter ] ~ ".wav";

			auto otherFileName = fileName[ 0 .. $ - 4 ] ~ ".ogg";
			
			if ( ! exists( fileName ) && exists( otherFileName ) )
				fileName = otherFileName;

			if ( exists( fileName ) ) {
				_lsnds[ letter ] = new Snd( fileName );
				if ( _lsnds[ letter ] is null ) {
					writeln( fileName, " - not load! - Get hold of your vendor at once!" );
					_lsnds[ letter ] = blowSnd; // default sound
				}
			}
			else
				writeln( fileName, " - not exist! - Get hold of your vendor at once!" );
		}
	}

	/**
	 * Recieve input and play its letter
	 */
	//#should break this method into two
	auto doKeyInput( ref bool doShowRefWords, ref bool doShowPicture ) {
		// put object text into the care of string text until later
		string text = _text.stringText;

		// update text before exiting function
		scope( exit )
			_text.stringText = text;

		// Do input
		foreach( keyId; keysStart .. keysEnd ) //#not sure if keysEnd is a key, it isn't in the loop
			foreach( keyStuff; [ &doAlphabet, &doSpace, &doNumbers, &doBackSpace, &doEnter ] ) {
				auto result = keyStuff( keyId, text, doShowRefWords, doShowPicture );
				if ( ! result.empty )
					return result;
			}
		
		return g_emptyText;
	} // get input key
	
	/**
	 * Display input text on screen
	 */
	void drawTextInput() const {
		foreach( fatness; EnumMembers!g_PrintFatness )
			_text.draw( fatness );
	}
private:
	Key[ ALLEGRO_KEY_MAX + 1 ] _keys;
	Snd[ NUMBER_OF_LETTERS_IN_THE_ALPHABET ] _lsnds;
	IText _text;
	immutable
		keysStart = 0,
		keysEnd = ALLEGRO_KEY_MAX + 1;

	// Add a letter and play a sound if letter key hit
	string doAlphabet( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		if ( keyId >= ALLEGRO_KEY_A && keyId <= ALLEGRO_KEY_Z && _keys[ keyId ].keyHit ) {
			// Play letter
			_lsnds[ keyId - ALLEGRO_KEY_A ].play;

			// add letter
			enum keyShift = key[ ALLEGRO_KEY_LSHIFT ] || key[ ALLEGRO_KEY_RSHIFT ];
			text ~= ( ( ! keyShift ? 'a' : 'A' ) + ( keyId - ALLEGRO_KEY_A ) & 0xFF );
		}
		return g_emptyText;
	}
	
	string doSpace( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		if ( keyId == ALLEGRO_KEY_SPACE && _keys[ ALLEGRO_KEY_SPACE ].keyHit ) {
			text ~= ' ';
		}
		return g_emptyText;
	}
	
	string doNumbers( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		if ( keyId >= ALLEGRO_KEY_0 && keyId <= ALLEGRO_KEY_9 )
			if ( _keys[ keyId ].keyHit ) {
				text ~= '0' + ( keyId - ALLEGRO_KEY_0 ) & 0xFF;
			}
		return g_emptyText;
	}
	
	string doBackSpace( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		enum wordHasLength = text.length > 0;
		if ( wordHasLength && keyId == ALLEGRO_KEY_BACKSPACE && _keys[ ALLEGRO_KEY_BACKSPACE ].keyHit ) {
			text = text[ 0 .. $ - 1 ];
		}
		return g_emptyText;
	}

	string doEnter( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture ) {
		// Activate the entered word
		auto textIsSomeThing = text != g_emptyText;
		if ( keyId == ALLEGRO_KEY_ENTER && _keys[ ALLEGRO_KEY_ENTER ].keyHit ) {
			if ( textIsSomeThing ) {
				if ( doShowRefWords ) {
					// show picture without the words
					doShowRefWords = false;
					doShowPicture = true;
				}
				
				auto text2 = _text.stringText.idup;
				text = g_emptyText;
				
				return text2; // and here's a hasty return
			} // if _text.. is not nothing
			
			if ( text == g_emptyText ) {
				if ( ! doShowRefWords && doShowPicture ) {
					// show picture and words
					doShowRefWords = true;
					
					return g_emptyText;
				}
				
				if ( doShowRefWords && doShowPicture ) {
					// show words but no picture
					doShowPicture = false;
					return g_emptyText;
				}
			} // if input is nothing
		} // Activate the entered word
		return g_emptyText;
	}
} // class input
