//#not work should look at D->UDA on delicious
//#hack, uses global symbol
//#not sure on using with with only one method call
/**
 * Title: Current (like current picture)
 */
module current;

import std.stdio;
import std.string;
import std.conv;
import std.traits: EnumMembers; // for foreach enums
import std.math;
import std.random;

import jeca.all;

import base, media, input;

/**
 * Title: Current class for current viewing state
 */
class Current {
public:
	
	this() {
		doShowRefWords = true,
		doShowPicture = false;
		noPicture = null;
		_strInput = g_emptyText;
		_media = Media.loadInMedia(); // from media module
		_input = new Input();
	}
	
	void logic() {
		doInputStuff();
	}

	void draw() {
		al_clear_to_color( Colour.black );
		
		drawPicture(); // if one

		drawReferenceWords(); // words and stuff

		//#not sure on using with with only one method call
		with(_input)
			drawTextInput();
		
		al_rest(0.005);

		al_flip_display();
	}
private:
	IMedia[] _media; // sound, picture, and word dynamic array
	Input _input; // handle keyboard input (user typing in the words/names)
	ALLEGRO_BITMAP* _picture; // current picture
	bool
		doShowRefWords,
		doShowPicture;
	
	ALLEGRO_BITMAP* noPicture;
	string _strInput;
	//alias g_inputLets _strInput; //#hack, uses global symbol

	void doInputStuff() {
		
		//if (__traits(getAttributes, typeof(_input)).to!string() == "tuple((Key))") //#not work should look at D->UDA on delicious
		//	writeln("A key");
		pragma(msg, __traits(getAttributes, typeof(_input)));

		// main Input method
		with( _input ) {
			_strInput = doKeyInput( /* ref: */ doShowRefWords, /* ref: */ doShowPicture );
			if ( ! doShowPicture )
				_picture = noPicture;

			if ( _strInput != g_emptyText ) {
				auto noMedia = true;
				foreach( m; _media ) {
					auto inputNameMatch = _strInput.toLower == m.text.stringText.toLower;
					if ( inputNameMatch ) {
						noMedia = false;
						m.tell;
						if ( isAPicture( m.picture ) )
							_picture = m.picture;
					}	
				}
				if ( noMedia && _strInput.length > 0 ) {
					IMedia m;
					do {
						m = _media[ uniform( 0, $ ) ];
					} while( ! isAPicture( m.picture ) );
					_picture = m.picture;
				}
			}
		}
	}
	
	// check for picture (is it null or pointing to picture data)
	bool isAPicture( in ALLEGRO_BITMAP* picture ) {
		return ( picture !is null );
	}

	void drawPicture() {
		// Show picture
		if ( doShowPicture && isAPicture( _picture ) ) {
			double
				sw = al_get_bitmap_width( _picture ),
				sh = al_get_bitmap_height( _picture ),
				SCREEN_W = al_get_display_width( DISPLAY ),
				SCREEN_H = al_get_display_height( DISPLAY );
			double dw, dh;
			dw = dh = 0;
			if ( sw > SCREEN_W || sh > SCREEN_H ) {
				double max = fmax( sw, sh );
				double max2 = ( max == sw ? 640 : 480 );

				dw = sw / max * max2,
				dh = sh / max * max2;
			} else {
				dw = sw;
				dh = sh;
			}
			
			void draw() {
				al_draw_scaled_bitmap(
					/* bitmap: */ _picture,
					/* sx: */ 0,
					/* sy: */ 0,
					/* sw: */ sw,
					/* sh: */ sh,
					/* dx: */ ( SCREEN_W - dw ) / 2,
					/* dy: */ 0,
					/* dw: */ dw,
					/* dh: */ dh,
					/* flags: */ 0
				);
			}
			draw();
		}
	}

	void drawReferenceWords() {
		// show ref words
		if ( doShowRefWords ) {
			foreach( media; _media )
				foreach( printFatness; EnumMembers!g_PrintFatness ) // fat and slim type - fat prints slim x9
					media.showRefWord( printFatness );
		}
	}
}
