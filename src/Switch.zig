const lv = @import("lv.zig");
const c = lv.c;

pub const Switch = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Switch);

pub fn init(parent: anytype) Switch {
    return .{
        .obj = c.lv_switch_create(parent.obj).?,
    };
}
