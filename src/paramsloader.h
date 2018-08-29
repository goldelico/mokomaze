/*  paramsloader.h
 *
 *  Config and levelpack loader
 *
 *  (c) 2009-2010 Anton Olkhovik <ant007h@gmail.com>
 *  (c) 2018 Nikolaus Schaller <hns@goldelico.com> -- converted to Obj-C
 *
 *  This file is part of QtMaze (port of Mokomaze) - labyrinth game.
 *
 *  QtMaze is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  QtMaze is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with QtMaze.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>

@interface ParamsLoader : NSObject
{
	NSString *loaded_pack;	//file name
	NSDictionary *game_levels;
	NSString *level_pack;
	int userlevel;
	int vibro_enabled;
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSPopUpButton *stylePreference;
	enum debuggingLevel {
		debuggingLevelNone=0,
		debuggingLevelAccel=1,
		debuggingLevelGraphics=2
	} debuggingLevel;
}

- (int) load_params:(NSString *) levelpack;
- (NSArray *) getGameLevels;
- (NSDictionary *) getGameLevel:(int) level;
- (NSSize) gameSize;		// coordinate range in levelpack
- (NSString *) levelPackName;
- (NSString *) levelPackAuthor;
- (double) ballRadius;
- (double) holeRadius;
- (NSString *) levelpack;	// name of the levelpack stored in UserDefaults
- (int) userlevel;			// the level stored in UserDefauls
- (void) saveLevel:(int) n;	// store level in UserDefaults
- (BOOL) getVibroEnabled;
- (int) getDebuggingLevel;

- (IBAction) preferences:(id) sender;
- (IBAction) preferenceChanged:(id) sender;

@end
