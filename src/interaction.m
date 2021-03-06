/*  interaction.m
 *
 *  Vibro feedback routines
 *
 *  (c) 2009 Anton Olkhovik <ant007h@gmail.com>
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

#import "interaction.h"

#ifdef __APPLE__
#import <AudioToolbox/AudioToolbox.h>
#else
#import <CoreMotion/CoreMotion.h>
#import <CoreDevice/CoreDevice.h>	// we have AudioServicesPlaySystemSoundWithVibration() defined here
static CMMotionManager *mm;
#endif

@implementation Interaction

+ (BOOL) hasAccel;
{
#ifdef __APPLE__
	return NO;
#else
	if(!mm)
		{
		mm=[CMMotionManager new];
		[mm startDeviceMotionUpdates];
		}
	return [mm hasAccelerometer];
#endif
}

+ (NSPoint) accel;
{ // accelerometer values in g for x and y
#ifdef __APPLE__
	// random walk for demo purposes
#define K 0.6
	return NSMakePoint(K*((float)rand()/((float)RAND_MAX)-0.5), K*((float)rand()/((float)RAND_MAX)-0.5));
#else	// QuantumSTEP
	if(!mm)
		[self hasAccel];	// define mm
	CMDeviceMotion *m=[mm deviceMotion];
	CMAcceleration g=[m gravity];
	return NSMakePoint(g.x, g.y);
#endif
}

+ (int) set_vibro:(uint8_t) level;
{
#ifdef __APPLE__
	NSBeep();
#else
	AudioServicesStopSystemSound(kSystemSoundID_Vibrate);

	int64_t vibrationLength = level;

	NSArray *pattern=
			[NSArray arrayWithObjects:
				[NSNumber numberWithBool:YES],
				[NSNumber numberWithFloat:vibrationLength],
				[NSNumber numberWithBool:NO],
				[NSNumber numberWithFloat:0],
				nil];

	NSMutableDictionary *dict=
			[NSMutableDictionary dictionaryWithObjectsAndKeys:pattern, @"VibePattern",
						[NSNumber numberWithDouble:1.0], @"Intensity",
						nil];

	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
#endif
	return 0;
}

@end
