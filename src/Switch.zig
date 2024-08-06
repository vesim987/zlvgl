const std = @import("std");
const lv = @import("lv.zig");
const c = lv.c;

comptime {
    std.debug.assert(lv.config.lvgl.widgets.@"switch");
}

pub const Switch = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Switch);

pub fn create(parent: anytype) Switch {
    return .{
        .obj = c.lv_switch_create(parent.obj).?,
    };
}
