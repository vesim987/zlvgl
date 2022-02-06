const c = @import("lv.zig").c;

pub const Dir = enum(u8) {
    Top = c.LV_DIR_TOP,
    Bottom = c.LV_DIR_BOTTOM,
    Left = c.LV_DIR_LEFT,
    Right = c.LV_DIR_RIGHT,
    _,
};
