const std = @import("std");

const Driver = enum { Gtk, FbDev, Sdl, None };

// TODO: add more "GPUs"
const Gpu = enum { Auto, Software, Sdl };

pub const Config = struct {
    driver: Driver = .None,
    gpu: Gpu = .Auto,

    // TODO: remove this
    width: u32 = 800,
    height: u32 = 480,

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
            /// false: User need to register a callback with `lv_log_register_print_cb()`
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
        /// Enable asserts if an operation is failed or an invalid data is found.
        /// If LV_USE_LOG is enabled an error message will be printed on failure
        assert: struct {
            /// Check if the parameter is NULL. (Very fast, recommended)
            null: bool = true,
            /// Checks is the memory is successfully allocated or no. (Very fast, recommended)
            malloc: bool = true,
            /// Check if the styles are properly initialized. (Very fast, recommended)
            style: bool = true,
            /// Check the integrity of `lv_mem` after critical operations. (Slow)
            mem_integrity: bool = false,
            /// Check the object's type and existence (e.g. not deleted). (Slow)
            obj: bool = false,
            handler: ?struct {
                include: []const u8,
                handler: []const u8,
            } = null,
        } = .{},
        text: struct {
            /// Select a character encoding for strings.
            /// Your IDE or editor should have the same character encoding
            encoding: enum {
                utf8,
                ascii,
            } = .utf8,
            /// Can break (wrap) texts on these chars
            break_chars: []const u8 = " ,.;:-_",
            line_break_long: ?struct {
                /// If a word is at least this long, will break wherever "prettiest"
                len: i64 = 0,
                /// Minimum number of characters in a long word to put on a line before a break.
                pre_min_len: i64 = 0,
                /// Minimum number of characters in a long word to put on a line after a break.
                post_min_len: i64 = 0,
            } = null,
            /// The control character to use for signalling text recoloring.
            color_cmd: []const u8 = "#",
            /// Support bidirectional texts. Allows mixing Left-to-Right and Right-to-Left text
            /// The direction will be processed according to the Unicode Bidirectioanl Algorith
            /// https://www.w3.org/International/articles/inline-bidi-markup/uba-basics
            bidi: ?enum {
                left_to_right,
                right_to_left,
                auto,
            } = null,
            arabic_persian_chars: bool = false,
        } = .{},
        widgets: struct {
            animimg: bool = false,
            arc: bool = false,
            bar: bool = false,
            button: bool = false,
            buttonmatrix: bool = false,
            canvas: bool = false,
            checkbox: bool = false,
            dropdown: bool = false,
            img: bool = false,
            label: bool = false,
            line: bool = true,
            roller: bool = false,
            slider: bool = false,
            @"switch": bool = false,
            scale: bool = false,
            table: bool = false,
            textarea: bool = false,
            extra: struct {
                win: bool = false,
                msgbox: bool = false,
                chart: bool = false,
                spinner: bool = false,
                calendar: bool = false,
                meter: bool = false,
                keyboard: bool = false,
                list: bool = false,
                menu: bool = false,
                spinbox: bool = false,
                tileview: bool = false,
                tabview: bool = false,
                colorwheel: bool = false,
                image: bool = false,
                span: bool = false,
                led: bool = false,
            } = .{},
        } = .{},
        layouts: struct {
            flex: bool = false,
            grid: bool = false,
        } = .{},
        theme: union(enum(usize)) {
            default: struct {
                /// enable dark mode
                dark: bool = true,
                /// enable grow on press
                grow: bool = true,
                /// transiiton time in ms
                transition_time: i64 = 80,
            },
            simple: void,
            mono: void,
        } = .{ .default = .{} },
    } = .{},
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const driver = b.option(Driver, "driver", "Driver") orelse .Sdl;
    const gpu = b.option(Gpu, "gpu", "gpu") orelse .Auto;
    const config_addr = b.option(usize, "config_addr", "only for direct use as dependency") orelse 0;
    const config: ?*Config = if (config_addr == 0) null else @as(*Config, @ptrFromInt(config_addr));

    const lvgl_dep = b.dependency("lvgl", .{});

    const lvgl = b.addStaticLibrary(.{
        .name = "lvgl",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const zlvgl = b.addModule("zlvgl", .{
        .root_source_file = b.path("src/lv.zig"),
    });

    const build_mod = b.addModule("build", .{ .root_source_file = b.path("build.zig") });
    zlvgl.addImport("build", build_mod);

    try addFiles(b, lvgl, .{
        .zlvgl = zlvgl,
        .lvgl = lvgl_dep,
    }, if (config) |c| c else &Config{
        .driver = driver,
        .gpu = gpu,
        .lvgl = .{
            .widgets = .{
                .button = true,
                .label = true,
            },
        },
    });
    b.installArtifact(lvgl);
    zlvgl.linkLibrary(lvgl);
    try zlvgl.include_dirs.appendSlice(b.allocator, lvgl.root_module.include_dirs.items);

    // {
    //     const autodoc_test = b.addTest(.{
    //         .root_source_file = b.path("src/test.zig"),
    //         .target = target,
    //     });
    //     autodoc_test.root_module.addImport("zlvgl", zlvgl);

    //     const install_docs = b.addInstallDirectory(.{
    //         .source_dir = autodoc_test.getEmittedDocs(),
    //         .install_dir = .prefix,
    //         .install_subdir = "doc",
    //     });

    //     b.getInstallStep().dependOn(&install_docs.step);
    // }
}

fn addFiles(b: *std.Build, lib: *std.Build.Step.Compile, modules: struct {
    zlvgl: *std.Build.Module,
    lvgl: *std.Build.Dependency,
}, config: *const Config) !void {
    const lvgl = modules.lvgl;

    lib.addIncludePath(b.path("zig_exports"));

    lib.addIncludePath(lvgl.path(""));
    lib.installHeadersDirectory(lvgl.path(""), "", .{ .include_extensions = &.{".h"} });

    const options = b.addOptions();
    lib.step.dependOn(&options.step);

    modules.zlvgl.addImport("config", options.createModule());
    options.addOption(Driver, "driver", config.driver);

    var list = std.ArrayList(u8).init(b.allocator);
    try std.json.stringify(config.*, .{}, list.writer());
    options.addOption([]const u8, "config", list.items);

    const config_header = b.addConfigHeader(.{
        .include_path = "lv_conf.h",
    }, .{
        .LV_COLOR_DEPTH = @as(i64, @intFromEnum(config.lvgl.color.depth)),
        .LV_COLOR_16_SWAP = config.lvgl.color.swap_rgb565,
        .LV_COLOR_SCREEN_TRANSP = config.lvgl.color.transparent_screen,
        // Images pixels with this color will not be drawn if they are  chroma keyed)
        .LV_COLOR_CHROMA_KEY = .@"lv_color_hex(0x00ff00)", // TODO: lv_color_hex

        .LV_DISP_DEF_REFR_PERIOD = config.lvgl.hal.display_refresh_period, // ms
        .LV_INDEV_DEF_READ_PERIOD = config.lvgl.hal.indev_refresh_period, //ms
        .LV_DPI_DEF = config.lvgl.hal.dpi,

        .LV_ASSERT_HANDLER_INCLUDE = "zig.h",
        .LV_ASSERT_HANDLER = .@"zig_lvgl_assert();",
    });

    switch (config.lvgl.memory.allocator) {
        .memory_pool => |pool| {
            config_header.addValues(.{
                .LV_MEM_CUSTOM = 0,
                .LV_MEM_SIZE = pool.mem_size,
                .LV_MEM_ADR = pool.address,
            });
        },
        .custom => unreachable,
    }

    config_header.addValues(.{
        .LV_MEMCPY_MEMSET_STD = 0,
    });

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
                    .LV_LOG_LEVEL = .LV_LOG_LEVEL_NONE,
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

    // assert
    config_header.addValues(.{
        .LV_USE_ASSERT_NULL = config.lvgl.assert.null,
        .LV_USE_ASSERT_MALLOC = config.lvgl.assert.malloc,
        .LV_USE_ASSERT_STYLE = config.lvgl.assert.style,
        .LV_USE_ASSERT_MEM_INTEGRITY = config.lvgl.assert.mem_integrity,
        .LV_USE_ASSERT_OBJ = config.lvgl.assert.obj,
    });
    if (config.lvgl.assert.handler) |handler| {
        // TODO: LV_ASSERT_HANDLER_INCLUDE
        // TODO: LV_ASSERT_HANDLER
        _ = handler;
        @panic("TODO");
    }

    switch (config.driver) {
        .Gtk => lib.linkSystemLibrary("gtk+-3.0"),
        .Sdl => {
            lib.linkSystemLibrary("SDL2");
            lib.linkSystemLibrary("SDL2_image");
        },
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
        .None => "",
    };
    const cflags = [_][]const u8{
        // TODO: rewrite drivers and get rid of hardcoded resolutions
        b.fmt("-DSDL_HOR_RES={}", .{config.width}),
        b.fmt("-DSDL_VER_RES={}", .{config.height}),
        b.fmt("-DLV_HOR_RES={}", .{config.width}),
        b.fmt("-DLV_VER_RES={}", .{config.height}),
        b.fmt("-DLV_HOR_RES_MAX={}", .{config.width}),
        b.fmt("-DLV_VER_RES_MAX={}", .{config.height}),
        "-DLV_USE_OS=LV_OS_PTHREAD", // TODO

        "-DLV_LVGL_H_INCLUDE_SIMPLE=1",
        "-DLV_CONF_INCLUDE_SIMPLE=1",

        "-fno-sanitize=all",
        driver_define,
        // "-DSDL_INCLUDE_PATH=SDL/SDL.h",
        "-DSDL_ZOOM=1",
        if (gpu == .Sdl) "-DLV_USE_GPU_SDL=1" else "",
        "-DLV_GPU_SDL_CUSTOM_BLEND_MODE=0", // TODO
        "-Wno-incompatible-function-pointer-types",
        "-DSDL_INCLUDE_PATH=<SDL2/SDL.h>",
    };

    var files = std.ArrayList(std.Build.LazyPath).init(b.allocator);

    switch (config.driver) {
        .Gtk => {
            // try files.append(lv_drivers.path("gtkdrv/gtkdrv.c"));
        },
        .FbDev => {
            // try files.append(lv_drivers.path("display/fbdev.c"));
        },
        .Sdl => {
            switch (gpu) {
                .Sdl, .Software => {
                    try files.append(lvgl.path("src/drivers/sdl/lv_sdl_keyboard.c"));
                    try files.append(lvgl.path("src/drivers/sdl/lv_sdl_mouse.c"));
                    try files.append(lvgl.path("src/drivers/sdl/lv_sdl_mousewheel.c"));
                    try files.append(lvgl.path("src/drivers/sdl/lv_sdl_window.c"));
                },
                else => {
                    std.log.err("Invalid gpu for SDL driver", .{});
                    return error.InvalidGpu;
                },
            }
        },
        .None => {},
    }

    // TODO
    // lib.addCSourceFile(.{ .file = lv_drivers.path("indev/evdev.c"), .flags = &cflags });

    const lvgl_draw_sw_source_files = [_]std.Build.LazyPath{
        lvgl.path("src/draw/sw/lv_draw_sw.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_mask.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_fill.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_border.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_gradient.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_box_shadow.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_mask_rect.c"),
        lvgl.path("src/draw/sw/blend/lv_draw_sw_blend.c"),
        lvgl.path("src/draw/sw/blend/lv_draw_sw_blend_to_rgb565.c"),
        lvgl.path("src/draw/sw/blend/lv_draw_sw_blend_to_argb8888.c"),
        lvgl.path("src/draw/sw/blend/lv_draw_sw_blend_to_rgb888.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_letter.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_img.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_arc.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_line.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_triangle.c"),
        lvgl.path("src/draw/sw/lv_draw_sw_transform.c"),
    };
    config_header.addValues(.{
        .LV_USE_SDL = config.driver == .Sdl,
        .LV_USE_DRAW_SDL = gpu == .Sdl,
        .LV_USE_DRAW_SW = true,
        .LV_SDL_INCLUDE_PATH = .@"<SDL2/SDL.h>",
    });

    const lvgl_draw_sdl_source_files = [_]std.Build.LazyPath{
        lvgl.path("src/draw/sdl/lv_draw_sdl.c"),

        // lvgl.path("src/draw/sdl/lv_draw_sdl_bg.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_composite.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_utils.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_layer.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_mask.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_texture_cache.c"),
        // // lvgl.path("src/draw/sdl/lv_draw_sdl_transform.c"),
        // // lvgl.path("src/draw/sdl/lv_draw_sdl_blend.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_arc.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_rect.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_label.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_img.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_line.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_polygon.c"),
        // lvgl.path("src/draw/sdl/lv_draw_sdl_stack_blur.c"),

        // // sw components needed by SDL
        // lvgl.path("src/draw/sw/lv_draw_sw_blend.c"),
        // lvgl.path("src/draw/sw/lv_draw_sw_gradient.c"),
        // lvgl.path("src/draw/sw/lv_draw_sw_letter.c"),
    };
    try files.appendSlice(&lvgl_draw_sw_source_files);

    switch (gpu) {
        .Software => {},
        .Sdl => {
            try files.appendSlice(&lvgl_draw_sdl_source_files);
        },
        .Auto => unreachable,
    }

    try files.appendSlice(&.{
        lvgl.path("src/lv_init.c"),

        // core
        lvgl.path("src/core/lv_group.c"),
        lvgl.path("src/core/lv_refr.c"),
        lvgl.path("src/core/lv_obj.c"),
        lvgl.path("src/core/lv_obj_class.c"),
        lvgl.path("src/core/lv_obj_pos.c"),
        lvgl.path("src/core/lv_obj_event.c"),
        lvgl.path("src/core/lv_obj_tree.c"),
        lvgl.path("src/core/lv_obj_draw.c"),
        lvgl.path("src/core/lv_obj_style.c"),
        lvgl.path("src/core/lv_obj_style_gen.c"),
        lvgl.path("src/core/lv_obj_scroll.c"),

        //widets

        //display
        lvgl.path("src/display/lv_display.c"),

        //indev
        lvgl.path("src/indev/lv_indev.c"),
        lvgl.path("src/indev/lv_indev_scroll.c"),

        //themes
        lvgl.path("src/themes/lv_theme.c"),

        //hal
        // lvgl.path("src/hal/lv_hal_indev.c"),
        //tick
        lvgl.path("src/tick/lv_tick.c"),
        // lvgl.path("src/hal/lv_hal_disp.c"),

        //draw
        lvgl.path("src/draw/lv_draw.c"),
        lvgl.path("src/draw/lv_draw_buf.c"),
        // lvgl.path("src/draw/lv_draw_layer.c"),
        // lvgl.path("src/draw/lv_draw_transform.c"),
        lvgl.path("src/draw/lv_draw_label.c"),
        lvgl.path("src/draw/lv_draw_arc.c"),
        lvgl.path("src/draw/lv_draw_rect.c"),
        lvgl.path("src/draw/lv_draw_mask.c"),
        lvgl.path("src/draw/lv_draw_line.c"),
        lvgl.path("src/draw/lv_draw_image.c"),

        // lvgl.path("src/draw/lv_image_buf.c"),
        lvgl.path("src/draw/lv_image_decoder.c"),
        // lvgl.path("src/draw/lv_img_cache.c"),

        //misc
        // lvgl.path("src/misc/lv_gc.c"),
        lvgl.path("src/misc/lv_array.c"),
        lvgl.path("src/misc/lv_utils.c"),
        lvgl.path("src/misc/lv_fs.c"),
        lvgl.path("src/misc/lv_event.c"),
        lvgl.path("src/misc/lv_color.c"),
        lvgl.path("src/misc/lv_async.c"),
        lvgl.path("src/misc/lv_area.c"),
        lvgl.path("src/misc/lv_anim.c"),
        lvgl.path("src/misc/lv_text.c"),
        lvgl.path("src/misc/lv_palette.c"),
        // lvgl.path("src/misc/lv_tlsf.c"),
        lvgl.path("src/misc/lv_timer.c"),
        lvgl.path("src/misc/lv_style.c"),
        lvgl.path("src/misc/lv_ll.c"),
        lvgl.path("src/misc/lv_log.c"),
        // lvgl.path("src/misc/lv_printf.c"),
        // lvgl.path("src/misc/lv_mem.c"),
        lvgl.path("src/misc/lv_math.c"),
        lvgl.path("src/misc/lv_style_gen.c"),
        lvgl.path("src/misc/lv_lru.c"),
        lvgl.path("src/misc/lv_rb.c"),
        lvgl.path("src/misc/cache/lv_cache.c"),
        lvgl.path("src/misc/cache/lv_cache_entry.c"),
        lvgl.path("src/misc/cache/lv_image_cache.c"),
        lvgl.path("src/misc/cache/_lv_cache_lru_rb.c"),

        // extra
        // lvgl.path("src/extra/lv_extra.c"),

        //stdlib
        lvgl.path("src/stdlib/lv_mem.c"),
        lvgl.path("src/stdlib/builtin/lv_tlsf.c"),
        lvgl.path("src/stdlib/builtin/lv_string_builtin.c"),
        lvgl.path("src/stdlib/builtin/lv_mem_core_builtin.c"),
        lvgl.path("src/stdlib/builtin/lv_sprintf_builtin.c"),

        //libs
        lvgl.path("src/libs/bin_decoder/lv_bin_decoder.c"),

        //TODO: make this configurable
        lvgl.path("src/osal/lv_pthread.c"),

        // font
        lvgl.path("src/font/lv_font.c"),
        lvgl.path("src/font/lv_font_fmt_txt.c"),
        lvgl.path("src/font/lv_font_montserrat_14.c"),
    });

    switch (config.lvgl.text.encoding) {
        .utf8 => {
            config_header.addValues(.{
                .LV_TXT_ENC = .LV_TXT_ENC_UTF8,
            });
        },
        .ascii => {
            config_header.addValues(.{
                .LV_TXT_ENC = .LV_TXT_ENC_ASCII,
            });
        },
    }

    config_header.addValues(.{
        .LV_TXT_BREAK_CHARS = config.lvgl.text.break_chars,
        .LV_TXT_COLOR_CMD = config.lvgl.text.color_cmd,
        .LV_USE_ARABIC_PERSIAN_CHARS = config.lvgl.text.arabic_persian_chars,
    });

    if (config.lvgl.text.line_break_long) |line_break| {
        config_header.addValues(.{
            .LV_TXT_LINE_BREAK_LONG_LEN = line_break.len,
            .LV_TXT_LINE_BREAK_LONG_PRE_MIN_LEN = line_break.pre_min_len,
            .LV_TXT_LINE_BREAK_LONG_POST_MIN_LEN = line_break.post_min_len,
        });
    } else {
        config_header.addValues(.{
            .LV_TXT_LINE_BREAK_LONG_LEN = 0,
        });
    }

    if (config.lvgl.text.bidi) |bidi| {
        switch (bidi) {
            .left_to_right => {
                config_header.addValues(.{
                    .LV_BIDI_BASE_DIR_DEF = .LV_BASE_DIR_LTR,
                });
            },
            .right_to_left => {
                config_header.addValues(.{
                    .LV_BIDI_BASE_DIR_DEF = .LV_BASE_DIR_RTL,
                });
            },
            .auto => {
                config_header.addValues(.{
                    .LV_BIDI_BASE_DIR_DEF = .LV_BASE_DIR_AUTO,
                });
            },
        }
    }

    // widgets
    config_header.addValues(.{
        .LV_USE_ANIMIMG = config.lvgl.widgets.animimg,
        .LV_USE_ARC = config.lvgl.widgets.arc,
        .LV_USE_BUTTON = config.lvgl.widgets.button,
        .LV_USE_BTNMATRIX = config.lvgl.widgets.buttonmatrix,
        .LV_USE_BAR = config.lvgl.widgets.bar,
        .LV_USE_CANVAS = config.lvgl.widgets.canvas,
        .LV_USE_DROPDOWN = config.lvgl.widgets.dropdown,
        // TODO: LV_TEXTAREA_DEF_PWD_SHOW_TIME
        .LV_USE_TEXTAREA = config.lvgl.widgets.textarea,
        .LV_USE_CHECKBOX = config.lvgl.widgets.checkbox,
        .LV_USE_SWITCH = config.lvgl.widgets.@"switch",
        .LV_USE_SCALE = config.lvgl.widgets.scale,
        .LV_USE_SLIDER = config.lvgl.widgets.slider,
        // TODO: LV_ROLLER_INF_PAGES
        .LV_USE_ROLLER = config.lvgl.widgets.roller,
        .LV_USE_TABLE = config.lvgl.widgets.table,
        .LV_USE_IMG = config.lvgl.widgets.img,
        // TODO: LV_LABEL_TEXT_SELECTION and LV_LABEL_LONG_TXT_HINT
        .LV_USE_LABEL = config.lvgl.widgets.label,
        .LV_USE_LINE = config.lvgl.widgets.line,
    });

    if (config.lvgl.widgets.dropdown and !config.lvgl.widgets.label) {
        @panic("Dropdown requires Label");
    }

    if (config.lvgl.widgets.img and !config.lvgl.widgets.label) {
        @panic("Img requires Label");
    }

    if (config.lvgl.widgets.textarea and !config.lvgl.widgets.label) {
        @panic("Textarea requires Label");
    }

    if (config.lvgl.widgets.slider and !config.lvgl.widgets.bar) {
        @panic("Slider requires Bar");
    }

    inline for (&.{
        "animimg",
        "arc",
        "button",
        "buttonmatrix",
        "bar",
        "dropdown",
        "textarea",
        "checkbox",
        "switch",
        "slider",
        "scale",
        "table",
        "img",
        "label",
        "line",
    }) |widget| {
        if (@field(config.lvgl.widgets, widget))
            try files.append(lvgl.path("src/widgets/" ++ widget ++ "/lv_" ++ widget ++ ".c"));
    }

    // extra widgets
    config_header.addValues(.{
        .LV_USE_TABVIEW = config.lvgl.widgets.extra.tabview,
    });
    if (config.lvgl.widgets.extra.tabview) {
        try files.append(lvgl.path("src/widgets/tabview/lv_tabview.c"));
        if (!config.lvgl.widgets.buttonmatrix) {
            @panic("TabView requires ButtonMatrix");
        }
        if (!config.lvgl.layouts.flex) {
            @panic("TabView requires Flex layout");
        }
    }

    config_header.addValues(.{
        .LV_USE_WIN = config.lvgl.widgets.extra.win,
    });
    if (config.lvgl.widgets.extra.win) {
        try files.append(lvgl.path("src/extra/widgets/win/lv_win.c"));
    }

    config_header.addValues(.{
        .LV_USE_MSGBOX = config.lvgl.widgets.extra.msgbox,
    });
    if (config.lvgl.widgets.extra.msgbox) {
        try files.append(lvgl.path("src/extra/widgets/win/lv_win.c"));
    }

    config_header.addValues(.{
        .LV_USE_CHART = config.lvgl.widgets.extra.chart,
    });
    if (config.lvgl.widgets.extra.chart) {
        try files.append(lvgl.path("src/extra/widgets/chart/lv_chart.c"));
    }

    config_header.addValues(.{
        .LV_USE_SPINNER = config.lvgl.widgets.extra.spinner,
    });
    if (config.lvgl.widgets.extra.spinner) {
        try files.append(lvgl.path("src/extra/widgets/spinner/lv_spinner.c"));
    }

    config_header.addValues(.{
        .LV_USE_CALENDAR = config.lvgl.widgets.extra.calendar,
    });
    if (config.lvgl.widgets.extra.calendar) {
        // TODO: LV_CALENDAR_WEEK_STARTS_MONDAY
        // TODO: LV_CALENDAR_DEFAULT_DAY_NAMES
        // TODO: LV_CALENDAR_DEFAULT_MONTH_NAMES
        // TODO: LV_USE_CALENDAR_HEADER_ARROW
        // TODO: LV_USE_CALENDAR_HEADER_DROPDOWN
        try files.append(lvgl.path("src/extra/widgets/calendar/lv_calendar.c"));
        try files.append(lvgl.path("src/extra/widgets/calendar/lv_calendar_header_arrow.c"));
        try files.append(lvgl.path("src/extra/widgets/calendar/lv_calendar_header_dropdown.c"));
    }

    config_header.addValues(.{
        .LV_USE_METER = config.lvgl.widgets.extra.meter,
    });
    if (config.lvgl.widgets.extra.meter) {
        try files.append(lvgl.path("src/extra/widgets/meter/lv_meter.c"));
    }

    config_header.addValues(.{
        .LV_USE_KEYBOARD = config.lvgl.widgets.extra.keyboard,
    });
    if (config.lvgl.widgets.extra.keyboard) {
        try files.append(lvgl.path("src/extra/widgets/keyboard/lv_keyboard.c"));
    }

    config_header.addValues(.{
        .LV_USE_LIST = config.lvgl.widgets.extra.list,
    });
    if (config.lvgl.widgets.extra.list) {
        try files.append(lvgl.path("src/extra/widgets/list/lv_list.c"));
    }

    config_header.addValues(.{
        .LV_USE_MENU = config.lvgl.widgets.extra.menu,
    });
    if (config.lvgl.widgets.extra.menu) {
        try files.append(lvgl.path("src/extra/widgets/menu/lv_menu.c"));
    }

    config_header.addValues(.{
        .LV_USE_SPINBOX = config.lvgl.widgets.extra.spinbox,
    });
    if (config.lvgl.widgets.extra.spinbox) {
        try files.append(lvgl.path("src/extra/widgets/spinbox/lv_spinbox.c"));
    }

    config_header.addValues(.{
        .LV_USE_TILEVIEW = config.lvgl.widgets.extra.tileview,
    });
    if (config.lvgl.widgets.extra.tileview) {
        try files.append(lvgl.path("src/extra/widgets/tileview/lv_tileview.c"));
    }

    config_header.addValues(.{
        .LV_USE_COLORWHEEL = config.lvgl.widgets.extra.colorwheel,
    });
    if (config.lvgl.widgets.extra.colorwheel) {
        try files.append(lvgl.path("src/extra/widgets/colorwheel/lv_colorwheel.c"));
    }

    config_header.addValues(.{
        .LV_USE_LED = config.lvgl.widgets.extra.led,
    });
    if (config.lvgl.widgets.extra.led) {
        try files.append(lvgl.path("src/extra/widgets/led/lv_led.c"));
    }

    config_header.addValues(.{
        .LV_USE_SPAN = config.lvgl.widgets.extra.span,
    });
    if (config.lvgl.widgets.extra.span) {
        // TODO: LV_SPAN_SNIPPET_STACK_SIZE
        try files.append(lvgl.path("src/extra/widgets/span/lv_span.c"));
    }

    config_header.addValues(.{
        .LV_USE_IMAGE = config.lvgl.widgets.extra.image,
    });
    if (config.lvgl.widgets.extra.image) {
        try files.append(lvgl.path("src/extra/widgets/imgbtn/lv_imgbtn.c"));
    }

    // layouts
    try files.append(lvgl.path("src/layouts/lv_layout.c"));

    config_header.addValues(.{
        .LV_USE_FLEX = config.lvgl.layouts.flex,
        .LV_USE_GRID = config.lvgl.layouts.grid,
    });

    if (config.lvgl.layouts.flex) {
        try files.append(lvgl.path("src/layouts/flex/lv_flex.c"));
    }
    if (config.lvgl.layouts.grid) {
        try files.append(lvgl.path("src/layouts/grid/lv_grid.c"));
    }
    config_header.addValues(.{
        .LV_USE_THEME_DEFAULT = config.lvgl.theme == .default,
        .LV_USE_THEME_SIMPLE = config.lvgl.theme == .simple,
        .LV_USE_THEME_MONO = config.lvgl.theme == .mono,
    });

    switch (config.lvgl.theme) {
        .default => |def| {
            config_header.addValues(.{
                .LV_THEME_DEFAULT_DARK = def.dark,
                .LV_THEME_DEFAULT_GROW = def.grow,
                .LV_THEME_DEFAULT_TRANSITON_TIME = def.transition_time,
            });
            try files.append(lvgl.path("src/themes/default/lv_theme_default.c"));
        },
        .simple => {
            try files.append(lvgl.path("src/themes/simple/lv_theme_simple.c"));
        },
        .mono => {
            try files.append(lvgl.path("src/themes/mono/lv_theme_mono.c"));
        },
    }

    // disable the C examples
    config_header.addValues(.{
        .LV_BUILD_EXAMPLES = false,
    });

    for (files.items) |f| {
        lib.addCSourceFile(.{ .file = f, .flags = &cflags });
    }

    lib.addConfigHeader(config_header);
    lib.installConfigHeader(config_header);
}
