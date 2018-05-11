/*  vibro.cpp
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

#import "vibro.h"

#ifdef __APPLE__
#import <AudioToolbox/AudioToolbox.h>
#else
#import <CoreMotion/CoreMotion.h>
#import <CoreDevice/CoreDevice.h>	// we have AudioServicesPlaySystemSoundWithVibration() defined here
#endif

@implementation Vibro

+ (NSPoint) accel;
{ // accelerometer values in g for x and y
#ifdef __APPLE__
	// random walk for demo purposes
#define K 0.6
	return NSMakePoint(K*((float)rand()/((float)RAND_MAX)-0.5), K*((float)rand()/((float)RAND_MAX)-0.5));
#else	// QuantumSTEP
	static CMMotionManager *mm;
	if(!mm)
		{
		mm=[CMMotionManager new];
		[mm startDeviceMotionUpdates];
		}
	CMDeviceMotion *m=[mm deviceMotion];
	CMAcceleration g=[m gravity];
	return NSMakePoint(g.x, g.y);
#endif
}

+ (int) init_vibro;
{
	return 0;
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
						[NSNumber numberWithDouble:1.0],
						nil];

	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
#endif
	return 0;
}

+ (int) close_vibro;
{
	return 0;
}

@end

#if OLD

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <fcntl.h>
#include <pthread.h>
#include <QVibrateAccessory>

#include "vibro.h"

QVibrateAccessory vib;

pthread_t vibro_timer;
int timer_set=0;

#define VIBRATION_TIME 33

int init_vibro()
{
	QVibrateAccessory vib;
}

void* callback(void *data)
{
	timer_set = 1;
	usleep(VIBRATION_TIME*1000);
	vib.setVibrateNow(false);
	timer_set = 0;
	return NULL;
}

int set_vibro(BYTE level)
{
	if (!timer_set)
		{
		vib.setVibrateNow(true);
		pthread_create( &vibro_timer, NULL, callback, NULL);
		}
	return 0;
}

int close_vibro()
{
	if (timer_set) pthread_join(vibro_timer, NULL);
	return 0;
}
#endif
