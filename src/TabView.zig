const lv = @import("lv.zig");
const c = lv.c;

pub const TabView = @This();
obj: *c.lv_obj_t,

usingnamespace lv.Obj.Functions(TabView);

pub fn init(parent: anytype, tab_pos: lv.Dir, tab_size: i16) TabView {
    return .{
        .obj = c.lv_tabview_create(parent.obj, @enumToInt(tab_pos), tab_size).?,
    };
}

pub fn addTab(self: TabView, name: [:0]const u8) lv.Obj {
    return lv.Obj{ .obj = c.lv_tabview_add_tab(self.obj, name).? };
}
