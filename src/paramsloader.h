/*  paramsloader.h
 *
 *  Config and levelpack loader
 *
 *  (c) 2009-2010 Anton Olkhovik <ant007h@gmail.com>
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
	NSDictionary *game_levels;
	NSString *level_pack;
	int userlevel;
	int vibro_enabled;
}

- (int) load_params:(NSString *) levelpack;
- (NSArray *) GetGameLevels;
- (NSDictionary *) GetGameLevel:(int) level;
// each record is an NSDictionary
//   boxes = array(dict with x1, x2, y1, y2)
//   checkpoints = array(dict with x, y)
//   comment = string
//   holes = array(dict with x, y)
//   init = dict(x, y)
- (NSSize) gameSize;		// coordinate range in levelpack
- (NSString *) levelPackName;
- (NSString *) levelPackAuthor;
- (double) ballRadius;
- (double) holeRadius;
- (NSString *) levelpack;	// name of the levelpack stored in UserDefaults
- (int) userlevel;			// the level stored in UserDefauls
- (void) SaveLevel:(int) n;	// store level in UserDefaults
- (int) GetVibroEnabled;

@end

#define PARAMSLOADER_H

#ifndef PARAMSLOADER_H
#define PARAMSLOADER_H

#include "types.h"

void parse_command_line(int argc, char *argv[]);
int load_params();
Config GetGameConfig();
Level* GetGameLevels();
User GetUserSettings();
int GetGameLevelsCount();
int GetVibroEnabled();
Prompt GetArguments();
char* GetExecInit();
char* GetExecFinal();

void SaveLevel(int n);

#endif

