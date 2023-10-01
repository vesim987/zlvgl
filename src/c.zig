const config = @import("lv.zig").config;

pub const c = @cImport({
    switch (config.driver) {
        .Sdl => {
            switch (config.gpu) {
                .Software => {
                    @cDefine("USE_SDL", "1");
                },
                .Sdl => {
                    @cDefine("USE_SDL_GPU", "1");
                },
                else => unreachable,
            }
        },
        .Gtk => {
            @cDefine("USE_GTK", "1");
        },
        .FbDev => {
            @cDefine("USE_FBDEV", "1");
        },
    }
    @cDefine("LV_LVGL_H_INCLUDE_SIMPLE", "1");
    @cDefine("SDL_INCLUDE_PATH", "<SDL2/SDL.h>");
    @cDefine("ZIG", "1");
    @cInclude("lvgl.h");
    @cInclude("gtkdrv/gtkdrv.h");
    @cInclude("display/fbdev.h");
    @cInclude("indev/evdev.h");
    @cInclude("sdl/sdl.h");
    @cInclude("sdl/sdl_gpu.h");
});
