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
		fin_pixmap=[[NSImage imageNamed:@"fin.png"] retain];
		desk_pixmap=[[NSImage imageNamed:@"desk.png"] retain];
		wall_pixmap=[[NSImage imageNamed:@"wall.png"] retain];
		lvl_pixmap=[[NSImage alloc] initWithSize:frame.size];
		_antialiased = NO;
		}
	return self;
}

- (void) dealloc
{
	[lvl_pixmap release];
	[super dealloc];
}

- (void) awakeFromNib
{
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	// überarbeiten...
	// es sollte sichergestellt werden dass die params geladen sind wenn man GetGameLevels aufruft

	[pl load_params:[pl levelpack]];
	re_game_levels = [[pl GetGameLevels] retain];
}

// fixme: read this from the levelpack!
// and scale to our real screen size
/*
 "window": {
 "width":  480,
 "height": 640
 },

 "ball": {
 "radius": 23
 },

 "hole": {
 "radius": 28
 }
*/

#define HOLE_R	28
#define BALL_R	23

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
		[self renderWallShadow:p1.x :p1.y :p2.x :p2.y];
		}

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint p1=NSMakePoint([[val objectForKey:@"x1"] doubleValue], [[val objectForKey:@"y1"] doubleValue]);
		NSPoint p2=NSMakePoint([[val objectForKey:@"x2"] doubleValue], [[val objectForKey:@"y2"] doubleValue]);
		NSRect rect=NSMakeRect(p1.x, p1.y, p2.x-p1.x, p2.y-p1.y);
		[wall_pixmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
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

- (void) renderWallShadow:(int) bx1 :(int) by1 :(int) bx2 :(int) by2;
{
	bx2--;
	by2--;

	int initalpha = 90;
	[[NSColor colorWithCalibratedRed: 0 green:0 blue:0 alpha:initalpha/100.0] set];

	[NSBezierPath setDefaultLineWidth:1.0];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bx1-1, by1) toPoint:NSMakePoint(bx1-1, by2)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(bx1, by1-1) toPoint:NSMakePoint(bx2, by2-1)];

	[[NSColor colorWithCalibratedRed: 0 green:0 blue:0 alpha:initalpha/100.0] set];

	// FIXME: loop?

#if FIXME
	col->setRed(0);
	col->setGreen(0);
	col->setBlue(0);
	col->setAlpha(initalpha);

	QPen *pen = new QPen();
	pen->setStyle(Qt::SolidLine);
	pen->setColor(*col);
	painter->setPen(*pen);
	painter->setBrush(Qt::NoBrush);

	painter->drawLine(bx1-1, by1, bx1-1, by2);
	painter->drawLine(bx1, by1-1, bx2, by1-1);

	int box_shadow_length_scaled = 10;
	for (int j=0; j<1+box_shadow_length_scaled; j++)
		{
		col->setAlpha(initalpha - 60*j/box_shadow_length_scaled);
		pen->setColor(*col);
		painter->setPen(*pen);

		painter->drawLine(bx2+j+1, by1+j, bx2+j+1, by2+j+1);
		painter->drawLine(bx1+j, by2+j+1, bx2+j, by2+j+1);
		}

	delete col;
	delete pen;
#endif
}

- (BOOL) isOpaque; { return YES; }

