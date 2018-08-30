/*  form.cpp
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

#import "paramsloader.h"
#import "vibro.h"
#import "ball.h"

#ifdef __APPLE__
#define FRAME_RATE		30.0
#else
#define FRAME_RATE		10.0
#endif
#define MAX_BUMP_SPEED	160.0
#define MIN_BUMP_SPEED	10

double calcdist(NSPoint p1, NSPoint p2)
{
	return sqrt((p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y));
}

double calclen(NSPoint p)
{
	return sqrt(p.x*p.x + p.y*p.y);
}

NSPoint normalize(NSPoint p)
{
	NSPoint r;
	double len = calclen(p);
	r.x = p.x/len;
	r.y = p.y/len;
	return r;
}

int inbox(NSPoint p, NSRect box)
{
	return NSPointInRect(p, box);
}

int incircle(NSPoint p, NSPoint c, double cr)
{
	return (calcdist(p, c) <= cr);
}

@implementation Ball

- (void) awakeFromNib
{
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	if([pl load_params:[pl levelpack]])
		[NSApp terminate:nil];

	qt_game_levels = [[pl getGameLevels] retain];

	cur_level = [pl userlevel];
	if (cur_level < 0) cur_level = 0;
	if (cur_level >= [qt_game_levels count])
		cur_level = (int) [qt_game_levels count] - 1;

	[self setLevelNo];

	hole_r=[pl holeRadius];
	ball_r=[pl ballRadius];

	NSSize wnd=[pl gameSize];
	wnd_w=wnd.width;
	wnd_h=wnd.height;

	ball_pixmap=[[NSImage imageNamed:@"ball.png"] retain];
	[ball_pixmap setFlipped:YES];
	shadow_pixmap=[[NSImage imageNamed:@"ball-shadow.png"] retain];

	[self initState:YES];
	[NSTimer scheduledTimerWithTimeInterval:1.0/FRAME_RATE target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (BOOL) isOpaque; { return NO; }
- (BOOL) isFlipped; { return YES; }

- (void) drawRect:(NSRect) rect
{
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	double br=[pl ballRadius];	// FIXME: not every time!
	if (game_state != GAME_STATE_NORMAL)
		{ // make ball become smaller over time
		br *= 1 - 0.40 * anim_timer / ANIM_MAX;
		}
	NSRect ball=NSMakeRect(ballpos.x-br, ballpos.y-br, 2*br, 2*br);
	NSRect shadow=ball;
	shadow.origin.x += br/5.0;	// shadow shift
	shadow.origin.y += br/5.0;
	[shadow_pixmap drawInRect:shadow fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[ball_pixmap drawInRect:ball fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void) setMenuVis:(BOOL) x;
{
	[self setLevelNo];
	[menubuttons setHidden:!x];
	[self setButtonsPics];
	[menubuttons setNeedsDisplay:YES];
}

- (BOOL) menuVis;
{
	return ![menubuttons isHidden];
}

- (void) setLevelNo;
{
	NSDictionary *level=[qt_game_levels objectAtIndex:cur_level];
	NSString *name=[level objectForKey:@"comment"];
	if(name)
		;
	NSString *str=[NSString stringWithFormat:@"Level %d/%lu", cur_level+1, (unsigned long)[qt_game_levels count]];
	[levelno_lbl setStringValue:str];
	[(RenderArea *) [self superview] setLevel:cur_level];	// update background image
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	[pl saveLevel:cur_level];
}

- (void) moveBall:(NSPoint) pos;
{
	ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
	ballpos=pos;
	if([pl getDebuggingLevel] == debuggingLevelGraphics)
		{ // also move in game
			NSPoint v;
			v.x=pos.x-pr_px;
			v.y=pos.y-pr_py;
			new_game_state = GAME_STATE_NORMAL;
			if([self testbump:pos :v])
				{
				px=pos.x;
				py=pos.y;
				pr_px = px;
				pr_py = py;
				prev_px = px;
				prev_py = py;
				}
			game_state = new_game_state;
		}
	[self setNeedsDisplay:YES];
}

#define MAX_PHYS_ITERATIONS 10
- (BOOL) line:(double) x0 :(double) y0 :(double) x1 :(double) y1
			 :(double) vx0 :(double) vy0 :(double) vx1 :(double) vy1;
{
	double x=x0, y=y0;
	double mm_vx=vx1, mm_vy=vy1;

	NSPoint vec;
	vec.x = x1-x0;
	vec.y = y1-y0;
	NSPoint norm_vec;
	double len = calclen(vec);

	norm_vec.x = vec.x/len;
	norm_vec.y = vec.y/len;
	double k=0;
	BOOL muststop=NO;

	while (!muststop)
		{
		k += 1;
		if (k>=len)
			{
			k=len;
			muststop=YES;
			}
		x = x0 + norm_vec.x*k;
		y = y0 + norm_vec.y*k;
		if ([self testbump:NSMakePoint(x, y) :NSMakePoint(mm_vx, mm_vy)])
			{
			int ko=0;
			while (new_game_state == GAME_STATE_NORMAL)
				{
				ko++;
				//TODO: lite testbump version
				BOOL bump = [self testbump:tmp_p :tmp_v];
				if ( (!bump) || (ko >= MAX_PHYS_ITERATIONS) )
					break;
				}
			[self apply_temp_phys_res];
			game_state = new_game_state;	// may have changed to WIN or FAIL
			return YES;
			}
		}

	return NO;
}

- (void) initState:(BOOL) redraw;
{

	NSDictionary *val=[[qt_game_levels objectAtIndex:cur_level] objectForKey:@"init"];
	NSPoint point=NSMakePoint([[val objectForKey:@"x"] doubleValue], [[val objectForKey:@"y"] doubleValue]);
	px=point.x, py=point.y;
	vx=0; vy=0;

	pr_px=px; pr_py=py;
	pr_vx=0; pr_vy=0;

	prev_px=px; prev_py=py;
	game_state = GAME_STATE_NORMAL;
	[self moveBall:NSMakePoint(px, py)];

	[self zeroAnim];

	if(redraw)
		{
		[self setLevelNo];
		[self setButtonsPics];
		[self setNeedsDisplay:YES];
		}
}

- (void) zeroAnim;
{
	anim_stage = 0;
	anim_timer = 0;
}

- (int) gameState;
{
	return game_state;
}

- (void) processGameState;
{
	if (game_state == GAME_STATE_FAILED)
		{
		[self initState:NO];
		}

	if (game_state == GAME_STATE_WIN)
		{
		if (cur_level == [qt_game_levels count] - 1)
			{ // last level
			cur_level = 0;
			}
		else
			{
			cur_level++;
			}
		[self initState:YES];
		}
}

- (BOOL) testbump:(NSPoint) pnt :(NSPoint) mm_v;
{
	int i;

	// Loop over all finals

	NSDictionary *level=[qt_game_levels objectAtIndex:cur_level];

	NSArray *valList=[level objectForKey:@"checkpoints"];

	for (i=0; i<[valList count]; i++)
		{ // check finis
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint final_hole=NSMakePoint([[val objectForKey:@"x"] doubleValue], [[val objectForKey:@"y"] doubleValue]);
		double dist = calcdist(pnt, final_hole);
		if (dist <= hole_r)
			{
			fall_hole_x = final_hole.x;
			fall_hole_y = final_hole.y;
			new_game_state = GAME_STATE_WIN;
			[self post_temp_phys_res:pnt :mm_v];
			return YES;
			}
		}

	// Loop over all holes

	valList=[level objectForKey:@"holes"];

	for (i=0; i<[valList count]; i++)
		{ // check holes
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint hole=NSMakePoint([[val objectForKey:@"x"] doubleValue], [[val objectForKey:@"y"] doubleValue]);
		NSRect boundbox=NSMakeRect(hole.x - hole_r, hole.y - hole_r, 2*hole_r, 2*hole_r);
		if (inbox(pnt, boundbox))
			{
			double dist = calcdist(pnt, hole);
			if (dist <= hole_r)
				{
				fall_hole_x = hole.x;
				fall_hole_y = hole.y;
				new_game_state = GAME_STATE_FAILED;
				[self post_temp_phys_res:pnt :mm_v];
				return YES;
				}
			}
		}

	BOOL retval = NO;

	// Loop over all walls

	valList=[level objectForKey:@"boxes"];

	for (i=0; i<[valList count]; i++)
		{
		NSDictionary *val=[valList objectAtIndex:i];
		NSPoint p1=NSMakePoint([[val objectForKey:@"x1"] doubleValue], [[val objectForKey:@"y1"] doubleValue]);
		NSPoint p2=NSMakePoint([[val objectForKey:@"x2"] doubleValue], [[val objectForKey:@"y2"] doubleValue]);
		NSRect box=NSMakeRect(p1.x, p1.y, p2.x-p1.x, p2.y-p1.y);
		NSRect boundbox=NSInsetRect(box, -ball_r, -ball_r);
		if (inbox(pnt, boundbox))
			{
			if (inbox(NSMakePoint(pnt.x, pnt.y-ball_r), box))
				{
				[self bumpVibrate:mm_v.y];
				pnt.y = p2.y+ball_r + 0.2;
				mm_v.y = -mm_v.y * BUMP_COEF;
				retval = YES;
				}
			if (inbox(NSMakePoint(pnt.x, pnt.y+ball_r), box))
				{
				[self bumpVibrate:mm_v.y];
				pnt.y = p1.y-ball_r - 1.00;
				mm_v.y = -mm_v.y * BUMP_COEF;
				retval = YES;
				}
			if (inbox(NSMakePoint(pnt.x-ball_r, pnt.y), box))
				{
				[self bumpVibrate:mm_v.x];
				pnt.x = p2.x+ball_r + 0.2;
				mm_v.x = -mm_v.x * BUMP_COEF;
				retval = YES;
				}
			if (inbox(NSMakePoint(pnt.x+ball_r, pnt.y), box))
				{
				[self bumpVibrate:mm_v.x];
				pnt.x = p1.x-ball_r - 1.00;
				mm_v.x = -mm_v.x * BUMP_COEF;
				retval = YES;
				}

			if ([self edgebump:NSMakePoint(p1.x, p1.y) :pnt :mm_v]) return YES;
			if ([self edgebump:NSMakePoint(p2.x, p1.y) :pnt :mm_v]) return YES;
			if ([self edgebump:NSMakePoint(p2.x, p2.y) :pnt :mm_v]) return YES;
			if ([self edgebump:NSMakePoint(p1.x, p2.y) :pnt :mm_v]) return YES;
			}

		}

	if (retval)
		{
		[self post_temp_phys_res:pnt :mm_v];
		}

	return retval;
}

- (BOOL) edgebump:(NSPoint) t :(NSPoint) pnt :(NSPoint) mm_v;
{
	NSPoint touch=t;
	if (incircle(touch, pnt, ball_r))
		{
		NSPoint tmp_norm;
		tmp_norm.x = (pnt.x - touch.x);
		tmp_norm.y = (pnt.y - touch.y);
		NSPoint norm = normalize(tmp_norm);
		mm_v.y = -mm_v.y;
		double dot_norm_vect = mm_v.x*norm.x + mm_v.y*norm.y;
		mm_v.x = mm_v.x - 2*norm.x*dot_norm_vect;
		mm_v.y = mm_v.y - 2*norm.y*dot_norm_vect;

		double vpr_x = -fabs(dot_norm_vect)*norm.x;
		double vpr_y = -fabs(dot_norm_vect)*norm.y;
		[self bumpVibrate:calclen(NSMakePoint(vpr_x, vpr_y))];

		double dop_x = (1-BUMP_COEF) * vpr_x;
		double dop_y = (1-BUMP_COEF) * vpr_y;
		mm_v.x = mm_v.x + dop_x;
		mm_v.y = mm_v.y + dop_y;
		mm_v.y = -mm_v.y;

		pnt.x = touch.x + norm.x*(ball_r+0.10);
		pnt.y = touch.y + norm.y*(ball_r+0.10);

		[self post_temp_phys_res:pnt :mm_v];
		return YES;
		}
	return NO;
}

- (void) tout:(NSPoint) pnt;
{ // apply accelerometer value
	double ax=pnt.x, ay=pnt.y;

	new_game_state = GAME_STATE_NORMAL;

	double mid_px=px, mid_py=py;
	double mid_vx=vx, mid_vy=vy;

	double v = sqrt(mid_vx*mid_vx+mid_vy*mid_vy);
	double a = sqrt(ax*ax+ay*ay);
	if ((v > 0) || (a > FORCE_TREASURE))
		{
		mid_vx += ax*GRAV_CONST * TIME_QUANT;
		mid_vy += ay*GRAV_CONST * TIME_QUANT;
		}
	if (fabs(mid_vx) > 0)
		{
		double dvx = fabs( FRICT_COEF * GRAV_CONST*cos(asin(ax)) );
		if (mid_vx>0)
			{
			mid_vx-=dvx;
			if (mid_vx<0) mid_vx=0;
			}
		else
			{
			mid_vx+=dvx;
			if (mid_vx>0) mid_vx=0;
			}
		}
	if (fabs(mid_vy) > 0)
		{
		double dvy = fabs( FRICT_COEF * GRAV_CONST*cos(asin(ay)) );
		if (mid_vy>0)
			{
			mid_vy-=dvy;
			if (mid_vy<0) mid_vy=0;
			}
		else
			{
			mid_vy+=dvy;
			if (mid_vy>0) mid_vy=0;
			}
		}

	mid_px +=  (mid_vx * SPEED_TO_PIXELS);
	mid_py += -(mid_vy * SPEED_TO_PIXELS);

	if (![self line:pr_px :pr_py :mid_px :mid_py :pr_vx :pr_vy :mid_vx :mid_vy])
		{
		[self post_temp_phys_res:NSMakePoint(mid_px, mid_py) :NSMakePoint(mid_vx, mid_vy)];
		[self apply_temp_phys_res];
		}
}

- (void) apply_temp_phys_res;
{
	[self post_phys_res:tmp_p :tmp_v];
}

- (void) post_temp_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
{
	if (pnt.x<ball_r)
		{
		[self bumpVibrate:mm_v.x]; //VIB_HOR
		pnt.x = ball_r;
		mm_v.x = -mm_v.x * BUMP_COEF;
		}
	if (pnt.x>wnd_w - ball_r)
		{
		[self bumpVibrate:mm_v.x];
		pnt.x = wnd_w - ball_r;
		mm_v.x = -mm_v.x * BUMP_COEF;
		}
	if (pnt.y<ball_r)
		{
		[self bumpVibrate:mm_v.y];
		pnt.y = ball_r;
		mm_v.y = -mm_v.y * BUMP_COEF;
		}
	if (pnt.y>wnd_h - ball_r)
		{
		[self bumpVibrate:mm_v.y];
		pnt.y = wnd_h - ball_r;
		mm_v.y = -mm_v.y * BUMP_COEF;
		}

	tmp_p = pnt;
	tmp_v.x = mm_v.x; tmp_v.y = mm_v.y;
}

- (void) post_phys_res:(NSPoint) pnt :(NSPoint) mm_v;
{
	px = pnt.x; py = pnt.y;
	[self moveBall:pnt];

	vx = mm_v.x; vy = mm_v.y;
	pr_px = px; pr_py = py;
	pr_vx = vx; pr_vy = vy;
}

- (void) bumpVibrate:(double) speed;
{
	double v = fabs(speed);
	double k = v/MAX_BUMP_SPEED;
	if (k>1) k=1;
	if (v>MIN_BUMP_SPEED)
		{
		uint8_t vlevel = (uint8_t)(k*63);
		[Vibro set_vibro:vlevel];
		}
}

- (void) setButtonsPics;
{ // enable/disable buttons
	[prev_lbl setEnabled:cur_level > 0];
	[next_lbl setEnabled:cur_level < [qt_game_levels count]-1];
	[reset_lbl setEnabled:cur_level > 0];
}

- (void) acccelerate:(NSPoint) acc;
{
	if (game_state == GAME_STATE_NORMAL)
		{
		[self tout:acc];
		if (game_state != GAME_STATE_NORMAL)
			{
			int bshift = (hole_r - ball_r) / 3;
			px = fall_hole_x + bshift;
			py = fall_hole_y + bshift;
			}
		}

	if (game_state != GAME_STATE_NORMAL)
		{ // animation is running
		if (anim_stage >= 1)	// is done
			[self processGameState];
		else
			{
			anim_timer += 1;
			if (anim_timer == ANIM_MAX)
				anim_stage = 1;
			}
		}

	[self moveBall:NSMakePoint(px, py)];
	prev_px = px;
	prev_py = py;
}

- (void) timerAction;
{
#if 0 // what is this fastchange_step good for?
	int new_cur_level = cur_level + fastchange_step;
	if (new_cur_level >= [qt_game_levels count]) new_cur_level = [qt_game_levels count]-1;
	if (new_cur_level < 0) new_cur_level = 0;
	if (new_cur_level != cur_level)
		{
		cur_level = new_cur_level;
		[self initState:YES];
		}
#endif
	if(![self menuVis])
		{ // process movements
			NSPoint acc;
			ParamsLoader *pl=(ParamsLoader *) [NSApp delegate];
			if([pl getDebuggingLevel] == debuggingLevelAccel)
				{
				acc=[self convertPoint:[_window mouseLocationOutsideOfEventStream] fromView:nil];
				// center and scale to range...
				}
			acc=[Vibro accel];
			[self acccelerate:acc];
		}
}

// actions

- (IBAction) screenTouchedPause:(id) sender;
{
	[self setMenuVis:YES];
	[sender setAction:@selector(screenTouchedContinue:)];
}

- (IBAction) screenTouchedContinue:(id) sender;
{
	[self setMenuVis:NO];
	[sender setAction:@selector(screenTouchedPause:)];
}

- (IBAction) nextLevel:(id) sender;
{
	if (cur_level < [qt_game_levels count]-1)
		{
		cur_level++;
		[self initState:YES];

		fastchange_step = +10;
#if FIXME // what is fastchange good for?
		if (timer->isActive())
			timer->stop();
		timer->start(FASTCHANGE_INTERVAL);
#endif

		[self setButtonsPics];
		}
}

- (IBAction) prevLevel:(id) sender;
{
	if(cur_level > 0)
		{
		cur_level--;
		[self initState:YES];
		}
}

- (IBAction) restart:(id) sender;
{
	cur_level=0;
	[self initState:YES];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem;
{
	NSString *action=NSStringFromSelector([menuItem action]);
	if([action isEqualToString:@"nextLevel:"])
		return cur_level < [qt_game_levels count]-1;
	if([action isEqualToString:@"prevLevel:"])
		return cur_level > 0;
	if([action isEqualToString:@"restart:"])
		return cur_level > 0;
	return YES;
}

@end
