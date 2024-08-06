const lv = @import("lv.zig");
const c = lv.c;

pub const Arc = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Arc);

pub const Mode = enum(u8) {
    Normal = c.LV_ARC_MODE_NORMAL,
    Symmetrical = c.LV_ARC_MODE_SYMMETRICAL,
    Reverse = c.LV_ARC_MODE_REVERSE,
    _,
};

pub const DrawPart = enum(u8) {
    Background = c.LV_ARC_DRAW_PART_BACKGROUND,
    Foreground = c.LV_ARC_DRAW_PART_FOREGROUND,
    Knob = c.LV_ARC_DRAW_PART_KNOB,
};

pub fn create(parent: anytype) Arc {
    return Arc{ .obj = c.lv_arc_create(parent.obj).? };
}

pub fn setStartAnble(self: Arc, start: u16) void {
    c.lv_arc_set_start_angle(self.obj, start);
}

pub fn setEndAngle(self: Arc, end: u16) void {
    c.lv_arc_set_end_angle(self.obj, end);
}

pub fn setAngles(self: Arc, start: u16, end: u16) void {
    c.lv_arc_set_angles(self.obj, start, end);
}

pub fn setBgStartAnble(self: Arc, start: u16) void {
    c.lv_arc_set_bg_start_angle(self.obj, start);
}

pub fn setBgEndAngle(self: Arc, end: u16) void {
    c.lv_arc_set_bg_end_angle(self.obj, end);
}

pub fn setBgAngles(self: Arc, start: u16, end: u16) void {
    c.lv_arc_set_bg_angles(self.obj, start, end);
}

pub fn setRotation(self: Arc, rotation: u16) void {
    c.lv_arc_set_rotation(self.obj, rotation);
}

pub fn setMode(self: Arc, mode: Mode) void {
    c.lv_arc_set_mode(self.obj, @intFromEnum(mode));
}

pub fn setValue(self: Arc, value: i16) void {
    c.lv_arc_set_value(self.obj, value);
}

pub fn setRange(self: Arc, min: i16, max: i16) void {
    c.lv_arc_set_range(self.obj, min, max);
}

pub fn setChangeRate(self: Arc, rate: u16) void {
    c.lv_arc_set_change_rate(self.obj, rate);
}

pub fn getAngleStart(self: Arc) u16 {
    return c.lv_arc_get_angle_start(self.obj);
}

pub fn getAngleEnd(self: Arc) u16 {
    return c.lv_arc_get_angle_end(self.obj);
}

pub fn getBgAngleStart(self: Arc) u16 {
    return c.lv_arc_get_bg_angle_start(self.obj);
}

pub fn getBgAngleEnd(self: Arc) u16 {
    return c.lv_arc_get_bg_angle_end(self.obj);
}

pub fn getValue(self: Arc) i16 {
    return c.lv_arc_get_value(self.obj);
}

pub fn getMinValue(self: Arc) i16 {
    return c.lv_arc_get_min_value(self.obj);
}

pub fn getMaxValue(self: Arc) i16 {
    return c.lv_arc_get_max_value(self.obj);
}

pub fn getMode(self: Arc) Mode {
    return @enumFromInt(c.lv_arc_get_mode(self.obj));
}
