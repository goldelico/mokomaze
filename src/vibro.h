/*  vibro.h
 *
 *  Vibro feedback routines
 *
 *  (c) 2009 Anton Olkhovik <ant007h@gmail.com>
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

@interface Vibro : NSObject

+ (int) init_vibro;
+ (int) set_vibro:(uint8_t) level;
+ (int) close_vibro;

+ (NSPoint) accel;	// accelerometer values in g for x and y

@end

#define VIBRO_H

#ifndef VIBRO_H
#define VIBRO_H

#include "types.h"

int init_vibro();
int set_vibro(BYTE level);
int close_vibro();

#endif /* VIBRO_H */

