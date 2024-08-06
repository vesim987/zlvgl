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

test {
    _ = Button;
    _ = Label;
}

comptime {
    // std.testing.refAllDeclsRecursive(@This());

    // inline for (std.meta.declarations(@This())) |decl| {
    //     if (std.mem.eql(u8, decl.name, "c"))
    //         continue;
    //     if (std.mem.eql(u8, decl.name, "Coord"))
    //         continue;
    //     if(@TypeOf(@field(@This(), )))

    //     inline for (std.meta.declarations(@field(@This(), decl.name))) |d| {
    //         _ = d;
    //     }
    // }
}
