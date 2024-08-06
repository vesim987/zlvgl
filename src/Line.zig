const lv = @import("lv.zig");
const c = lv.c;

pub const Line = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Line);

pub fn create(parent: anytype) Line {
    return .{ .obj = c.lv_line_create(parent.obj).? };
}

pub fn setPoints(self: Line, points: []lv.Point) void {
    c.lv_line_set_points(self.obj, points.ptr, @as(u16, @intCast(points.len)));
}

pub fn setYInvert(self: Line, en: bool) void {
    c.lv_line_set_y_invert(self.obj, en);
}

pub fn getYInvert(self: Line) bool {
    return c.lv_line_get_y_invert(self.obj);
}
