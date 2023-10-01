const lv = @import("lv.zig");
const c = lv.c;

pub const Button = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Button);

pub fn init(parent: anytype) Button {
    return .{ .obj = c.lv_btn_create(parent.obj).? };
}
