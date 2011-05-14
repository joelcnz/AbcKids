//#Not sure on name
/**
 * Title: Base - variables with that are easiest to access
 * 
 * Kind of global variables (depending if this is imported in other modules)
 */
module base;

//import jeca.all;
import allegro5.allegro_font;

/// What appears on the windows title bar
immutable g_displayTitle = "Abc - Type, Hear, and See! :-)";

/// Main font
ALLEGRO_FONT* g_font; // public by default. //#Not sure on name

/// Store the number of letters in the English alphabet
immutable NUMBER_OF_LETTERS_IN_THE_ALPHABET = 26;

/// Font thickness list of possible settings
enum g_PrintFatness { fat, slim };

/// Empty string
enum g_emptyText = ""; // was g_nothing

/// Alphabet letter sounds folder
immutable g_voicesFolder = "Letters";

/// Sounds, pictures and other media
immutable g_playBackFolder = "Playback";

/// reference word devider
immutable g_devide = ", ";
immutable g_otherDevide = " / "; // unused

/// End of list of keys
immutable g_endOfList = ".";

immutable g_soundExtentions = ".ogg .wav .voc"; /// sound file extentions
immutable g_imageExtentions = ".jpg .png .bmp .tga .pcx"; /// image file extentions
immutable g_mediaExtentions = g_soundExtentions ~ ' ' ~ g_imageExtentions; /// both sound and image extentions
