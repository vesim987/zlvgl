const std = @import("std");
const lv = @import("../../src/lv.zig");

pub fn example_1() void {
    const btn1 = lv.Button.init(lv.Screen.active());
    btn1.addEventCallback(struct {
        pub fn onClicked(target: lv.Button) void {
            _ = target;
            std.debug.print("Clicked\n", .{});
        }
    });
    btn1.toObj().setAlign(.Center, 0, -40);
    const label = lv.Label.init(btn1);
    label.setText("Button");
    label.toObj().center();

    const btn2 = lv.Button.init(lv.Screen.active());
    btn2.addEventCallback(struct {
        pub fn onValueChanged(target: lv.Button) void {
            _ = target;
            std.debug.print("Toggled\n", .{});
        }
    });
    btn2.toObj().addFlag(.Checkable);
    btn2.toObj().setAlign(.Center, 0, 40);
    const label2 = lv.Label.init(btn2);
    label2.setText("Toggle");
    label2.toObj().center();
}

// TODO:example_2 and  3 with styles
