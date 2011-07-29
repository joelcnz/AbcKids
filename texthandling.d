/**
 *	Text handling
 */
module texthandling;

import std.stdio;
import std.conv: convText = text, to; // Rename to avoid symbol collistion(sp)
import std.string: toStringz; // only allow access to toStringz
import std.traits;

import jeca.all;

import base;

interface IText {
	@property pure string stringText() const; // getter - IText A = new Media(..); string a = A.text;
	@property string stringText( in string stringText0 ); // setter - IText A = new Media(..); A.text = "goody dollars";
	@property pure real xpos() const; 
	@property pure real ypos() const;
	@property real xpos( in real xpos0 ); 
	@property real ypos( in real ypos0 );
	void draw( g_PrintFatness fatness ) const;
	void draw( real x, real y, g_PrintFatness fatness, in string text ) const;
}

/**
 * Handles the text part
 * 
 * To do: make it part of the JECA library
 */
class Text: IText {
private:
	string _stringText;
	real _x, _y;
	ALLEGRO_COLOR
		_fatColour,
		_slimColour;
public:
	@property pure string stringText() const { return _stringText; }
	@property string stringText( in string stringText0 ) { return _stringText = stringText0; }
	@property pure real xpos() const { return _x; }
	@property pure real ypos() const { return _y; }
	@property real xpos( in real xpos0 ) { return _x = xpos0; }
	@property real ypos( in real ypos0 ) { return _y = ypos0; }
	
	this( in real x, in real y, in ALLEGRO_COLOR fatColour, in ALLEGRO_COLOR slimColour) {
		this( x, y, fatColour, slimColour, g_emptyText );
	}
	
	this( in real x, in real y, in ALLEGRO_COLOR fatColour, in ALLEGRO_COLOR slimColour, in string stringText ) {
		xpos = x;
		ypos = y;
		_fatColour = fatColour;
		_slimColour = slimColour;
		_stringText = stringText;
	}
	
	void draw( g_PrintFatness printFatness ) const {
		draw( xpos, ypos, printFatness, stringText );
	}

	void draw( real x, real y, g_PrintFatness printFatness, in string stringText ) const {
		void drawThin( ALLEGRO_COLOR colour, real x, real y ) {
			al_draw_text(
				g_font, // ALLEGRO_FONT
				colour, // colour
				x, y, // xpos, ypos
				ALLEGRO_ALIGN_LEFT, // alignment
				toStringz( stringText ) // string text (char*)
			);
		}
		
		switch( printFatness ) {
			case g_PrintFatness.slim:
				drawThin( _slimColour, xpos + 1, ypos + 1 );
			break;
			case g_PrintFatness.fat:
				foreach( py;     _y .. _y + 3 )
					foreach( px; _x .. _x + 3 )
						drawThin( _fatColour, px, py );
			break;
			default:
				assert( false, convText( printFatness, " is invalid." ) );
		}
	} // draw
} // text
