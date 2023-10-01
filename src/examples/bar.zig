const std = @import("std");
const lv = @import("zlvgl");

pub fn example_1() void {
    const bar = lv.Bar.init(lv.Screen.active());
    bar.toObj().setSize(200, 20);
    bar.toObj().center();
    bar.setValue(70, .Off);
}

// example_2 and 4 are mostly about styles

pub fn example_3() void {
    // TODO: lv_style stuff
    const bar = lv.Bar.init(lv.Screen.active());
    bar.toObj().setSize(20, 200);
    bar.toObj().center();
    bar.setRange(-20, 40);

    var anim: lv.Anim = undefined;
    anim.init();
    anim.setExecCb(struct {
        fn f(obj: lv.Obj, value: i32) void {
            (lv.Bar{ .obj = obj.obj }).setValue(value, .On);
        }
    }.f);
    anim.setTime(3000);
    anim.setPlaybackTime(3000);
    anim.setVar(@as(*anyopaque, @ptrCast(bar.obj)));
    anim.setValues(-20, 40);
    anim.setRepeatCount(0xffff);
    _ = anim.start();
}

pub fn example_5() void {
    // TODO: lv_style stuff
    const bar_ltr = lv.Bar.init(lv.Screen.active());
    bar_ltr.toObj().setSize(200, 20);
    bar_ltr.toObj().setAlign(.Center, 0, -30);
    bar_ltr.setValue(70, .Off);

    const label_ltr = lv.Label.init(lv.Screen.active());
    label_ltr.setText("Left to Right base direction");
    label_ltr.toObj().setAlignTo(bar_ltr, .OutTopMid, 0, -5);

    const bar_rtl = lv.Bar.init(lv.Screen.active());
    bar_rtl.toObj().setStyleBaseDir(.Rtl, .Main);
    bar_rtl.toObj().setSize(200, 20);
    bar_rtl.toObj().setAlign(.Center, 0, 30);
    bar_rtl.setValue(70, .Off);

    const label_rtl = lv.Label.init(lv.Screen.active());
    label_rtl.setText("Right to Left base direction");
    label_rtl.toObj().setAlignTo(bar_rtl, .OutTopMid, 0, -5);
}

// TODO:example_6
