const lv = @import("lv.zig");
const c = lv.c;
const config = lv.config;

var disp_buf1: c.lv_disp_draw_buf_t = undefined;
var buf1: [800 * 480 * 4]u8 = undefined;
pub const fbdev = struct {
    pub fn init() void {
        c.fbdev_init();
    }

    pub fn deinit() void {
        c.fbdev_exit();
    }

    pub fn register() void {
        register_display_driver();
        register_mouse_driver();
    }

    var disp_drv: c.lv_disp_drv_t = undefined;
    pub fn register_display_driver() void {
        c.lv_disp_draw_buf_init(&disp_buf1, @as(*anyopaque, @ptrCast(&buf1)), null, buf1.len);
        c.lv_disp_drv_init(&disp_drv);
        disp_drv.draw_buf = &disp_buf1;
        disp_drv.flush_cb = c.fbdev_flush;
        _ = c.lv_disp_drv_register(&disp_drv);
    }

    var indev_drv_mouse: c.lv_indev_drv_t = undefined;
    pub fn register_mouse_driver() void {
        // c.lv_indev_drv_init(&indev_drv_mouse);
        // indev_drv_mouse.type = c.LV_INDEV_TYPE_POINTER;
        // indev_drv_mouse.read_cb = c.gtkdrv_mouse_read_cb;
        // _ = c.lv_indev_drv_register(&indev_drv_mouse);
    }
};
pub const evdev = struct {
    pub fn init() void {
        c.evdev_init();
    }

    pub fn deinit() void {}

    var indev_evdev_drv: c.lv_indev_drv_t = undefined;
    pub fn register() void {
        c.lv_indev_drv_init(&indev_evdev_drv);
        indev_evdev_drv.type = c.LV_INDEV_TYPE_POINTER | c.LV_INDEV_TYPE_KEYPAD;
        indev_evdev_drv.read_cb = c.evdev_read;
        _ = c.lv_indev_drv_register(&indev_evdev_drv);
    }
};
pub const gtk = struct {
    pub fn init() void {
        c.gtkdrv_init();
    }

    pub fn deinit() void {}

    pub fn register() void {
        register_display_driver();
        register_mouse_driver();
    }

    var disp_drv: c.lv_disp_drv_t = undefined;
    pub fn register_display_driver() void {
        c.lv_disp_draw_buf_init(&disp_buf1, @as(*anyopaque, @ptrCast(&buf1)), null, buf1.len);
        c.lv_disp_drv_init(&disp_drv);
        disp_drv.hor_res = 800;
        disp_drv.ver_res = 480;
        disp_drv.draw_buf = &disp_buf1;
        disp_drv.flush_cb = c.gtkdrv_flush_cb;
        _ = c.lv_disp_drv_register(&disp_drv);
    }

    var gtk_drv_mouse: c.lv_indev_drv_t = undefined;
    pub fn register_mouse_driver() void {
        c.lv_indev_drv_init(&gtk_drv_mouse);
        gtk_drv_mouse.type = c.LV_INDEV_TYPE_POINTER;
        gtk_drv_mouse.read_cb = c.gtkdrv_mouse_read_cb;
        _ = c.lv_indev_drv_register(&gtk_drv_mouse);
    }
};

pub const sdl = struct {
    pub fn init() void {
        c.sdl_init();
    }

    pub fn deinit() void {}

    pub fn register() void {
        register_display_driver();
        register_mouse_driver();
    }

    var disp_drv: c.lv_disp_drv_t = undefined;
    pub fn register_display_driver() void {
        switch (config.gpu) {
            .Sdl => {
                c.sdl_disp_drv_init(&disp_drv, 800, 480);
            },
            .Software => {
                c.lv_disp_draw_buf_init(&disp_buf1, @as(*anyopaque, @ptrCast(&buf1)), null, buf1.len);
                c.lv_disp_drv_init(&disp_drv);
                disp_drv.hor_res = 800;
                disp_drv.ver_res = 480;
                disp_drv.draw_buf = &disp_buf1;
                disp_drv.flush_cb = c.sdl_display_flush;
            },
            else => unreachable,
        }
        _ = c.lv_disp_drv_register(&disp_drv);
    }

    var sdl_drv_mouse: c.lv_indev_drv_t = undefined;
    pub fn register_mouse_driver() void {
        c.lv_indev_drv_init(&sdl_drv_mouse);
        sdl_drv_mouse.type = c.LV_INDEV_TYPE_POINTER;
        sdl_drv_mouse.read_cb = c.sdl_mouse_read;
        _ = c.lv_indev_drv_register(&sdl_drv_mouse);
    }
};

pub fn init() void {
    switch (config.driver) {
        .Sdl => {
            sdl.init();
        },
        .Gtk => {
            gtk.init();
        },
        .FbDev => {
            fbdev.init();
        },
    }
}

pub fn deinit() void {
    switch (config.driver) {
        .Sdl => {
            sdl.deinit();
        },
        .Gtk => {
            gtk.deinit();
        },
        .FbDev => {
            fbdev.deinit();
        },
    }
}

pub fn register() void {
    switch (config.driver) {
        .Sdl => {
            sdl.register();
        },
        .Gtk => {
            gtk.register();
        },
        .FbDev => {
            fbdev.register();
        },
    }
}
