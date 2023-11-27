module main

import term.ui as tui
import strconv
import os

struct App {
mut:
	tui         &tui.Context = unsafe { nil }
	minutes     int
	seconds     int
	minutes_str string
	seconds_str string
	args        []string
}

fn main() {
	mut app := &App{}

	app.tui = tui.init(
		user_data: app
		frame_fn: frame
		event_fn: event
		hide_cursor: true
		frame_rate: 1
	)

	app.args = os.args.clone()

	app.parse_args()

	app.tui.run() or {}
}

fn frame(v voidptr) {
	mut app := unsafe { &App(v) }

	app.tui.clear()

	app.count_down()

	app.colon(38, 7)
	mins_str := app.minutes_str.split('')
	app.draw_n(strconv.atoi(mins_str[0]) or { 0 }, 0)
	app.draw_n(strconv.atoi(mins_str[1]) or { 0 }, 1)
	secs_str := app.seconds_str.split('')
	app.draw_n(strconv.atoi(secs_str[0]) or { 0 }, 2)
	app.draw_n(strconv.atoi(secs_str[1]) or { 0 }, 3)

	app.tui.reset()
	app.tui.flush()
}

fn event(e &tui.Event, v voidptr) {}

// Parses the app arguments and sets the proper minutes and seconds
fn (mut app App) parse_args() {
	if app.args.len <= 1 {
		return
	}

	mut res := app.args[1].trim(' ').split('')

	for i, c in res {
		if c == ':' {
			res.delete(i)
		}
	}

	if res.len >= 5 {
		app.minutes = 99
		app.seconds = 60

		return
	}

	for res.len < 4 {
		res.insert(0, '0')
	}

	app.minutes = strconv.atoi('${res[0]}${res[1]}') or { panic(err) }
	app.seconds = strconv.atoi('${res[2]}${res[3]}') or { panic(err) }

	if app.seconds > 60 {
		if app.minutes < 99 {
			app.seconds -= 60
			app.minutes += 1
		} else {
			app.seconds = 60
		}
	}
}

// Reduces one second when called, if seconds == 0 reduces a minute
// And sets the app seconds_str and minutes_str
fn (mut app App) count_down() {
	if app.seconds <= 0 && app.minutes > 0 {
		app.minutes -= 1
		app.seconds = 60
	}

	if app.seconds > 0 {
		app.seconds -= 1
	}

	if app.seconds < 10 {
		app.seconds_str = '0${app.seconds}'
	} else {
		app.seconds_str = '${app.seconds}'
	}
	if app.minutes < 10 {
		app.minutes_str = '0${app.minutes}'
	} else {
		app.minutes_str = '${app.minutes}'
	}
}

// Draws a number in a position specified by the parameters
fn (mut app App) draw_n(n int, pos int) {
	d := 19
	dy := 3
	mut dx := 3

	dx += d * pos

	match n {
		1 {
			app.v2(dx, dy)
			app.v4(dx, dy)
		}
		2 {
			app.h1(dx, dy)
			app.v2(dx, dy)
			app.h2(dx, dy)
			app.v3(dx, dy)
			app.h3(dx, dy)
		}
		3 {
			app.h1(dx, dy)
			app.h2(dx, dy)
			app.h3(dx, dy)
			app.v2(dx, dy)
			app.v4(dx, dy)
		}
		4 {
			app.v1(dx, dy)
			app.v2(dx, dy)
			app.h2(dx, dy)
			app.v4(dx, dy)
		}
		5 {
			app.h1(dx, dy)
			app.v1(dx, dy)
			app.h2(dx, dy)
			app.v4(dx, dy)
			app.h3(dx, dy)
		}
		6 {
			app.v1(dx, dy)
			app.h1(dx, dy)
			app.h2(dx, dy)
			app.v4(dx, dy)
			app.v3(dx, dy)
			app.h3(dx, dy)
		}
		7 {
			app.h1(dx, dy)
			app.v2(dx, dy)
			app.v4(dx, dy)
		}
		8 {
			app.h1(dx, dy)
			app.h2(dx, dy)
			app.h3(dx, dy)
			app.v1(dx, dy)
			app.v2(dx, dy)
			app.v3(dx, dy)
			app.v4(dx, dy)
		}
		9 {
			app.v1(dx, dy)
			app.h1(dx, dy)
			app.h2(dx, dy)
			app.h3(dx, dy)
			app.v2(dx, dy)
			app.v4(dx, dy)
		}
		else {
			app.h1(dx, dy)
			app.h3(dx, dy)
			app.v1(dx, dy)
			app.v2(dx, dy)
			app.v3(dx, dy)
			app.v4(dx, dy)
		}
	}
}

// Draws a line displacing it by the x and y position
// Each (h/v){number} procedure represents a horizontal or vertical line
fn (mut app App) h1(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(2 + x, 0 + y, 12 + x, 0 + y)
}

fn (mut app App) h2(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(2 + x, 6 + y, 12 + x, 6 + y)
}

fn (mut app App) h3(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(2 + x, 12 + y, 12 + x, 12 + y)
}

fn (mut app App) v1(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(0 + x, 1 + y, 0 + x, 5 + y)
	app.tui.draw_line(1 + x, 1 + y, 1 + x, 5 + y)
}

fn (mut app App) v2(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(13 + x, 1 + y, 13 + x, 5 + y)
	app.tui.draw_line(14 + x, 1 + y, 14 + x, 5 + y)
}

fn (mut app App) v3(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(0 + x, 7 + y, 0 + x, 11 + y)
	app.tui.draw_line(1 + x, 7 + y, 1 + x, 11 + y)
}

fn (mut app App) v4(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(13 + x, 7 + y, 13 + x, 11 + y)
	app.tui.draw_line(14 + x, 7 + y, 14 + x, 11 + y)
}

// Draws :
fn (mut app App) colon(x int, y int) {
	app.tui.set_bg_color(r: 255, g: 255, b: 255)
	app.tui.draw_line(0 + x, 0 + y, 1 + x, 0 + y)
	app.tui.draw_line(0 + x, 4 + y, 1 + x, 4 + y)
}
