const lv = @import("lv.zig");
const c = lv.c;

pub const Checkbox = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Checkbox);

pub fn init(parent: anytype) Checkbox {
    return Checkbox{ .obj = c.lv_checkbox_create(parent.obj).? };
}

pub fn setText(self: Checkbox, text: [:0]const u8) void {
    c.lv_checkbox_set_text(self.obj, text);
}

pub fn setTextStatic(self: Checkbox, text: [:0]const u8) void {
    c.lv_checkbox_set_text_static(self.obj, text);
}

pub fn getText(self: Checkbox) [*c]const u8 {
    return c.lv_checkbox_get_text(self.obj);
}
