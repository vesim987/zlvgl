const std = @import("std");

const Driver = enum { Gtk, FbDev, Sdl };

const Config = struct {
    driver: Driver = .Gtk,
    width: u32 = 800,
    height: u32 = 480,
};

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("example", "src/examples/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    try addDependencies(b, exe, .{});

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

pub fn addDependencies(b: *std.build.Builder, exe: *std.build.LibExeObjStep, config: Config) !void {
    const base = comptime std.fs.path.dirname(@src().file).?;
    exe.linkLibC();

    exe.addIncludeDir(comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "./lvgl" }));
    exe.addIncludeDir(base ++ "/configs");
    exe.addIncludeDir(base ++ "/libs");

    exe.addPackage(.{
        .name = "zlvgl",
        .path = .{ .path = comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "./src/lv.zig" }) },
    });

    switch (config.driver) {
        .Gtk => exe.linkSystemLibrary("gtk+-3.0"),
        .Sdl => exe.linkSystemLibrary("sdl2"),
        else => {},
    }

    _ = b;
    const driver_file: struct {
        file: []const u8,
        define: []const u8,
    } = switch (config.driver) {
        .Gtk => .{ .file = comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lv_drivers/gtkdrv/gtkdrv.c" }), .define = "-DUSE_GTK=1" },
        .FbDev => .{ .file = comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lv_drivers/display/fbdev.c" }), .define = "-DUSE_FBDEV=1" },
        .Sdl => .{ .file = comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lv_drivers/display/monitor.c" }), .define = "-DUSE_MONITOR=1" },
    };

    const cflags = [_][]const u8{
        // TODO:
        "-DLV_HOR_RES=800",
        "-DLV_VER_RES=480",

        "-DLV_CONF_INCLUDE_SIMPLE=1",
        "-fno-sanitize=all",
        driver_file.define,
    };

    exe.addCSourceFile(driver_file.file, &cflags);
    exe.addCSourceFile(comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lv_drivers/indev/evdev.c" }), &cflags);

    const lvgl_source_files = [_][]const u8{
        // core
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_group.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_indev.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_indev_scroll.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_disp.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_theme.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_refr.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_class.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_pos.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_tree.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_draw.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_style.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_style_gen.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_obj_scroll.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/core/lv_event.c" }),
        //hal
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/hal/lv_hal_indev.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/hal/lv_hal_tick.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/hal/lv_hal_disp.c" }),
        //draw
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_label.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_arc.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_rect.c" }),
        //comptime std.fmt.comptimePrint("{s}/{s}", .{ base,libs/ "lvgl/src/draw/lv_draw_blend.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_mask.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_line.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_draw_img.c" }),

        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_blend.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_arc.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_rect.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_letter.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_img.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_line.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_polygon.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/sw/lv_draw_sw_gradient.c" }),

        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_img_buf.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_img_decoder.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/draw/lv_img_cache.c" }),

        //misc
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_gc.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_utils.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_fs.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_color.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_async.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_area.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_anim.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_txt.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_tlsf.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_timer.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_style.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_ll.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_log.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_printf.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_mem.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_math.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/misc/lv_style_gen.c" }),
        // widgets
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_arc.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_btn.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_btnmatrix.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_bar.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_dropdown.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_textarea.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_checkbox.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_switch.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_roller.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_slider.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_table.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_img.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_label.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/widgets/lv_line.c" }),
        // extra
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/lv_extra.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/tabview/lv_tabview.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/win/lv_win.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/msgbox/lv_msgbox.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/chart/lv_chart.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/spinner/lv_spinner.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/calendar/lv_calendar.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/calendar/lv_calendar_header_arrow.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/calendar/lv_calendar_header_dropdown.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/meter/lv_meter.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/keyboard/lv_keyboard.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/list/lv_list.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/widgets/menu/lv_menu.c" }),
        //"lvgl/src/extra/widgets/spinbox/lv_spinbox.c"}),
        //"lvgl/src/extra/widgets/tileview/lv_tileview.c"}),
        //"lvgl/src/extra/widgets/colorwheel/lv_colorwheel.c"}),
        //"lvgl/src/extra/widgets/led/lv_led.c"}),
        //"lvgl/src/extra/layouts/grid/lv_grid.c"}),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/layouts/flex/lv_flex.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/extra/themes/default/lv_theme_default.c" }),
        // font
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/font/lv_font.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/font/lv_font_fmt_txt.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/src/font/lv_font_montserrat_14.c" }),
        comptime std.fmt.comptimePrint("{s}/{s}", .{ base, "libs/lvgl/examples/widgets/menu/lv_example_menu_5.c" }),
    };
    exe.addCSourceFiles(&lvgl_source_files, &cflags);
}
