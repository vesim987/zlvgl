const std = @import("std");
const lv = @import("zlvgl");

pub fn example_1() void {
    const arc = lv.Arc.init(lv.Screen.active());
    arc.toObj().setSize(150, 150);
    arc.setRotation(136);
    arc.setBgAngles(0, 270);
    arc.setValue(40);
    arc.toObj().center();
}

pub fn example_2() void {
    const arc = lv.Arc.init(lv.Screen.active());
    arc.setRotation(270);
    arc.setBgAngles(0, 360);
    arc.toObj().removeStyle(null, .Knob);
    arc.toObj().clearFlag(.Clickable);
    arc.toObj().center();

    var anim: lv.Anim = undefined;
    anim.init();
    anim.setVar(@as(*anyopaque, @ptrCast(arc.obj)));
    anim.setExecCb((struct {
        fn f(obj: lv.Obj, value: i32) void {
            (lv.Arc{ .obj = obj.obj }).setValue(@as(i16, @intCast(value)));
        }
    }).f);
    anim.setTime(1000);
    anim.setRepeatCount(0xffff);
    anim.setRepeatDelay(500);
    anim.setValues(0, 100);
    _ = anim.start();
}
