const std = @import("std");
const lv = @import("lv.zig");
const c = lv.c;

comptime {
    std.debug.assert(lv.config.lvgl.widgets.table);
}

pub const Table = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Table);

pub const CellCtrl = enum(u8) {
    MergeRight = c.LV_TABLE_CELL_CTRL_MERGE_RIGHT,
    TextCrop = c.LV_TABLE_CELL_CTRL_TEXT_CROP,
    Custom1 = c.LV_TABLE_CELL_CTRL_CUSTOM_1,
    Custom2 = c.LV_TABLE_CELL_CTRL_CUSTOM_2,
    Custom3 = c.LV_TABLE_CELL_CTRL_CUSTOM_3,
    Custom4 = c.LV_TABLE_CELL_CTRL_CUSTOM_4,
    _,
};

pub fn create(parent: anytype) Table {
    return .{ .obj = c.lv_table_create(parent.obj).? };
}

pub fn setCellValue(self: Table, row: u16, col: u16, text: [:0]const u8) void {
    c.lv_table_set_cell_value(self.obj, row, col, text);
}
// TODO ??? lv_table_set_cell_value_fmt:

pub fn setRowCnt(self: Table, row_cnt: u16) void {
    c.lv_table_set_row_cnt(self.obj, row_cnt);
}

pub fn setColCnt(self: Table, col_cnt: u16) void {
    c.lv_table_set_col_cnt(self.obj, col_cnt);
}

pub fn setColWidth(self: Table, col_id: u16, w: lv.Coord) void {
    c.lv_table_set_col_width(self.obj, col_id, w);
}

pub fn addCellCtrl(self: Table, row: u16, col: u16, ctrl: CellCtrl) void {
    c.lv_table_add_cell_ctrl(self.obj, row, col, @intFromEnum(ctrl));
}

pub fn getCellValue(self: Table, row: u16, col: u16) [*c]const u8 {
    return c.lv_table_get_cell_value(self.obj, row, col);
}

pub fn getRowCnt(self: Table) u16 {
    return c.lv_table_get_row_cnt(self.obj);
}

pub fn getColCnt(self: Table) u16 {
    return c.lv_table_get_col_cnt(self.obj);
}

pub fn getColWidth(self: Table, col: u16) lv.Coord {
    return c.lv_table_get_col_width(self.obj, col);
}

pub fn hasCellCtrl(self: Table, row: u16, col: u16, ctrl: CellCtrl) bool {
    return c.lv_table_has_cell_ctrl(self.obj, row, col, @intFromEnum(ctrl));
}

pub fn getSelectedCell(self: Table, row: *u16, col: *u16) void {
    return c.lv_table_get_selected_cell(self.obj, row, col);
}
