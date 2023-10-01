const lv = @import("lv.zig");
const c = lv.c;

const Obj = @This();

obj: *c.lv_obj_t,

pub const States = struct {
    pub const Default: u16 = c.LV_STATE_DEFAULT;
    pub const Checked: u16 = c.LV_STATE_CHECKED;
    pub const Focused: u16 = c.LV_STATE_FOCUSED;
    pub const FocusKey: u16 = c.LV_STATE_FOCUS_KEY;
    pub const Edited: u16 = c.LV_STATE_EDITED;
    pub const Hovered: u16 = c.LV_STATE_HOVERED;
    pub const Pressed: u16 = c.LV_STATE_PRESSED;
    pub const Scrolled: u16 = c.LV_STATE_SCROLLED;
    pub const Disabled: u16 = c.LV_STATE_DISABLED;
    pub const User1: u16 = c.LV_STATE_USER_1;
    pub const User2: u16 = c.LV_STATE_USER_2;
    pub const User3: u16 = c.LV_STATE_USER_3;
    pub const User4: u16 = c.LV_STATE_USER_4;
    pub const Any: u16 = c.LV_STATE_ANY;
};

pub fn assign(o: *c.lv_obj_t) Obj {
    return .{
        .obj = o,
    };
}

pub fn init(parent: anytype) Obj {
    return .{
        .obj = c.lv_obj_create(parent.obj).?,
    };
}

pub fn del(self: Obj) void {
    c.lv_obj_del(self.obj);
}

pub fn getChildCnt(self: Obj) u32 {
    return c.lv_obj_get_child_cnt(self.obj);
}

pub fn getChild(self: Obj, idx: u32) ?Obj {
    return if (c.lv_obj_get_child(self.obj, @as(i32, @intCast(idx)))) |obj| .{ .obj = obj } else null;
}

pub fn setSize(self: Obj, width: i16, height: i16) void {
    c.lv_obj_set_size(self.obj, width, height);
}

pub fn setHeight(self: Obj, height: i16) void {
    c.lv_obj_set_height(self.obj, height);
}

pub fn setWidth(self: Obj, width: i16) void {
    c.lv_obj_set_width(self.obj, width);
}

pub fn setPos(self: Obj, x: i16, y: i16) void {
    c.lv_obj_set_pos(self.obj, x, y);
}

pub fn center(self: Obj) void {
    c.lv_obj_center(self.obj);
}

pub fn getParent(self: Obj, comptime type_: type) ?type_ {
    return if (c.lv_obj_get_parent(self.obj)) |obj|
        return type_{ .obj = obj }
    else
        null;
}

pub fn setAlign(self: Obj, align_: lv.Align, x_ofs: lv.Coord, y_ofs: lv.Coord) void {
    c.lv_obj_align(self.obj, @intFromEnum(align_), x_ofs, y_ofs);
}

pub fn setAlignTo(self: Obj, base: anytype, align_: lv.Align, x_ofs: lv.Coord, y_ofs: lv.Coord) void {
    c.lv_obj_align_to(self.obj, base.obj, @intFromEnum(align_), x_ofs, y_ofs);
}

pub const Flag = enum(u32) {
    Hidden = c.LV_OBJ_FLAG_HIDDEN,
    Clickable = c.LV_OBJ_FLAG_CLICKABLE,
    ClickFocusable = c.LV_OBJ_FLAG_CLICK_FOCUSABLE,
    Checkable = c.LV_OBJ_FLAG_CHECKABLE,
    Scrollable = c.LV_OBJ_FLAG_SCROLLABLE,
    SCROLL_ELASTIC = c.LV_OBJ_FLAG_SCROLL_ELASTIC,
    SCROLL_MOMENTUM = c.LV_OBJ_FLAG_SCROLL_MOMENTUM,
    SCROLL_ONE = c.LV_OBJ_FLAG_SCROLL_ONE,
    SCROLL_CHAIN_HOR = c.LV_OBJ_FLAG_SCROLL_CHAIN_HOR,
    SCROLL_CHAIN_VER = c.LV_OBJ_FLAG_SCROLL_CHAIN_VER,
    SCROLL_CHAIN = c.LV_OBJ_FLAG_SCROLL_CHAIN,
    SCROLL_ON_FOCUS = c.LV_OBJ_FLAG_SCROLL_ON_FOCUS,
    SCROLL_WITH_ARROW = c.LV_OBJ_FLAG_SCROLL_WITH_ARROW,
    SNAPPABLE = c.LV_OBJ_FLAG_SNAPPABLE,
    PRESS_LOCK = c.LV_OBJ_FLAG_PRESS_LOCK,
    EVENT_BUBBLE = c.LV_OBJ_FLAG_EVENT_BUBBLE,
    GESTURE_BUBBLE = c.LV_OBJ_FLAG_GESTURE_BUBBLE,
    ADV_HITTEST = c.LV_OBJ_FLAG_ADV_HITTEST,
    IGNORE_LAYOUT = c.LV_OBJ_FLAG_IGNORE_LAYOUT,
    FLOATING = c.LV_OBJ_FLAG_FLOATING,
    OVERFLOW_VISIBLE = c.LV_OBJ_FLAG_OVERFLOW_VISIBLE,

    LAYOUT_1 = c.LV_OBJ_FLAG_LAYOUT_1,
    LAYOUT_2 = c.LV_OBJ_FLAG_LAYOUT_2,

    WIDGET_1 = c.LV_OBJ_FLAG_WIDGET_1,
    WIDGET_2 = c.LV_OBJ_FLAG_WIDGET_2,
    USER_1 = c.LV_OBJ_FLAG_USER_1,
    USER_2 = c.LV_OBJ_FLAG_USER_2,
    USER_3 = c.LV_OBJ_FLAG_USER_3,
    USER_4 = c.LV_OBJ_FLAG_USER_4,
};

