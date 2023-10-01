const lv = @import("lv.zig");
const c = lv.c;

pub const Slider = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Slider);

pub fn init(parent: anytype) Slider {
    return .{
        .obj = c.lv_slider_create(parent.obj).?,
    };
}

pub fn setValue(self: Slider, value: i16, anim: lv.AnimEnable) void {
    c.lv_slider_set_value(self.obj, value, @intFromEnum(anim));
}

pub fn setLeftValue(self: Slider, left_value: i16, anim: lv.AnimEnable) void {
    c.lv_slider_set_left_value(self.obj, left_value, @intFromEnum(anim));
}

pub fn setRange(self: Slider, min: i16, max: i16) void {
    c.lv_slider_set_range(self.obj, min, max);
}

pub fn getValue(self: Slider) i32 {
    return c.lv_slider_get_value(self.obj);
}

pub fn getLeftValue(self: Slider) i32 {
    return c.lv_slider_get_left_value(self.obj);
}

pub fn getMinValue(self: Slider) i32 {
    return c.lv_slider_get_min_value(self.obj);
}

pub fn getMaxValue(self: Slider) i32 {
    return c.lv_slider_get_max_value(self.obj);
}

pub fn isDragged(self: Slider) bool {
    return c.lv_slider_is_dragged(self.obj);
}
