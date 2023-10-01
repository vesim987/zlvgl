const lv = @import("lv.zig");
const c = lv.c;

pub const Anim = @This();
internal: c.lv_anim_t,

pub fn init(self: *Anim) void {
    c.lv_anim_init(&self.internal);
}

pub fn setVar(self: *Anim, var_: *anyopaque) void {
    c.lv_anim_set_var(&self.internal, var_);
}

pub fn setExecCb(self: *Anim, comptime exec_cb: anytype) void {
    c.lv_anim_set_exec_cb(&self.internal, (struct {
        fn f(obj: ?*anyopaque, v: i32) callconv(.C) void {
            exec_cb(lv.Obj{ .obj = @as(*c.lv_obj_t, @ptrCast(obj.?)) }, v);
        }
    }).f);
}

pub fn setPlaybackTime(self: *Anim, time: u32) void {
    c.lv_anim_set_playback_time(&self.internal, time);
}

pub fn setTime(self: *Anim, duration: u32) void {
    c.lv_anim_set_time(&self.internal, duration);
}

pub fn setRepeatCount(self: *Anim, cnt: u16) void {
    c.lv_anim_set_repeat_count(&self.internal, cnt);
}

pub fn setRepeatDelay(self: *Anim, delay: u16) void {
    c.lv_anim_set_repeat_delay(&self.internal, delay);
}

pub fn setValues(self: *Anim, start_: i32, end: i32) void {
    c.lv_anim_set_values(&self.internal, start_, end);
}

pub fn start(self: *Anim) *c.lv_anim_t {
    return c.lv_anim_start(&self.internal);
}
