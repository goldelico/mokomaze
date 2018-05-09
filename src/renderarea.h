/*  renderarea.h
 *
 *  Game field renderer
 *
 *  (c) 2009-2010 Anton Olkhovik <ant007h@gmail.com>
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
#import "types.h"

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

	// target + action for screen tap
	// connect to Forms ScreenTouchedPause action
}

// - (NSSize) minimumSizeHint;
// - (NSSize) sizeHint;
- (void) setAntialiased:(BOOL) antialiased;
- (void) setLevel:(int) lvl_no;
- (void) drawRect:(NSRect) rect;
- (void) renderWallShadow:(int) bx1 :(int) by1 :(int) bx2 :(int) by2;
- (BOOL) antialiased;

@end

#define RENDERAREA_H

#ifndef RENDERAREA_H
#define RENDERAREA_H

#include <QBrush>
#include <QPen>
#include <QPixmap>
#include <QWidget>

class RenderArea : public QWidget
{
	Q_OBJECT

public:
	QPixmap hole_pixmap;
	QPixmap fin_pixmap;
	QPixmap desk_pixmap;
	QPixmap wall_pixmap;
	RenderArea(QWidget *parent, int w, int h);
	~RenderArea();
	QSize minimumSizeHint() const;
	QSize sizeHint() const;

 public slots:
	void setAntialiased(bool antialiased);
	void setLevel(int lvl_no);

protected:
	void paintEvent(QPaintEvent *event);

private:
	void RenderWallShadow(QPainter *painter, int bx1, int by1, int bx2, int by2);
	bool antialiased;
	QPixmap *lvl_pixmap;
};

#endif
