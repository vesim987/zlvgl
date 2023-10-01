const lv = @import("lv.zig");
const c = lv.c;

pub const List = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(List);

pub fn init(parent: anytype) List {
    return .{
        .obj = c.lv_list_create(parent.obj).?,
    };
}

pub fn addButton(self: List, text: []const u8) !lv.Button {
    // TODO: error handling
    return lv.Button{
        .obj = c.lv_list_add_btn(self.obj, c.LV_SYMBOL_FILE, text.ptr).?,
    };
}

pub fn getButtonText(self: List, button: lv.Button) [*c]const u8 {
    return c.lv_list_get_btn_text(self.obj, button.obj);
}
