const std = @import("std");
pub const c = @import("c.zig").c;
const build = @import("build");
pub const config_wrapper = @import("config");
pub const config: build.Config = blk: {
    @setEvalBranchQuota(10000);
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var stream = std.json.Scanner.initCompleteInput(fba.allocator(), config_wrapper.config);
    break :blk std.json.parseFromTokenSourceLeaky(build.Config, fba.allocator(), &stream, .{}) catch unreachable;
};

pub const Layout = @import("layout.zig").Layout;
pub const AnimEnable = @import("anim_enable.zig").AnimEnable;
pub const Dir = @import("dir.zig").Dir;

pub const Align = enum(u8) {
    Default = c.LV_ALIGN_DEFAULT,
    TopLeft = c.LV_ALIGN_TOP_LEFT,
    TopMid = c.LV_ALIGN_TOP_MID,
    TopRright = c.LV_ALIGN_TOP_RIGHT,
    BottomLeft = c.LV_ALIGN_BOTTOM_LEFT,
    BottomMid = c.LV_ALIGN_BOTTOM_MID,
    BottomRight = c.LV_ALIGN_BOTTOM_RIGHT,
    LeftMid = c.LV_ALIGN_LEFT_MID,
    RightMid = c.LV_ALIGN_RIGHT_MID,
    Center = c.LV_ALIGN_CENTER,

    OutTopLeft = c.LV_ALIGN_OUT_TOP_LEFT,
    OutTopMid = c.LV_ALIGN_OUT_TOP_MID,
    OutTopRight = c.LV_ALIGN_OUT_TOP_RIGHT,
    OutBottomLeft = c.LV_ALIGN_OUT_BOTTOM_LEFT,
    OutBottomMid = c.LV_ALIGN_OUT_BOTTOM_MID,
    OutBottomRight = c.LV_ALIGN_OUT_BOTTOM_RIGHT,
    OutLeftTop = c.LV_ALIGN_OUT_LEFT_TOP,
    OutLeftMid = c.LV_ALIGN_OUT_LEFT_MID,
    OutLeftBottom = c.LV_ALIGN_OUT_LEFT_BOTTOM,
    OutRightTop = c.LV_ALIGN_OUT_RIGHT_TOP,
    OutRightMid = c.LV_ALIGN_OUT_RIGHT_MID,
    OutRightBottom = c.LV_ALIGN_OUT_RIGHT_BOTTOM,
    _,
};

pub const Point = c.lv_point_t;
pub const Coord = c.lv_coord_t;

pub const Screen = @import("Screen.zig");
pub const Display = struct {
    inner: *c.lv_display_t,
};
pub const Indev = struct {
    inner: *c.lv_indev_t,

    pub fn create() Indev {
        return .{ .inner = c.lv_indev_create().? };
    }

    pub fn delete(self: Indev) Indev {
        c.lv_indev_delete(self.inner);
    }

    pub fn getNext(self: Indev) Indev {
        return .{ .inner = c.lv_indev_get_next(self.inner) };
    }

    pub fn read(self: Indev) void {
        c.lv_indev_read(self.inner);
    }

    pub fn readTimerCallback(self: Indev) void {
        c.lv_indev_read_timer_cb(self.inner);
    }

    pub fn enable(self: Indev, value: bool) void {
        c.lv_indev_enable(self.inner, value);
    }

    pub fn active() ?Indev {
        return if (c.lv_indev_active()) |dev| .{ .inner = dev } else null;
    }

    pub const Type = enum(c_int) {
        None = c.LV_INDEV_TYPE_NONE,
        Pointer = c.LV_INDEV_TYPE_POINTER,
        Keypad = c.LV_INDEV_TYPE_KEYPAD,
        Button = c.LV_INDEV_TYPE_BUTTON,
        Encoder = c.LV_INDEV_TYPE_ENCODER,
    };

    pub fn setType(self: Indev, type_: Type) void {
        c.lv_indev_set_type(self.inner, @intFromEnum(type_));
    }

    pub fn getType(self: Indev) Type {
        return @enumFromInt(c.lv_indev_get_type(self.inner));
    }

    // TODO: read_cb

    pub fn setUserData(self: Indev, user_data: *anyopaque) void {
        c.lv_indev_set_user_data(self.inner, user_data);
    }

    pub fn getUserData(self: Indev) ?*anyopaque {
        return c.lv_indev_get_user_data(self.inner);
    }

    pub fn setDriverData(self: Indev, driver_data: *anyopaque) void {
        c.lv_indev_set_driver_data(self.inner, driver_data);
    }

    pub fn getDriverData(self: Indev) ?*anyopaque {
        return c.lv_indev_get_driver_data(self.inner);
    }

    pub fn setDisplay(self: Indev, display: Display) void {
        c.lv_indev_set_display(self.inner, display.inner);
    }

    pub fn getDisplay(self: Indev) ?Display {
        return if (c.lv_indev_get_display(self.inner)) |disp| .{ .inner = disp } else null;
    }

    pub fn reset(self: Indev, obj: Obj) void {
        c.lv_indev_reset(self.inner, obj.obj);
    }

    pub fn resetLongPress(self: Indev) void {
        c.lv_indev_reset_long_press(self.inner);
    }

    pub fn setCursor(self: Indev, obj: Obj) void {
        c.lv_indev_set_cursor(self.inner, obj.obj);
    }

    // TODO: set_group
    // TODO: set_button_points
    // TODO: get_point

    pub fn getGestureDir(self: Indev) Dir {
        return @enumFromInt(c.lv_indev_get_gesture_dir(self.inner));
    }

    pub fn getKey(self: Indev) u32 {
        return c.lv_indev_get_key(self.inner);
    }

    pub fn getScrollDir(self: Indev) Dir {
        return @enumFromInt(c.lv_indev_get_scroll_dir(self.inner));
    }

    pub fn getScrollObj(self: Indev) ?Obj {
        return if (c.lv_indev_get_scroll_obj(self.inner)) |obj| .{ .obj = obj } else null;
    }

    // TODO: get_vect

    pub fn waitRelease(self: Indev) void {
        c.lv_indev_wait_release(self.inner);
    }

    pub fn getActiveObj(self: Indev) ?Obj {
        return if (c.lv_indev_get_active_obj(self.inner)) |obj| .{ .obj = obj } else null;
    }

    pub fn getReadTimer(self: Indev) ?c.lv_timer_t {
        return if (c.lv_indev_get_read_timer(self.inner)) |timer| timer else null;
    }

    pub const Mode = enum(c_int) {
        None = c.LV_INDEV_MODE_NONE,
        Timer = c.LV_INDEV_MODE_TIMER,
        Event = c.LV_INDEV_MODE_EVENT,
        _,
    };

    pub fn setMode(self: Indev, mode: Mode) void {
        c.lv_indev_set_mode(self.inner, @intFromEnum(mode));
    }

    pub fn getMode(self: Indev) Mode {
        return @enumFromInt(c.lv_indev_get_mode(self.inner));
    }

    // TODO: search_obj
    // TODO: add_event_cb
    // TODO: get_event_count
    // TODO: get_event_dsc
    // TODO: remove_event
    // TODO: remove_event_cb_with_user_data
    // TODO: send_event
};
pub const Obj = @import("Obj.zig");

