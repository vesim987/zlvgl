const std = @import("std");
const lv = @import("zlvgl");

pub fn main() !void {
    lv.init();
    defer lv.deinit();

    lv.drivers.init();
    defer lv.drivers.deinit();
    lv.drivers.register();

    @import("./arc.zig").example_2();

    var lastTick: i64 = std.time.milliTimestamp();
    while (true) {
        lv.tick.inc(@intCast(u32, std.time.milliTimestamp() - lastTick));
        lastTick = std.time.milliTimestamp();
        lv.task.handler();
    }
}
