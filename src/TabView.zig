const std = @import("std");
const lv = @import("lv.zig");
const c = lv.c;

comptime {
    std.debug.assert(lv.config.lvgl.widgets.extra.tabview);
}

pub const TabView = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(TabView);

pub fn create(parent: anytype) TabView {
    return .{
        .obj = c.lv_tabview_create(parent.obj).?,
    };
}

pub fn addTab(self: TabView, name: [:0]const u8) lv.Obj {
    return lv.Obj{ .obj = c.lv_tabview_add_tab(self.obj, name).? };
}

pub fn renameTab(self: TabView, idx: u32, name: [:0]const u8) void {
    c.lv_tabview_rename_tab(self.obj, idx, name);
}

pub fn setActive(self: TabView, idx: u32, anim: bool) void {
    c.lv_tabview_set_active(self.obj, idx, @intFromBool(anim));
}

pub fn setTabBarPosition(self: TabView, pos: lv.Dir) void {
    c.lv_tabview_set_tab_bar_position(self.obj, @intFromEnum(pos));
}

pub fn setTabBarSize(self: TabView, size: i32) void {
    c.lv_tabview_set_tab_bar_size(self.obj, size);
}

pub fn getTabCount(self: TabView) u32 {
    return c.lv_tabview_get_tab_count(self.obj);
}

pub fn getTabActive(self: TabView) u32 {
    return c.lv_tabview_get_tab_active(self.obj);
}

pub fn getContent(self: TabView) lv.Obj {
    return .{ .obj = c.lv_tabview_get_content(self.obj).? };
}

pub fn getTabBar(self: TabView) lv.Obj {
    return .{ .obj = c.lv_tabview_get_tab_bar(self.obj).? };
}
