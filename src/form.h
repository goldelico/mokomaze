/*  form.h
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

#define PROC_ACC_DATA_INTERVAL 16


@interface Form : NSView
{
	NSTimer *timer;
	RenderArea *renderArea;
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

	double px,py;	// current position
	double vx,vy;	// current velocity

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

#define GAME_STATE_NORMAL   1
#define GAME_STATE_FAILED   2
#define GAME_STATE_WIN      3
	int game_state;
	int new_game_state;

#define FASTCHANGE_INTERVAL 1000
	int fastchange_step;

}

- (void) drawRect:(NSRect) rect;
- (void) setMenuVis:(BOOL) x;
- (void) SetLevelNo;
- (void) MoveBall:(double) x :(double) y;
- (void) InitState:(BOOL) redraw;
// int line(double x0, double y0, double x1, double y1,    double vx0,double vy0, double vx1,double vy1);
- (void) ZeroAnim;
- (void) ProcessGameState;
- (BOOL) testbump:(NSPoint) pnt :(NSPoint) mm_v;
- (BOOL) edgebump:(NSPoint) t :(NSPoint) pnt :(NSPoint) mm_v;
- (BOOL) line:(double) x0 :(double) y0 :(double) x1 :(double) y1
			 :(double) vx0 :(double) vy0 :(double) vx1 :(double) vy1;
- (void) tout:(NSPoint) pnt;
- (void) apply_temp_phys_res;
- (void) post_temp_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
- (void) post_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
- (void) BumpVibrate:(double) speed;
- (void) setButtonsPics;
- (void) acc_timerAction:(double) acx :(double) acy;
// FIXME: + (void) accel_callback(void *closure, double acx, double acy, double acz);
- (void) timerAction;
- (IBAction) ScreenTouchedPause:(id) sender;
- (IBAction) ScreenTouchedContinue:(id) sender;
- (IBAction) nextLevel:(id) sender;
- (IBAction) prevLevel:(id) sender;
- (IBAction) restart:(id) sender;

@end

#define EXAMPLE_H

#ifndef EXAMPLE_H
#define EXAMPLE_H
#include "ui_formbase.h"
#include "renderarea.h"

class Form : public QWidget, public Ui_FormBase
{
	Q_OBJECT

private:
	QTimer *timer;
	RenderArea *renderArea;
	QPixmap prev_pixmap, prev_p_pixmap, prev_i_pixmap;
	QPixmap next_pixmap, next_p_pixmap, next_i_pixmap;
	QPixmap reset_pixmap, reset_p_pixmap, reset_i_pixmap;
	QPixmap close_pixmap;
	void CheckLoadedPictures();
	void DisableScreenSaver();
	void EnableScreenSaver();
	void SetMenuVis(bool x);
	void SetLevelNo();
	void MoveBall(double x, double y);
	//--------------------------------
	void InitState(bool redraw = true);
	int line(double x0, double y0, double x1, double y1,    double vx0,double vy0, double vx1,double vy1);
	void ZeroAnim();
	void ProcessGameState();
	int testbump(double x,double y,   double mm_vx,double mm_vy);
	int edgebump(int tx,int ty,   double x,double y,   double mm_vx,double mm_vy);
	void tout(double ax, double ay);
	void apply_temp_phys_res();
	void post_temp_phys_res(double x, double y, double mm_vx, double mm_vy);
	void post_phys_res(double x, double y, double mm_vx, double mm_vy);
	void BumpVibrate(double speed);
	void setButtonsPics();
	void acc_timerAction(double acx, double acy);
	static void accel_callback(void *closure, double acx, double acy, double acz);

public:
	Form( QWidget *parent = 0, Qt::WFlags f = 0 );
	~Form();

	private slots:
	void timerAction();
	bool eventFilter(QObject *target, QEvent *event);
	void ScreenTouchedPause();
	void ScreenTouchedContinue();

protected:
	bool event(QEvent *);

};

#endif
