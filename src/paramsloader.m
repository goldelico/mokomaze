/*  paramsloader.cpp
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

#import "paramsloader.h"

@implementation ParamsLoader

- (void) dealloc
{
	[game_levels release];
	[level_pack release];
	[loaded_pack release];
	[super dealloc];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender;
{
	return YES;
}

- (void) awakeFromNib
{
	vibro_enabled=YES;
	debuggingLevel=debuggingLevelGraphics;
}

- (int) load_params:(NSString *) levelpack;
{
	if(!game_levels || !loaded_pack || ![levelpack isEqualToString:loaded_pack])
		{
		NSString *path=[[NSBundle mainBundle] pathForResource:levelpack ofType:@"json"];
		NSData *data=[NSData dataWithContentsOfFile:path];
		NSError *error=nil;
		NSDictionary *root=data?[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]:nil;
		if(!root)
			{
			NSString *defaultpack=@"main.levelpack";
			if([levelpack isEqualToString:defaultpack])
				{
				NSLog(@"failed to load and parse JSON %@: %@", levelpack, error);
				return -1;
				}
			return [self load_params:defaultpack];	// try default
			}
		[game_levels release];
		game_levels = [root retain];
		[loaded_pack release];
		loaded_pack=[levelpack retain];
		}
	return 0;
}

- (NSArray *) getGameLevels;
{
	return [game_levels objectForKey:@"levels"];
}

- (NSString *) levelPackAuthor;
{
	return [game_levels objectForKey:@"author"];
}

- (NSString *) levelPackName;
{
	return [game_levels objectForKey:@"name"];
}

- (NSSize) gameSize;
{ // coordinate range used in levelpack
	NSDictionary *val=[[game_levels objectForKey:@"requirements"] objectForKey:@"window"];
	return NSMakeSize([[val objectForKey:@"width"] doubleValue], [[val objectForKey:@"height"] doubleValue]);
}

- (double) ballRadius;
{
	return [[[[game_levels objectForKey:@"requirements"] objectForKey:@"ball"] objectForKey:@"radius"] doubleValue];
}

- (double) holeRadius;
{
	return [[[[game_levels objectForKey:@"requirements"] objectForKey:@"hole"] objectForKey:@"radius"] doubleValue];
}

/*
 * each record is an NSDictionary
 *   boxes = array(dict with x1, x2, y1, y2)
 *   checkpoints = array(dict with x, y)
 *   comment = string
 *   holes = array(dict with x, y)
 *   init = dict(x, y)
 */

- (NSDictionary *) getGameLevel:(int) level;
{
	return [[self getGameLevels] objectAtIndex:level];
}

- (NSString *) levelpack;
{
	NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
	[level_pack release];
	level_pack=[[ud objectForKey:@"levelpack"] retain];
	if(!level_pack)
		level_pack=@"//undefined//";
	userlevel=[[ud objectForKey:@"level"] intValue];
	return level_pack;
}

- (int) userlevel;
{
	return userlevel;
}

- (BOOL) getVibroEnabled;
{
	return vibro_enabled;
}

- (int) getDebuggingLevel;
{
	return debuggingLevel;
}

- (void) saveLevel:(int) n;
{
	NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
	[ud setObject:loaded_pack forKey:@"levelpack"];
	[ud setObject:[NSNumber numberWithInt:n] forKey:@"level"];
	[ud synchronize];
}

- (IBAction) preferences:(id) sender;
{
	// update popup and states
	// [preferencesWindow orderFrontAndMakeKey:nil];
}

- (IBAction) preferenceChanged:(id) sender;
{

}

@end
