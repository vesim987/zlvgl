const lv = @import("lv.zig");
const c = lv.c;

const Flex = @This();
obj: *c.lv_obj_t,

pub const Align = enum(u8) {
    Start = c.LV_FLEX_ALIGN_START,
    Eend = c.LV_FLEX_ALIGN_END,
    Center = c.LV_FLEX_ALIGN_CENTER,
    SpaceEvenly = c.LV_FLEX_ALIGN_SPACE_EVENLY,
    SpaceAround = c.LV_FLEX_ALIGN_SPACE_AROUND,
    SpaceBetween = c.LV_FLEX_ALIGN_SPACE_BETWEEN,
    _,
};

pub const Flow = enum(u8) {
    Row = c.LV_FLEX_FLOW_ROW,
    Column = c.LV_FLEX_FLOW_COLUMN,
    RowWrap = c.LV_FLEX_FLOW_ROW_WRAP,
    RowReverse = c.LV_FLEX_FLOW_ROW_REVERSE,
    RowWrapReverse = c.LV_FLEX_FLOW_ROW_WRAP_REVERSE,
    ColumnWrap = c.LV_FLEX_FLOW_COLUMN_WRAP,
    ColumnReverse = c.LV_FLEX_FLOW_COLUMN_REVERSE,
    ColumnWrapReverse = c.LV_FLEX_FLOW_COLUMN_WRAP_REVERSE,
    _,
};

pub fn init() void {
    c.lv_flex_init();
}

pub fn setFlow(self: Flex, flow: Flow) void {
    c.lv_obj_set_flex_flow(self.obj, @enumToInt(flow));
}

pub fn setAlign(self: Flex, main_place: Align, cross_place: Align, track_place: Align) void {
    c.lv_obj_set_flex_align(self.obj, @enumToInt(main_place), @enumToInt(cross_place), @enumToInt(track_place));
}

pub fn setGrow(self: Flex, grow: u8) void {
    c.lv_obj_set_flex_grow(self.obj, grow);
}
