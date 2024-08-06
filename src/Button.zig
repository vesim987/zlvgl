const std = @import("std");
const lv = @import("lv.zig");
const c = lv.c;

comptime {
    std.debug.assert(lv.config.lvgl.widgets.button);
}

pub const Button = @This();
obj: *c.lv_obj_t,

pub usingnamespace lv.Obj.Functions(Button);

pub fn create(parent: anytype) Button {
    return .{ .obj = c.lv_btn_create(parent.obj).? };
}

test Button {
    const btn1 = lv.Button.create(lv.Screen.active());
    btn1.addEventCallback(struct {
        pub fn onClicked(target: lv.Button) void {
            _ = target;
            std.log.info("Clicked", .{});
        }
    });
    btn1.toObj().setAlign(.Center, 0, -40);
    const label = lv.Label.create(btn1);
    label.setText("Button");
    label.toObj().center();

    const btn2 = lv.Button.create(lv.Screen.active());
    btn2.addEventCallback(struct {
        pub fn onValueChanged(target: lv.Button) void {
            _ = target;
            std.log.info("Toggled", .{});
        }
    });
    btn2.toObj().addFlag(.Checkable);
    btn2.toObj().setAlign(.Center, 0, 40);
    const label2 = lv.Label.create(btn2);
    label2.setText("Toggle");
    label2.toObj().center();
}
