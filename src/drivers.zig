const lv = @import("lv.zig");
const c = lv.c;

var disp_buf1: c.lv_disp_draw_buf_t = undefined;
var buf1: [800 * 480 * 4]u8 = undefined;
pub const fbdev = struct {
    pub fn init() void {
        c.fbdev_init();
    }

    pub fn deinit() void {
        c.fbdev_exit();
    }

    var disp_drv: c.lv_disp_drv_t = undefined;
    pub fn register_display_driver() void {
        c.lv_disp_draw_buf_init(&disp_buf1, @ptrCast(*anyopaque, &buf1), null, buf1.len);
        c.lv_disp_drv_init(&disp_drv);
        disp_drv.draw_buf = &disp_buf1;
        disp_drv.flush_cb = c.fbdev_flush;
        _ = c.lv_disp_drv_register(&disp_drv);
    }

    var indev_drv_mouse: c.lv_indev_drv_t = undefined;
    pub fn register_mouse_driver() void {
        c.lv_indev_drv_init(&indev_drv_mouse);
        indev_drv_mouse.type = c.LV_INDEV_TYPE_POINTER;
        indev_drv_mouse.read_cb = c.gtkdrv_mouse_read_cb;
        _ = c.lv_indev_drv_register(&indev_drv_mouse);
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

    var disp_drv: c.lv_disp_drv_t = undefined;
    pub fn register_display_driver() void {
        c.lv_disp_draw_buf_init(&disp_buf1, @ptrCast(*anyopaque, &buf1), null, buf1.len);
        c.lv_disp_drv_init(&disp_drv);
        disp_drv.hor_res = 800;
        disp_drv.ver_res = 480;
        disp_drv.draw_buf = &disp_buf1;
        disp_drv.flush_cb = c.gtkdrv_flush_cb;
        _ = c.lv_disp_drv_register(&disp_drv);
    }

    var indev_drv_mouse: c.lv_indev_drv_t = undefined;
    pub fn register_mouse_driver() void {
        c.lv_indev_drv_init(&indev_drv_mouse);
        indev_drv_mouse.type = c.LV_INDEV_TYPE_POINTER;
        indev_drv_mouse.read_cb = c.gtkdrv_mouse_read_cb;
        _ = c.lv_indev_drv_register(&indev_drv_mouse);
    }
};

pub fn init() void {
    //lv.drivers.fbdev.init();
    gtk.init();
}

pub fn deinit() void {
    //lv.drivers.fbdev.deinit();
    gtk.deinit();
}

pub fn register() void {
    //lv.drivers.fbdev.register_display_driver();
    //lv.drivers.fbdev.register_mouse_driver();
    gtk.register_display_driver();
    gtk.register_mouse_driver();
}
