/*  renderarea.cpp
 *
 *  Game field renderer
 *
 *  (c) 2009-2010 Anton Olkhovik <ant007h@gmail.com>
 *  (c) 2018 Nikolaus Schaller <hns@goldelico.com> -- converted to Obj-C
 *
 *  Based on original renderarea.cpp from Qt Basic Drawing Example
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

#import "paramsloader.h"
#import "renderarea.h"

@implementation RenderArea

- (id) initWithFrame:(NSRect) frame
{
	if((self=[super initWithFrame:frame]))
		{
		hole_pixmap=[[NSImage imageNamed:@"hole.png"] retain];
		[hole_pixmap setFlipped:YES];
		fin_pixmap=[[NSImage imageNamed:@"fin.png"] retain];
		[fin_pixmap setFlipped:YES];
		desk_pixmap=[[NSImage imageNamed:@"desk.png"] retain];
		[desk_pixmap setFlipped:YES];
		wall_pixmap=[[NSImage imageNamed:@"wall.png"] retain];
		[wall_pixmap setFlipped:YES];
		lvl_pixmap=[[NSImage alloc] initWithSize:frame.size];
		_antialiased = NO;
		}
	return self;
}

- (void) dealloc
{
	[hole_pixmap release];
	[fin_pixmap release];
	[desk_pixmap release];
	[wall_pixmap release];
	[lvl_pixmap release];
	[super dealloc];
}

- (void) awakeFromNib
{
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	[pl load_params:[pl levelpack]];
	re_game_levels = [[pl GetGameLevels] retain];
}

- (void) setLevel:(int) lvl_no;
{ // prepare background pixmap for given game level
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	int i;

	re_cur_level = lvl_no;

	[lvl_pixmap lockFocus];

	/* draw background image */
	NSSize sz=[lvl_pixmap size];
	[desk_pixmap drawInRect:NSMakeRect(0, 0, sz.width, sz.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];

	/* draw boxes, holes, checkpoints */
	double hole_r=[pl holeRadius];
	NSDictionary *level=[[pl GetGameLevels] objectAtIndex:re_cur_level];

	NSArray *valList=[level objectForKey:@"boxes"];

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint p1=NSMakePoint([[val objectForKey:@"x1"] doubleValue], [[val objectForKey:@"y1"] doubleValue]);
		NSPoint p2=NSMakePoint([[val objectForKey:@"x2"] doubleValue], [[val objectForKey:@"y2"] doubleValue]);
		[self renderWallShadow:p1 :p2];
		}

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint p1=NSMakePoint([[val objectForKey:@"x1"] doubleValue], [[val objectForKey:@"y1"] doubleValue]);
		NSPoint p2=NSMakePoint([[val objectForKey:@"x2"] doubleValue], [[val objectForKey:@"y2"] doubleValue]);
		NSRect rect=NSMakeRect(p1.x, p1.y, p2.x-p1.x, p2.y-p1.y);
		[wall_pixmap drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
		}

	valList=[level objectForKey:@"holes"];

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint point=NSMakePoint([[val objectForKey:@"x"] doubleValue], [[val objectForKey:@"y"] doubleValue]);
		NSRect rect=NSMakeRect(point.x-hole_r, point.y-hole_r, 2*hole_r, 2*hole_r);
		[hole_pixmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		}

	valList=[level objectForKey:@"checkpoints"];

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint point=NSMakePoint([[val objectForKey:@"x"] doubleValue], [[val objectForKey:@"y"] doubleValue]);
		NSRect rect=NSMakeRect(point.x-hole_r, point.y-hole_r, 2*hole_r, 2*hole_r);
		[fin_pixmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		}

	[lvl_pixmap unlockFocus];
}

- (void) renderWallShadow:(NSPoint) p1 :(NSPoint) p2;
{
	int bx1=p1.x, by1=p1.y;
	int bx2=p2.x, by2=p2.y;

	bx2--;
	by2--;

	float initalpha = 90/255.0;
	[[NSColor colorWithCalibratedRed: 0 green:0 blue:0 alpha:initalpha] set];

	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bx1-1, by1) toPoint:NSMakePoint(bx1-1, by2)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bx1, by1-1) toPoint:NSMakePoint(bx2, by1-1)];

	int box_shadow_length_scaled = 10;
	for (int j=0; j<1+box_shadow_length_scaled; j++)
		{
		[[NSColor colorWithCalibratedRed: 0 green:0 blue:0 alpha:initalpha - ((60/255.0)*j)/box_shadow_length_scaled] set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(bx2+j-1, by1+j) toPoint:NSMakePoint(bx2+j+1, by2+j+1)];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(bx1+j, by2+j+1) toPoint:NSMakePoint(bx2+j, by2+j+1)];
		}
}

- (BOOL) isOpaque; { return YES; }
- (BOOL) isFlipped; { return YES; }

- (void) drawRect:(NSRect) rect
{
	[lvl_pixmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
}

- (void) mouseDown:(NSEvent *) event
{
	// ? loop until released...
	[self sendAction:[self action] to:[self target]];
}

@end
