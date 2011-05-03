/**
 * Title: Base - variables with that are easiest to access
 * 
 * Kind of global variables (depending if this is imported in other modules)
 */
module base;

//import jeca.all;
import allegro5.allegro_font;

/// Array of fonts
ALLEGRO_FONT*[] g_fonts; // public by default

/// Store the number of letters in the English alphabet
immutable NUMBER_OF_LETTERS_OF_THE_ALPHABET = 26;

/// Font thickness setting
enum g_PrintFatness { fat, slim };

/// Type of media, (input word, ref word)
enum g_MediaType {input, referance, invalid};

/// Empty string
enum g_emptyText = ""; // was g_nothing

/// Alphabet letter sounds folder
immutable g_voicesFolder = "Letters";

immutable g_playBackFolder = "Playback";

/// reference word devider
immutable g_devide = ", ";
immutable otherDevide = " / "; // unused

/// End of list of keys
immutable g_endOfList = ".";

immutable g_soundExtentions = ".ogg .wav .voc"; /// sound file extentions
immutable g_imageExtentions = ".jpg .png .bmp .tga .pcx"; /// image file extentions
immutable g_mediaExtentions = g_soundExtentions ~ ' ' ~ g_imageExtentions; /// both sound and image extentions