const widgets_config = config.lvgl.widgets;

// core widgets
pub const Arc = @import("Arc.zig");
pub const Bar = @import("Bar.zig");
pub const Button = @import("Button.zig");
// pub const ButtonMatrix = @import("ButtonMatrix.zig");
// pub const Canvas = @import("Canvas.zig");
pub const Checkbox = @import("Checkbox.zig");
pub const Dropdown = @import("Dropdown.zig");
// pub const Img = @import("Img.zig");
pub const Label = @import("Label.zig");
pub const Line = @import("Line.zig");
// pub const Roller = @import("Roller.zig");
pub const Slider = @import("Slider.zig");
pub const Switch = @import("Switch.zig");
pub const Table = @import("Table.zig");
// pub const Textarea = @import("Textarea.zig");

// extra widgets
pub const List = @import("List.zig");
pub const TabView = @import("TabView.zig");

pub const Anim = @import("Anim.zig");

pub const Flex = @import("Flex.zig");

pub const task = struct {
    pub fn handler() void {
        _ = c.lv_task_handler();
    }
};

pub const sdl = struct {
    pub const window = struct {
        display: Display,

        pub fn create(width: i32, height: i32) @This() {
            return .{
                .display = .{ .inner = c.lv_sdl_window_create(width, height).? },
            };
        }

        pub fn setResizable(self: @This(), value: bool) void {
            c.lv_sdl_window_set_resizeable(self.display.inner, value);
        }

        pub fn setZoom(self: @This(), zoom: u8) void {
            c.lv_sdl_window_set_zoom(self.display.inner, zoom);
        }

        pub fn getZoom(self: @This()) u8 {
            return c.lv_sdl_window_get_zoom(self.display.inner);
        }

        pub fn setTitle(self: @This(), title: [:0]const u8) void {
            c.lv_sdl_window_set_title(self.display.inner, title);
        }

        pub fn getRenderer(self: @This()) *anyopaque {
            return c.lv_sdl_window_get_renderer(self.display.inner).?;
        }
    };

    pub const mouse = struct {
        pub fn create() Indev {
            return .{ .inner = c.lv_sdl_mouse_create().? };
        }
    };

    pub const mousewheel = struct {
        pub fn create() Indev {
            return .{ .inner = c.lv_sdl_mousewheel_create().? };
        }
    };

    pub const keyboard = struct {
        pub fn create() Indev {
            return .{ .inner = c.lv_sdl_keyboard_create().? };
        }
    };

    pub fn quit() void {
        c.lv_sdl_quit();
    }
};

fn print_cb(log_level: c.lv_log_level_t, msg_: [*c]const u8) callconv(.C) void {
    const msg_span = std.mem.span(msg_);
    const msg = std.mem.trimRight(u8, msg_span, "\r\n");

    const logger = std.log.scoped(.lvgl);

    switch (log_level) {
        c.LV_LOG_LEVEL_INFO,
        c.LV_LOG_LEVEL_USER,
        => logger.info("{s}", .{msg}),
        c.LV_LOG_LEVEL_WARN => logger.warn("{s}", .{msg}),
        c.LV_LOG_LEVEL_ERROR => logger.err("{s}", .{msg}),
        c.LV_LOG_LEVEL_TRACE,
        c.LV_LOG_LEVEL_NONE,
        => logger.debug("{s}", .{msg}),
        else => logger.debug("{s}", .{msg}),
    }
}

pub fn init() void {
    c.lv_log_register_print_cb(print_cb);
    c.lv_init();
}

pub fn isInitialized() bool {
    return c.lv_is_initialized();
}

pub fn deinit() void {
    // c.lv_deinit();
}

pub fn pct(value: i32) i32 {
    return c.lv_pct(value);
}

pub const tick = struct {
    pub fn inc(period: u32) void {
        c.lv_tick_inc(period);
    }
};

pub const Size = struct {
    pub const Content = c.LV_SIZE_CONTENT;
};

export fn zig_lvgl_assert() void {
    @panic("lvgl assert");
}
