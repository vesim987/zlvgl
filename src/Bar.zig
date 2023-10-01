const lv = @import("lv.zig");
const c = lv.c;

pub const Bar = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Bar);

pub const Mode = enum(u8) {
    Normal = c.LV_BAR_MODE_NORMAL,
    Symmetrical = c.LV_BAR_MODE_SYMMETRICAL,
    Range = c.LV_BAR_MODE_RANGE,
    _,
};

pub fn init(parent: anytype) Bar {
    return Bar{ .obj = c.lv_bar_create(parent.obj).? };
}

pub fn setValue(self: Bar, value: i32, anim: lv.AnimEnable) void {
    c.lv_bar_set_value(self.obj, value, @intFromEnum(anim));
}

pub fn setStartValue(self: Bar, value: i32, anim: lv.AnimEnable) void {
    c.lv_bar_set_start_value(self.obj, value, @intFromEnum(anim));
}

pub fn setRange(self: Bar, min: i32, max: i32) void {
    c.lv_bar_set_range(self.obj, min, max);
}

pub fn setMode(self: Bar, mode: Mode) void {
    c.lv_bar_set_mode(self.obj, @intFromEnum(mode));
}

pub fn getValue(self: Bar) i32 {
    return c.lv_bar_get_value(self.obj);
}

pub fn getStartValue(self: Bar) i32 {
    return c.lv_bar_get_start_value(self.obj);
}

pub fn getMinValue(self: Bar) i32 {
    return c.lv_bar_get_min_value(self.obj);
}

pub fn getMaxValue(self: Bar) i32 {
    return c.lv_bar_get_max_value(self.obj);
}

pub fn getMode(self: Bar) Mode {
    return @enumFromInt(c.lv_bar_get_mode(self.obj));
}
