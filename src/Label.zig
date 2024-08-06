const lv = @import("lv.zig");
const c = lv.c;

pub const Label = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Label);

pub const LongMode = enum(u8) {
    Wrap = c.LV_LABEL_LONG_WRAP,
    Dot = c.LV_LABEL_LONG_DOT,
    Scroll = c.LV_LABEL_LONG_SCROLL,
    ScrollCircular = c.LV_LABEL_LONG_SCROLL_CIRCULAR,
    Clip = c.LV_LABEL_LONG_CLIP,
    _,
};

pub fn create(parent: anytype) Label {
    return .{ .obj = c.lv_label_create(parent.obj).? };
}

pub fn setText(self: Label, text: [*:0]const u8) void {
    c.lv_label_set_text(self.obj, text);
}
// TODO: ??? lv_label_set_text_fmt
pub fn setTextStatic(self: Label, text: [*:0]const u8) void {
    c.lv_label_set_text_static(self.obj, text);
}

pub fn setLongMode(self: Label, mode: LongMode) void {
    c.lv_label_set_long_mode(self.obj, @intFromEnum(mode));
}

pub fn setRecolor(self: Label, en: bool) void {
    c.lv_label_set_recolor(self.obj, en);
}

pub fn setTextSelStart(self: Label, index: u32) void {
    c.lv_label_set_text_sel_start(self.obj, index);
}

pub fn setTextSelEnd(self: Label, index: u32) void {
    c.lv_label_set_text_sel_end(self.obj, index);
}

pub fn getText(self: Label) [*c]const u8 {
    return c.lv_label_get_text(self.obj);
}

pub fn getLongMode(self: Label) LongMode {
    return @as(LongMode, @enumFromInt(c.lv_label_get_long_mode(self.obj)));
}

pub fn getRecolor(self: Label) bool {
    return c.lv_label_get_recolor(self.obj);
}

pub fn getLetterPos(self: Label, char_id: u32, pos: *lv.Point) void {
    c.lv_label_get_letter_pos(self.obj, char_id, pos);
}

pub fn getLetterOn(self: Label, pos: *lv.Point) u32 {
    return c.lv_label_get_letter_on(self.obj, pos);
}

pub fn isCharUnderPos(self: Label, pos: *lv.Point) bool {
    return c.lv_label_is_char_under_pos(self.obj, pos);
}

pub fn getTextSelectionStart(self: Label) u32 {
    return c.lv_label_get_text_selection_start(self.obj);
}

pub fn getTextSelectionEnd(self: Label) u32 {
    return c.lv_label_get_text_selection_end(self.obj);
}

pub fn insText(self: Label, pos: u32, text: [*:0]const u8) void {
    c.lv_label_ins_text(self.obj, pos, text);
}

pub fn cutText(self: Label, pos: u32, cnt: u32) void {
    c.lv_label_cut_text(self.obj, pos, cnt);
}
