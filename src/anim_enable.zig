const c = @import("lv.zig").c;

pub const AnimEnable = enum(u8) {
    On = c.LV_ANIM_ON,
    Off = c.LV_ANIM_OFF,
    _,
};