- (void) drawRect:(NSRect) rect
{
	[lvl_pixmap drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
}

- (void) mouseDown:(NSEvent *) event
{
	// loop until released (?)
	[self sendAction:[self action] to:[self target]];
}

@end

#if OLD

#include <QtGui>

#include "paramsloader.h"
#include "renderarea.h"
#include "types.h"

Config re_game_config;
Level* re_game_levels;
int re_game_levels_count;
int re_cur_level;

RenderArea::RenderArea(QWidget *parent, int w, int h)
: QWidget(parent)
{
	resize(w,h);
	lvl_pixmap = new QPixmap(QSize(w,h));

	hole_pixmap.load(QCoreApplication::applicationDirPath() + "/pics/qtmaze/hole.png");
	fin_pixmap.load(QCoreApplication::applicationDirPath() + "/pics/qtmaze/fin.png");
	desk_pixmap.load(QCoreApplication::applicationDirPath() + "/pics/qtmaze/desk.png");
	wall_pixmap.load(QCoreApplication::applicationDirPath() + "/pics/qtmaze/wall.png");

	setBackgroundRole(QPalette::Base);
	setAutoFillBackground(true);
	antialiased = false;

	re_game_config = GetGameConfig();
	re_game_levels = GetGameLevels();
	re_game_levels_count = GetGameLevelsCount();
	re_cur_level = GetUserSettings().level - 1;
}

RenderArea::~RenderArea()
{
	delete lvl_pixmap;
}

void RenderArea::setLevel(int lvl_no)
{
	re_cur_level = lvl_no;

	QPainter painter(lvl_pixmap);

	if (antialiased)
		{
		painter.setRenderHint(QPainter::Antialiasing, true);
		painter.translate(+0.5, +0.5);
		}

	painter.drawPixmap(0,0, desk_pixmap);

	Level *lvl = &re_game_levels[re_cur_level];
	int bcount = lvl->boxes_count;
	Box *boxes = lvl->boxes;
	for (int i=0; i<bcount; i++)
		{
		Box *box = &boxes[i];
		RenderWallShadow(&painter, box->x1,box->y1, box->x2,box->y2);
		}
	for (int i=0; i<bcount; i++)
		{
		Box *box = &boxes[i];
		QRect rect(
				   box->x1, box->y1,
				   box->x2 - box->x1, box->y2 - box->y1
				   );
		//painter.drawRect(rect);
		painter.drawPixmap(rect, wall_pixmap, rect);
		}

	for (int i=0; i<lvl->holes_count; i++)
		{
		Point *hole = &lvl->holes[i];
		painter.drawPixmap( hole->x - re_game_config.hole_r,
						   hole->y - re_game_config.hole_r,
						   hole_pixmap);
		}

	Point *fin = &lvl->fins[0];
	painter.drawPixmap( fin->x - re_game_config.hole_r,
					   fin->y - re_game_config.hole_r,
					   fin_pixmap);
}

QSize RenderArea::minimumSizeHint() const
{
	return QSize(100, 100);
}

QSize RenderArea::sizeHint() const
{
	return QSize(200, 200);
}

void RenderArea::setAntialiased(bool antialiased)
{
	this->antialiased = antialiased;
	update();
}

void RenderArea::paintEvent(QPaintEvent *event)
{
	QPainter painter(this);
	if (lvl_pixmap != NULL)
		{
		painter.drawPixmap(event->rect(), *lvl_pixmap, event->rect());
		}
}

void RenderArea::RenderWallShadow(QPainter *painter, int bx1, int by1, int bx2, int by2)
{
	bx2--;
	by2--;

	QColor *col = new QColor();
	int initalpha = 90;
	col->setRed(0);
	col->setGreen(0);
	col->setBlue(0);
	col->setAlpha(initalpha);

	QPen *pen = new QPen();
	pen->setStyle(Qt::SolidLine);
	pen->setColor(*col);
	painter->setPen(*pen);
	painter->setBrush(Qt::NoBrush);

	painter->drawLine(bx1-1, by1, bx1-1, by2);
	painter->drawLine(bx1, by1-1, bx2, by1-1);

	int box_shadow_length_scaled = 10;
	for (int j=0; j<1+box_shadow_length_scaled; j++)
		{
		col->setAlpha(initalpha - 60*j/box_shadow_length_scaled);
		pen->setColor(*col);
		painter->setPen(*pen);

		painter->drawLine(bx2+j+1, by1+j, bx2+j+1, by2+j+1);
		painter->drawLine(bx1+j, by2+j+1, bx2+j, by2+j+1);
		}

	delete col;
	delete pen;
}

#endif
