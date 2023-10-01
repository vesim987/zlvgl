const std = @import("std");

const Driver = enum { Gtk, FbDev, Sdl };

// TODO: add more "GPUs"
const Gpu = enum { Auto, Software, Sdl };

pub const Config = struct {
    driver: Driver = .Sdl,
    width: u32 = 800,
    height: u32 = 480,
    gpu: Gpu = .Auto,

    lvgl: struct {
        color: struct {
            depth: enum(i64) {
                @"1bpp" = 1,
                RGB332 = 8,
                RGB565 = 16,
                ARGB8888 = 32,
            } = .ARGB8888,
            /// Swap the 2 bytes of RGB565 color. Useful if the display has a 8 bit interface (e.g. SPI)
            swap_rgb565: bool = false,
            /// Enable more complex drawing routines to manage screens transparency.
            /// Can be used if the UI is above another layer, e.g. an OSD menu or video player.
            /// Requires `LV_COLOR_DEPTH = 32` colors and the screen's `bg_opa` should be set to non LV_OPA_COVER value
            transparent_screen: bool = false,
            // / Images pixels with this color will not be drawn if they are  chroma keyed)
            // / .LV_COLOR_CHROMA_KEY = .@"lv_color_hex(0x00ff00)", // TODO: lv_color_hex
        } = .{},
        memory: struct {
            allocator: union(enum) {
                memory_pool: struct {
                    //Size of the memory available for `lv_mem_alloc()` in bytes (>= 2kB)*/
                    mem_size: i64 = (1024 * 1024 * 1024),
                    //Set an address for the memory pool instead of allocating it as a normal array. Can be in external SRAM too.*/
                    address: i64 = 0,
                },
                custom: void, // TODO
            } = .{ .memory_pool = .{} },
            /// Use the standard `memcpy` and `memset` instead of LVGL's own functions. (Might or might not be faster).
            memcpy_memset_from_stdlib: bool = false,
        } = .{},
        hal: struct {
            /// Default display refresh period. LVG will redraw changed ares with this period time
            display_refresh_period: i64 = 16,
            /// Input device read period in milliseconds
            indev_refresh_period: i64 = 16,
            /// Use a custom tick source that tells the elapsed time in milliseconds.
            /// It removes the need to manually update the tick with `lv_tick_inc()`)*/
            tick: union(enum) {
                explicit: void,
                custom: void, // TODO
            } = .explicit,
            /// Default Dot Per Inch. Used to initialize default sizes such as widgets sized, style paddings.
            /// (Not so important, you can adjust it to modify default sizes and spaces)
            dpi: i64 = 130,
        } = .{},
        log: ?struct {
            level: enum {
                /// A lot of logs to give detailed information
                Trace,
                /// Log important events
                Info,
                /// Log if something unwanted happened but didn't cause a problem
                Warn,
                /// Only critical issue, when the system may fail
                Error,
                /// Only logs added by the user
                User,
                /// Do not log anything
                None,
            } = .Warn,
            /// true: Print the log with 'printf';
            /// false : User need to register a callback with `lv_log_register_print_cb()`
            use_printf: bool = true,
            /// Enable/disable LV_LOG_TRACE in modules that produces a huge number of logs
            trace: struct {
                mem: bool = true,
                timer: bool = true,
                indev: bool = true,
                disp_refr: bool = true,
                event: bool = true,
                obj_create: bool = true,
                layout: bool = true,
                anim: bool = true,
            } = .{},
        } = null,
        assert: struct { // TODO
            null: bool = true,
            malloc: bool = true,
            style: bool = false,
            mem_integrity: bool = false,
            handler: ?struct {
                include: []const u8,
                handler: []const u8,
            } = null,
        } = .{},
    } = .{},
};

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const driver = b.option(Driver, "driver", "Driver") orelse .Sdl;
    const gpu = b.option(Gpu, "gpu", "gpu") orelse .Auto;
    const config_addr = b.option(usize, "config_addr", "only for direct use as dependency") orelse 0;
    const config: ?*Config = if (config_addr == 0) null else @as(*Config, @ptrFromInt(config_addr));

    const lv_drivers = b.dependency("lv_drivers", .{});
    const lvgl = b.dependency("lvgl", .{});

    const lib = b.addStaticLibrary(.{
        .name = "lvgl",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const module = b.addModule("zlvgl", .{
        .source_file = .{ .path = "src/lv.zig" },
    });

    try addDependencies(b, lib, .{
        .zlvgl = module,
        .lvgl = lvgl,
        .lv_drivers = lv_drivers,
    }, if (config) |c| c else &Config{
        .driver = driver,
        .gpu = gpu,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "src/examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    exe.addModule("zlvgl", module);
    exe.linkLibrary(lib);
    try exe.include_dirs.appendSlice(lib.include_dirs.items);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

pub fn addDependencies(b: *std.build.Builder, lib: *std.build.LibExeObjStep, modules: struct {
    zlvgl: *std.Build.Module,
    lvgl: *std.Build.Dependency,
    lv_drivers: *std.Build.Dependency,
}, config: *const Config) !void {
    const lvgl = modules.lvgl;
    const lv_drivers = modules.lv_drivers;

    lib.linkLibC();

    lib.addIncludePath(.{ .path = b.pathFromRoot("configs") });
    lib.addIncludePath(lvgl.path(""));
    lib.addIncludePath(lv_drivers.path(""));

    const options = b.addOptions();
    lib.step.dependOn(&options.step);

    try modules.zlvgl.dependencies.put("config", options.createModule());
    options.addOption(Driver, "driver", config.driver);

    const config_header = b.addConfigHeader(.{
        .include_path = "lv_conf_zig.h",
    }, .{
        .LV_COLOR_DEPTH = @as(i64, @intFromEnum(config.lvgl.color.depth)),
        .LV_COLOR_16_SWAP = config.lvgl.color.swap_rgb565,
        .LV_COLOR_SCREEN_TRANSP = config.lvgl.color.transparent_screen,
        // Images pixels with this color will not be drawn if they are  chroma keyed)
        .LV_COLOR_CHROMA_KEY = .@"lv_color_hex(0x00ff00)", // TODO: lv_color_hex

        .LV_DISP_DEF_REFR_PERIOD = config.lvgl.hal.display_refresh_period, // ms
        .LV_INDEV_DEF_READ_PERIOD = config.lvgl.hal.indev_refresh_period, //ms
        .LV_DPI_DEF = config.lvgl.hal.dpi,
    });

    switch (config.lvgl.memory.allocator) {
        .memory_pool => {
            config_header.addValues(.{
                .LV_MEM_CUSTOM = 0,
                .LV_MEM_SIZE = (1024 * 1024 * 1024),
                .LV_MEM_ADR = 0,
                .LV_MEMCPY_MEMSET_STD = 0,
            });
        },
        .custom => unreachable,
    }

    switch (config.lvgl.hal.tick) {
        .explicit => {
            config_header.addValues(.{
                .LV_TICK_CUSTOM = 0,
            });
        },
        .custom => unreachable,
    }

    if (config.lvgl.log) |log| {
        config_header.addValues(.{
            .LV_USE_LOG = 1,
        });

        switch (log.level) {
            .Trace => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_TRACE,
                });
            },
            .Info => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_INFO,
                });
            },
            .Warn => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_WARN,
                });
            },
            .Error => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_ERROR,
                });
            },
            .User => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_USER,
                });
            },
            .None => {
                config_header.addValues(.{
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_NONe,
                });
            },
        }
        config_header.addValues(.{
            .LV_LOG_TRACE_MEM = log.trace.mem,
            .LV_LOG_TRACE_TIMER = log.trace.timer,
            .LV_LOG_TRACE_INDEV = log.trace.indev,
            .LV_LOG_TRACE_DISP_REFR = log.trace.disp_refr,
            .LV_LOG_TRACE_EVENT = log.trace.event,
            .LV_LOG_TRACE_OBJ_CREATE = log.trace.obj_create,
            .LV_LOG_TRACE_LAYOUT = log.trace.layout,
            .LV_LOG_TRACE_ANIM = log.trace.anim,
        });
    } else {
        config_header.addValues(.{
            .LV_USE_LOG = 0,
        });
    }

    lib.addConfigHeader(config_header);

    switch (config.driver) {
        .Gtk => lib.linkSystemLibrary("gtk+-3.0"),
        .Sdl => lib.linkSystemLibrary("sdl2"),
        else => {},
    }

    const gpu: Gpu = switch (config.gpu) {
        .Auto => if (config.driver == .Sdl) Gpu.Sdl else .Software,
        .Sdl => blk: {
            if (config.driver != .Sdl) {
                std.log.err("SDL GPU driver is only supported in SDL driver", .{});
                return error.InvalidGpu;
            }
            break :blk .Sdl;
        },
        else => |g| g,
    };
    options.addOption(Gpu, "gpu", gpu);

    const driver_define: []const u8 = switch (config.driver) {
        .Gtk => "-DUSE_GTK=1",
        .FbDev => "-DUSE_FBDEV=1",
        .Sdl => switch (gpu) {
            .Software => "-DUSE_SDL=1",
            .Sdl => "-DUSE_SDL_GPU=1",
            else => unreachable,
        },
    };
    const cflags = [_][]const u8{
        // TODO: rewrite drivers and get rid of hardcoded resolutions
        b.fmt("-DSDL_HOR_RES={}", .{config.width}),
        b.fmt("-DSDL_VER_RES={}", .{config.height}),
        b.fmt("-DLV_HOR_RES={}", .{config.width}),
        b.fmt("-DLV_VER_RES={}", .{config.height}),
        b.fmt("-DLV_HOR_RES_MAX={}", .{config.width}),
        b.fmt("-DLV_VER_RES_MAX={}", .{config.height}),

        "-DLV_LVGL_H_INCLUDE_SIMPLE=1",
        "-DLV_CONF_INCLUDE_SIMPLE=1",

        "-fno-sanitize=all",
        driver_define,
        "-DSDL_INCLUDE_PATH=SDL/SDL.h",
        "-DSDL_ZOOM=1",
        if (gpu == .Sdl) "-DLV_USE_GPU_SDL=1" else "",
        "-DLV_GPU_SDL_CUSTOM_BLEND_MODE=0", // TODO
        "-Wno-incompatible-function-pointer-types",
        "-DSDL_INCLUDE_PATH=<SDL2/SDL.h>",
    };

    switch (config.driver) {
        .Gtk => {
            lib.addCSourceFile(.{ .file = lv_drivers.path("gtkdrv/gtkdrv.c"), .flags = &cflags });
        },
        .FbDev => {
            lib.addCSourceFile(.{ .file = lv_drivers.path("display/fbdev.c"), .flags = &cflags });
        },
        .Sdl => {
            switch (gpu) {
                .Sdl => {
                    lib.addCSourceFile(.{ .file = lv_drivers.path("sdl/sdl_gpu.c"), .flags = &cflags });
                    lib.addCSourceFile(.{ .file = lv_drivers.path("sdl/sdl_common.c"), .flags = &cflags });
                },
                .Software => {
                    lib.addCSourceFile(.{ .file = lv_drivers.path("sdl/sdl.c"), .flags = &cflags });
                    lib.addCSourceFile(.{ .file = lv_drivers.path("sdl/sdl_common.c"), .flags = &cflags });
                },
                else => {
                    std.log.err("Invalid gpu for SDL driver", .{});
                    return error.InvalidGpu;
                },
            }
        },
    }

    lib.addCSourceFile(.{ .file = lv_drivers.path("indev/evdev.c"), .flags = &cflags });

    const lvgl_draw_sw_source_files = [_]std.Build.LazyPath{
        lvgl.path("src/draw/sw/lv_draw_sw.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_layer.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_transform.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_blend.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_arc.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_rect.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_letter.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_img.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_line.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_polygon.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_gradient.c"),
    };

    const lvgl_draw_sdl_source_files = [_]std.Build.LazyPath{
        lvgl.path("src/draw/sdl/lv_draw_sdl.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_bg.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_composite.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_utils.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_layer.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_mask.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_texture_cache.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_transform.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_blend.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_arc.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_rect.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_label.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_img.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_line.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_polygon.c"),
        lvgl.path("src/draw/sdl/lv_draw_sdl_stack_blur.c"),

        // sw components needed by SDL
        lvgl.path("src/draw/sw/lv_draw_sw_blend.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_gradient.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_letter.c"),
    };

    switch (gpu) {
        .Software => {
            for (lvgl_draw_sw_source_files) |f| {
                lib.addCSourceFile(.{ .file = f, .flags = &cflags });
            }
        },
        .Sdl => {
            for (lvgl_draw_sdl_source_files) |f| {
                lib.addCSourceFile(.{ .file = f, .flags = &cflags });
            }
        },
        .Auto => unreachable,
    }

    const lvgl_source_files = [_]std.Build.LazyPath{
        // core
        lvgl.path("src/core/lv_group.c"),
        lvgl.path("src/core/lv_indev.c"),
        lvgl.path("src/core/lv_indev_scroll.c"),
        lvgl.path("src/core/lv_disp.c"),
        lvgl.path("src/core/lv_theme.c"),
        lvgl.path("src/core/lv_refr.c"),
        lvgl.path("src/core/lv_obj.c"),
        lvgl.path("src/core/lv_obj_class.c"),
        lvgl.path("src/core/lv_obj_pos.c"),
        lvgl.path("src/core/lv_obj_tree.c"),
        lvgl.path("src/core/lv_obj_draw.c"),
        lvgl.path("src/core/lv_obj_style.c"),
        lvgl.path("src/core/lv_obj_style_gen.c"),
        lvgl.path("src/core/lv_obj_scroll.c"),
        lvgl.path("src/core/lv_event.c"),
        //hal
        lvgl.path("src/hal/lv_hal_indev.c"),
        lvgl.path("src/hal/lv_hal_tick.c"),
        lvgl.path("src/hal/lv_hal_disp.c"),
        //draw
        lvgl.path("src/draw/lv_draw.c"),
        lvgl.path("src/draw/lv_draw_layer.c"),
        lvgl.path("src/draw/lv_draw_transform.c"),
        lvgl.path("src/draw/lv_draw_label.c"),
        lvgl.path("src/draw/lv_draw_arc.c"),
        lvgl.path("src/draw/lv_draw_rect.c"),
        //comptime std.fmt.comptimePrint("{s}/{s}", .{ base,libs/ "lvgl/src/draw/lv_draw_blend.c" }),
        lvgl.path("src/draw/lv_draw_mask.c"),
        lvgl.path("src/draw/lv_draw_line.c"),
        lvgl.path("src/draw/lv_draw_img.c"),

        lvgl.path("src/draw/lv_img_buf.c"),
        lvgl.path("src/draw/lv_img_decoder.c"),
        lvgl.path("src/draw/lv_img_cache.c"),

        //misc
        lvgl.path("src/misc/lv_gc.c"),
        lvgl.path("src/misc/lv_utils.c"),
        lvgl.path("src/misc/lv_fs.c"),
        lvgl.path("src/misc/lv_color.c"),
        lvgl.path("src/misc/lv_async.c"),
        lvgl.path("src/misc/lv_area.c"),
        lvgl.path("src/misc/lv_anim.c"),
        lvgl.path("src/misc/lv_txt.c"),
        lvgl.path("src/misc/lv_tlsf.c"),
        lvgl.path("src/misc/lv_timer.c"),
        lvgl.path("src/misc/lv_style.c"),
        lvgl.path("src/misc/lv_ll.c"),
        lvgl.path("src/misc/lv_log.c"),
        lvgl.path("src/misc/lv_printf.c"),
        lvgl.path("src/misc/lv_mem.c"),
        lvgl.path("src/misc/lv_math.c"),
        lvgl.path("src/misc/lv_style_gen.c"),
        lvgl.path("src/misc/lv_lru.c"),

        // widgets
        lvgl.path("src/widgets/lv_arc.c"),
        lvgl.path("src/widgets/lv_btn.c"),
        lvgl.path("src/widgets/lv_btnmatrix.c"),
        lvgl.path("src/widgets/lv_bar.c"),
        lvgl.path("src/widgets/lv_dropdown.c"),
        lvgl.path("src/widgets/lv_textarea.c"),
        lvgl.path("src/widgets/lv_checkbox.c"),
        lvgl.path("src/widgets/lv_switch.c"),
        lvgl.path("src/widgets/lv_roller.c"),
        lvgl.path("src/widgets/lv_slider.c"),
        lvgl.path("src/widgets/lv_table.c"),
        lvgl.path("src/widgets/lv_img.c"),
        lvgl.path("src/widgets/lv_label.c"),
        lvgl.path("src/widgets/lv_line.c"),
        // extra
        lvgl.path("src/extra/lv_extra.c"),
        lvgl.path("src/extra/widgets/tabview/lv_tabview.c"),
        lvgl.path("src/extra/widgets/win/lv_win.c"),
        lvgl.path("src/extra/widgets/msgbox/lv_msgbox.c"),
        lvgl.path("src/extra/widgets/chart/lv_chart.c"),
        lvgl.path("src/extra/widgets/spinner/lv_spinner.c"),
        lvgl.path("src/extra/widgets/calendar/lv_calendar.c"),
        lvgl.path("src/extra/widgets/calendar/lv_calendar_header_arrow.c"),
        lvgl.path("src/extra/widgets/calendar/lv_calendar_header_dropdown.c"),
        lvgl.path("src/extra/widgets/meter/lv_meter.c"),
        lvgl.path("src/extra/widgets/keyboard/lv_keyboard.c"),
        lvgl.path("src/extra/widgets/list/lv_list.c"),
        lvgl.path("src/extra/widgets/menu/lv_menu.c"),
        //"lvgl/src/extra/widgets/spinbox/lv_spinbox.c"}),
        //"lvgl/src/extra/widgets/tileview/lv_tileview.c"}),
        //"lvgl/src/extra/widgets/colorwheel/lv_colorwheel.c"}),
        //"lvgl/src/extra/widgets/led/lv_led.c"}),
        //"lvgl/src/extra/layouts/grid/lv_grid.c"}),
        lvgl.path("src/extra/layouts/flex/lv_flex.c"),
        lvgl.path("src/extra/themes/default/lv_theme_default.c"),
        // font
        lvgl.path("src/font/lv_font.c"),
        lvgl.path("src/font/lv_font_fmt_txt.c"),
        lvgl.path("src/font/lv_font_montserrat_14.c"),
        lvgl.path("examples/widgets/menu/lv_example_menu_5.c"),
    };
    for (lvgl_source_files) |f| {
        lib.addCSourceFile(.{ .file = f, .flags = &cflags });
    }
}
