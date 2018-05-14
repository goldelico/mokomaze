/*  renderarea.h
 *
 *  Game field renderer
 *
 *  (c) 2009-2010 Anton Olkhovik <ant007h@gmail.com>
 *  (c) 2018 Nikolaus Schaller <hns@goldelico.com> -- converted to Obj-C
 *
 *  Based on original renderarea.h from Qt Basic Drawing Example
 *  Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies).
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

@interface RenderArea : NSControl
{
	IBOutlet NSImage *hole_pixmap;
	IBOutlet NSImage *fin_pixmap;
	IBOutlet NSImage *desk_pixmap;
	IBOutlet NSImage *wall_pixmap;
	NSImage *lvl_pixmap;
	BOOL _antialiased;
	NSArray *re_game_levels;
	int re_cur_level;
}

- (void) setLevel:(int) lvl_no;
- (void) drawRect:(NSRect) rect;
- (void) renderWallShadow:(NSPoint) p1 :(NSPoint) p2;

@end
