pub const c = @cImport({
    @cDefine("USE_GTK", "1");
    @cDefine("ZIG", "1");
    @cInclude("lvgl/lvgl.h");
    @cInclude("lv_drivers/gtkdrv/gtkdrv.h");
    @cInclude("lv_drivers/display/fbdev.h");
    @cInclude("lv_drivers/indev/evdev.h");
});
