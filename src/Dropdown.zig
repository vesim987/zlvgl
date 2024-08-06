const std = @import("std");
const lv = @import("lv.zig");
const c = lv.c;

comptime {
    std.debug.assert(lv.config.lvgl.widgets.dropdown);
}

pub const Dropdown = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Dropdown);

pub fn create(parent: anytype) Dropdown {
    return Dropdown{ .obj = c.lv_dropdown_create(parent.obj).? };
}

pub fn setText(self: Dropdown, text: [:0]const u8) void {
    c.lv_dropdown_set_text(self.obj, text);
}

pub fn setOptions(self: Dropdown, text: [:0]const u8) void {
    c.lv_dropdown_set_options(self.obj, text);
}

pub fn setOptionsStatic(self: Dropdown, text: [:0]const u8) void {
    c.lv_dropdown_set_options_static(self.obj, text);
}

pub fn addOption(self: Dropdown, text: [:0]const u8, pos: u32) void {
    c.lv_dropdown_add_option(self.obj, text, pos);
}

pub fn clearOptions(self: Dropdown) void {
    c.lv_dropdown_clear_options(self.obj);
}

pub fn setSelected(self: Dropdown, sel_opt: u16) void {
    c.lv_dropdown_set_selected(self.obj, sel_opt);
}

pub fn setDir(self: Dropdown, dir: lv.Dir) void {
    c.lv_dropdown_set_dir(self.obj, @intFromEnum(dir));
}

pub fn setSymbol(self: Dropdown, symbol: [:0]const u8) void {
    c.lv_dropdown_set_symbol(self.obj, @ptrCast(symbol.ptr));
}

pub fn setSelectedHighlight(self: Dropdown, en: bool) void {
    c.lv_dropdown_set_selected_highlight(self.obj, en);
}

pub fn getList(self: Dropdown) lv.Obj {
    return lv.Obj.assign(c.lv_dropdown_get_list(self.obj).?);
}

pub fn getText(self: Dropdown) [*c]const u8 {
    return c.lv_dropdown_get_text(self.obj);
}

pub fn getOptions(self: Dropdown) [*c]const u8 {
    return c.lv_dropdown_get_options(self.obj);
}

pub fn getSelected(self: Dropdown) u16 {
    return c.lv_dropdown_get_selected(self.obj);
}

pub fn getOptionCnt(self: Dropdown) u16 {
    return c.lv_dropdown_get_option_cnt(self.obj);
}

pub fn getSelectedStr(self: Dropdown, buf: [:0]u8) void {
    c.lv_dropdown_get_selected_str(self.obj, buf.ptr, @intCast(buf.len));
}

pub fn getSymbol(self: Dropdown) [*c]const u8 {
    return c.lv_dropdown_get_symbol(self.obj);
}

pub fn getSelectedHighlight(self: Dropdown) bool {
    return c.lv_dropdown_get_selected_highlight(self.obj);
}

pub fn getDir(self: Dropdown) lv.Dir {
    return @enumFromInt(c.lv_dropdown_get_dir(self.obj));
}

pub fn open(self: Dropdown) void {
    c.lv_dropdown_open(self.obj);
}

pub fn clsoe(self: Dropdown) void {
    c.lv_dropdown_close(self.obj);
}

pub fn isOpen(self: Dropdown) bool {
    return c.lv_dropdown_is_open(self.obj);
}
