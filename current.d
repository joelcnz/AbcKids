//#not sure on using with with only one method call
/**
 * Title: Current (like current picture)
 */
module current;

import std.stdio;
import std.string;
import std.traits: EnumMembers; // for foreach enums
import std.math;

import jeca.all;

import jtools.misc;

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
		_media = loadInMedia; // from media module
		_input = new Input;
	}
	
	void logic() {
	
		doInputStuff;
	
		version( ChangingFonts ) {
			static int fp = 0, fpt = 0;
			++fpt;
			if ( fpt == 20 ) {
				FONT = g_fonts[ fp = ( fp == g_fonts.length - 1 ? 0 : fp + 1 ) ];
				fpt = 0;
			}
		}
	}

	void draw() {
		al_clear_to_color( Colour.black );
		
		drawPicture; // if one

		drawReferenceWords; // words and stuff

		//#not sure on using with with only one method call
		with( _input )
			drawTextInput;

		al_flip_display;
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

	// check for picture (is it null or pointing to picture data)
	bool isAPicture( in ALLEGRO_BITMAP* picture ) {
		return ( picture !is null );
	}

	void drawPicture() {
		// Show picture
		if ( doShowPicture && isAPicture( _picture ) ) {
			real
				sw = al_get_bitmap_width( _picture ),
				sh = al_get_bitmap_height( _picture ),
				SCREEN_W = al_get_display_width( DISPLAY ),
				SCREEN_H = al_get_display_height( DISPLAY );
			real dw, dh;
			dw = dh = 0;
			/+
			auto bmp = al_create_bitmap( 640, 480 );
			scope( exit )
				al_destroy_bitmap( bmp );
			+/
			if ( sw > SCREEN_W || sh > SCREEN_H ) {
				real max = fmax( sw, sh );
				real max2 = ( max == sw ? 640 : 480 );

				dw = sw / max * max2,
				dh = sh / max * max2;
			} else {
				dw = sw;
				dh = sh;
			}
			/+
			mixin( trace( "max" ) );
			mixin( trace( "dw" ) );
			mixin( trace( "dh" ) );
			+/
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
			draw;

			/+
			al_draw_bitmap(
				/* soure bitmap: */ _picture,
				/* xpos: */ ( al_get_display_width( DISPLAY ) - al_get_bitmap_width( _picture ) ) / 2,
				/* ypos: */ 0,
				/* flags: */ 0 );
			+/
		}
	}

	void drawReferenceWords() {
		// show ref words
		if ( doShowRefWords ) {
			foreach( media; _media )
				foreach( textFatness; EnumMembers!g_PrintFatness ) // fat and slim type - fat prints slim x9
					media.showRefWord( textFatness );
		}
	}

	void doInputStuff() {
		// main Input method
		with( _input ) {
			_strInput = doKeyInput( /* ref: */ doShowRefWords, /* ref: */ doShowPicture );
			if ( ! doShowPicture )
				_picture = noPicture;

			if ( _strInput != g_emptyText )
				foreach( m; _media )
					if ( _strInput.tolower == m.text.stringText.tolower ) {
						m.tell;
						if ( isAPicture( m.picture ) )
							_picture = m.picture;
					}
		}
	}
}
