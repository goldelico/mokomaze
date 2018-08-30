/*  ball.h
 *
 *  Main game routines
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

#include "renderarea.h"

#define GRAV_CONST 9.8*1.5
#define FRICT_COEF 0.10
#define TIME_QUANT 1.9
#define SPEED_TO_PIXELS 0.05*1.5
#define FORCE_TREASURE 0.030
#define BUMP_COEF 0.3

@interface Ball : NSView
{
	NSTimer *timer;
	NSImage *ball_pixmap;
	NSImage *shadow_pixmap;
	NSPoint ballpos;
	IBOutlet NSView *menubuttons;
	IBOutlet NSTextField *levelno_lbl;
	IBOutlet NSButton *info1_lbl;
	IBOutlet NSButton *prev_lbl;
	IBOutlet NSButton *next_lbl;
	IBOutlet NSButton *reset_lbl;
	IBOutlet NSButton *exit_lbl;

	double wnd_w, wnd_h;

	double px,py;	// current ball position
	double vx,vy;	// current ball velocity

	double pr_px, pr_py;
	double pr_vx, pr_vy;

	double prev_px, prev_py;

	double tmp_px, tmp_py;
	double tmp_vx, tmp_vy;

	double hole_r, ball_r;
	int fall_hole_x, fall_hole_y;

#define ANIM_MAX 9
	int anim_stage, anim_timer;

	NSArray *qt_game_levels;
	int cur_level;

#define GAME_STATE_NORMAL   1	// normally running
#define GAME_STATE_FAILED   2	// fall into black hole
#define GAME_STATE_WIN      3	// finis reached
	int game_state;
	int new_game_state;

#define FASTCHANGE_INTERVAL 1000
	int fastchange_step;

}

- (void) drawRect:(NSRect) rect;
- (void) setMenuVis:(BOOL) x;
- (void) setLevelNo;
- (void) moveBall:(NSPoint) pos;
- (void) initState:(BOOL) redraw;
- (void) zeroAnim;
- (void) processGameState;
- (BOOL) testbump:(NSPoint) pnt :(NSPoint) mm_v;
- (BOOL) edgebump:(NSPoint) t :(NSPoint) pnt :(NSPoint) mm_v;
- (BOOL) line:(double) x0 :(double) y0 :(double) x1 :(double) y1
			 :(double) vx0 :(double) vy0 :(double) vx1 :(double) vy1;
- (void) tout:(NSPoint) pnt;
- (void) apply_temp_phys_res;
- (void) post_temp_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
- (void) post_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
- (void) bumpVibrate:(double) speed;
- (void) setButtonsPics;
- (void) accceleate:(NSPoint) acc;
- (void) timerAction;
- (int) gameState;

- (IBAction) screenTouchedPause:(id) sender;
- (IBAction) screenTouchedContinue:(id) sender;
- (IBAction) nextLevel:(id) sender;
- (IBAction) prevLevel:(id) sender;
- (IBAction) restart:(id) sender;

@end