// flags
pub fn addFlag(self: Obj, flag: Flag) void {
    c.lv_obj_add_flag(self.obj, @intFromEnum(flag));
}

pub fn clearFlag(self: Obj, flag: Flag) void {
    c.lv_obj_clear_flag(self.obj, @intFromEnum(flag));
}

// styles
pub const StyleSelector = enum(u32) {
    Main = c.LV_PART_MAIN,
    Scrollbar = c.LV_PART_SCROLLBAR,
    Indicator = c.LV_PART_INDICATOR,
    Knob = c.LV_PART_KNOB,
    Selected = c.LV_PART_SELECTED,
    Items = c.LV_PART_ITEMS,
    Ticks = c.LV_PART_TICKS,
    Cursor = c.LV_PART_CURSOR,

    CustomFirst = c.LV_PART_CUSTOM_FIRST,

    Any = c.LV_PART_ANY,
    _,
};
pub fn removeStyle(self: Obj, style: ?*anyopaque, selector: StyleSelector) void {
    _ = style;
    c.lv_obj_remove_style(self.obj, null, @intFromEnum(selector));
}

pub const BaseDir = enum(u8) {
    Ltr = c.LV_BASE_DIR_LTR,
    Rtl = c.LV_BASE_DIR_RTL,
    Auto = c.LV_BASE_DIR_AUTO,

    Neutral = c.LV_BASE_DIR_NEUTRAL,
    Weak = c.LV_BASE_DIR_WEAK,
    _,
};

pub fn setStyleBaseDir(self: Obj, value: BaseDir, selector: StyleSelector) void {
    c.lv_obj_set_style_base_dir(self.obj, @intFromEnum(value), @intFromEnum(selector));
}

// state
pub fn addState(self: Obj, state: u16) void {
    c.lv_obj_add_state(self.obj, state);
}

pub fn clearState(self: Obj, state: u16) void {
    c.lv_obj_clear_state(self.obj, state);
}

pub fn getState(self: Obj) u16 {
    return c.lv_obj_get_state(self.obj);
}

pub fn hasState(self: Obj, state: u16) bool {
    return c.lv_obj_has_state(self.obj, state);
}

pub fn flex(self: Obj) lv.Flex {
    return lv.Flex{ .obj = self.obj };
}

pub fn Functions(comptime Self: type) type {
    return struct {
        pub fn toObj(self: Self) Obj {
            return Obj{ .obj = self.obj };
        }

        pub fn setSize(self: Self, width: i16, height: i16) void {
            (Obj{ .obj = self.obj }).setSize(width, height);
        }

        pub fn setPos(self: Self, x: i16, y: i16) void {
            (Obj{ .obj = self.obj }).setPos(x, y);
        }

        pub fn center(self: Self) void {
            (Obj{ .obj = self.obj }).center();
        }

        // state
        pub fn addObjState(self: Self, state: u16) void {
            (Obj{ .obj = self.obj }).addState(state);
        }

        pub fn clearObjState(self: Self, state: u16) void {
            (Obj{ .obj = self.obj }).clearState(state);
        }

        pub fn getObjState(self: Self) u16 {
            return (Obj{ .obj = self.obj }).getState();
        }

        pub fn hasObjState(self: Self, state: u16) bool {
            return (Obj{ .obj = self.obj }).hasState(state);
        }

        fn generateWrapper(comptime callbacks: type, comptime name: []const u8) fn (?*c.lv_event_t) callconv(.C) void {
            return struct {
                fn f(e: ?*c.lv_event_t) callconv(.C) void {
                    @field(callbacks, name)(Self{ .obj = e.?.target.? });
                }
            }.f;
        }

        // event callbacks
        pub fn addEventCallback(self: Self, comptime callbacks: type) void {
            const events = .{
                .{ "onPressed", c.LV_EVENT_PRESSED },
                .{ "onPressing", c.LV_EVENT_PRESSING },
                .{ "onPressLost", c.LV_EVENT_PRESS_LOST },
                .{ "onShortClicked", c.LV_EVENT_SHORT_CLICKED },
                .{ "onLongPressed", c.LV_EVENT_LONG_PRESSED },
                .{ "onLongPressedRepeat", c.LV_EVENT_LONG_PRESSED_REPEAT },
                .{ "onClicked", c.LV_EVENT_CLICKED },
                .{ "onReleased", c.LV_EVENT_RELEASED },
                .{ "onValueChanged", c.LV_EVENT_VALUE_CHANGED },
            };
            inline for (events) |event| {
                if (comptime @hasDecl(callbacks, event.@"0")) {
                    _ = c.lv_obj_add_event_cb(self.obj, generateWrapper(callbacks, event.@"0"), event.@"1", null);
                }
            }
        }
    };
}
