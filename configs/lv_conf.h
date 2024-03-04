/**
 * @file lv_conf.h
 * Configuration file for v8.1.0-dev
 */

/*
 * Copy this file as `lv_conf.h`
 * 1. simply next to the `lvgl` folder
 * 2. or any other places and
 *    - define `LV_CONF_INCLUDE_SIMPLE`
 *    - add the path as include path
 */

/* clang-format off */
#if 1 /*Set it to "1" to enable content*/

#ifndef LV_CONF_H
#define LV_CONF_H

#include <stdint.h>

#include <lv_conf_zig.h>

/*=========================
   MEMORY SETTINGS
 *=========================*/

/*1: use custom malloc/free, 0: use the built-in `lv_mem_alloc()` and `lv_mem_free()`*/
#if LV_MEM_CUSTOM == 1 /*LV_MEM_CUSTOM*/
#  define LV_MEM_CUSTOM_INCLUDE <stdlib.h>   /*Header for the dynamic memory function*/
#  define LV_MEM_CUSTOM_ALLOC     malloc
#  define LV_MEM_CUSTOM_FREE      free
#  define LV_MEM_CUSTOM_REALLOC   realloc
#endif     /*LV_MEM_CUSTOM*/


/*====================
   HAL SETTINGS
 *====================*/

#if LV_TICK_CUSTOM
#define LV_TICK_CUSTOM_INCLUDE  "lv_drivers/gtkdrv/gtkdrv.h"         /*Header for the system time function*/
#define LV_TICK_CUSTOM_SYS_TIME_EXPR (gtkdrv_tick_get())     /*Expression evaluating to current system time in ms*/
#endif   /*LV_TICK_CUSTOM*/

/*=======================
 * FEATURE CONFIGURATION
 *=======================*/

/*-------------
 * Drawing
 *-----------*/

/*Enable complex draw engine.
 *Required to draw shadow, gradient, rounded corners, circles, arc, skew lines, image transformations or any masks*/
#define LV_DRAW_COMPLEX 1
#if LV_DRAW_COMPLEX != 0

/*Allow buffering some shadow calculation.
 *LV_SHADOW_CACHE_SIZE is the max. shadow size to buffer, where shadow size is `shadow_width + radius`
 *Caching has LV_SHADOW_CACHE_SIZE^2 RAM cost*/
#define LV_SHADOW_CACHE_SIZE    0

/* Set number of maximally cached circle data.
 * The circumference of 1/4 circle are saved for anti-aliasing
 * radius * 4 bytes are used per circle (the most often used radiuses are saved)
 * 0: to disable caching */
#define LV_CIRCLE_CACHE_SIZE    4

#endif /*LV_DRAW_COMPLEX*/

/*Default image cache size. Image caching keeps the images opened.
 *If only the built-in image formats are used there is no real advantage of caching. (I.e. if no new image decoder is added)
 *With complex image decoders (e.g. PNG or JPG) caching can save the continuous open/decode of images.
 *However the opened images might consume additional RAM.
 *0: to disable caching*/
#define LV_IMG_CACHE_DEF_SIZE       0

/*Maximum buffer size to allocate for rotation. Only used if software rotation is enabled in the display driver.*/
#define LV_DISP_ROT_MAX_BUF         (10*1024)

/*-------------
 * GPU
 *-----------*/

/*Use STM32's DMA2D (aka Chrom Art) GPU*/
#define LV_USE_GPU_STM32_DMA2D  0
#if LV_USE_GPU_STM32_DMA2D
/*Must be defined to include path of CMSIS header of target processor
e.g. "stm32f769xx.h" or "stm32f429xx.h"*/
#define LV_GPU_DMA2D_CMSIS_INCLUDE
#endif

/*Use NXP's PXP GPU iMX RTxxx platforms*/
#define LV_USE_GPU_NXP_PXP      0
#if LV_USE_GPU_NXP_PXP
/*1: Add default bare metal and FreeRTOS interrupt handling routines for PXP (lv_gpu_nxp_pxp_osa.c)
 *   and call lv_gpu_nxp_pxp_init() automatically during lv_init(). Note that symbol SDK_OS_FREE_RTOS
 *   has to be defined in order to use FreeRTOS OSA, otherwise bare-metal implementation is selected.
 *0: lv_gpu_nxp_pxp_init() has to be called manually before lv_init()
 */
#define LV_USE_GPU_NXP_PXP_AUTO_INIT 0
#endif

/*Use NXP's VG-Lite GPU iMX RTxxx platforms*/
#define LV_USE_GPU_NXP_VG_LITE   0


/*-------------
 * Asserts
 *-----------*/

/*Add a custom handler when assert happens e.g. to restart the MCU*/
#define LV_ASSERT_HANDLER_INCLUDE   <stdint.h>
#define LV_ASSERT_HANDLER   while(1);   /*Halt by default*/

/*-------------
 * Others
 *-----------*/

/*1: Show CPU usage and FPS count in the right bottom corner*/
#define LV_USE_PERF_MONITOR     0

/*1: Show the used memory and the memory fragmentation  in the left bottom corner
 * Requires LV_MEM_CUSTOM = 0*/
#define LV_USE_MEM_MONITOR      0

/*1: Draw random colored rectangles over the redrawn areas*/
#define LV_USE_REFR_DEBUG       0

/*Change the built in (v)snprintf functions*/
#define LV_SPRINTF_CUSTOM   0
#if LV_SPRINTF_CUSTOM
#  define LV_SPRINTF_INCLUDE <stdio.h>
#  define lv_snprintf     snprintf
#  define lv_vsnprintf    vsnprintf
#else   /*LV_SPRINTF_CUSTOM*/
#  define LV_SPRINTF_USE_FLOAT 0
#endif  /*LV_SPRINTF_CUSTOM*/

#define LV_USE_USER_DATA      1

/*Garbage Collector settings
 *Used if lvgl is binded to higher level language and the memory is managed by that language*/
#define LV_ENABLE_GC 0
#if LV_ENABLE_GC != 0
#  define LV_GC_INCLUDE "gc.h"                           /*Include Garbage Collector related things*/
#endif /*LV_ENABLE_GC*/

/*1: Enable API to take snapshot for object*/
#define LV_USE_SNAPSHOT         0

/*=====================
 *  COMPILER SETTINGS
 *====================*/

/*For big endian systems set to 1*/
#define LV_BIG_ENDIAN_SYSTEM    0

/*Define a custom attribute to `lv_tick_inc` function*/
#define LV_ATTRIBUTE_TICK_INC

/*Define a custom attribute to `lv_timer_handler` function*/
#define LV_ATTRIBUTE_TIMER_HANDLER

/*Define a custom attribute to `lv_disp_flush_ready` function*/
#define LV_ATTRIBUTE_FLUSH_READY

/*Required alignment size for buffers*/
#define LV_ATTRIBUTE_MEM_ALIGN_SIZE

/*Will be added where memories needs to be aligned (with -Os data might not be aligned to boundary by default).
 * E.g. __attribute__((aligned(4)))*/
#define LV_ATTRIBUTE_MEM_ALIGN

/*Attribute to mark large constant arrays for example font's bitmaps*/
#define LV_ATTRIBUTE_LARGE_CONST

/*Complier prefix for a big array declaration in RAM*/
#define LV_ATTRIBUTE_LARGE_RAM_ARRAY

/*Place performance critical functions into a faster memory (e.g RAM)*/
#define LV_ATTRIBUTE_FAST_MEM

/*Prefix variables that are used in GPU accelerated operations, often these need to be placed in RAM sections that are DMA accessible*/
#define LV_ATTRIBUTE_DMA

/*Export integer constant to binding. This macro is used with constants in the form of LV_<CONST> that
 *should also appear on LVGL binding API such as Micropython.*/
#define LV_EXPORT_CONST_INT(int_value) struct _silence_gcc_warning /*The default value just prevents GCC warning*/

/*Extend the default -32k..32k coordinate range to -4M..4M by using int32_t for coordinates instead of int16_t*/
#define LV_USE_LARGE_COORD  0

/*==================
 *   FONT USAGE
 *===================*/

/*Montserrat fonts with ASCII range and some symbols using bpp = 4
 *https://fonts.google.com/specimen/Montserrat*/
#define LV_FONT_MONTSERRAT_8     0
#define LV_FONT_MONTSERRAT_10    0
#define LV_FONT_MONTSERRAT_12    0
#define LV_FONT_MONTSERRAT_14    1
#define LV_FONT_MONTSERRAT_16    0
#define LV_FONT_MONTSERRAT_18    0
#define LV_FONT_MONTSERRAT_20    0
#define LV_FONT_MONTSERRAT_22    0
#define LV_FONT_MONTSERRAT_24    0
#define LV_FONT_MONTSERRAT_26    0
#define LV_FONT_MONTSERRAT_28    0
#define LV_FONT_MONTSERRAT_30    0
#define LV_FONT_MONTSERRAT_32    0
#define LV_FONT_MONTSERRAT_34    0
#define LV_FONT_MONTSERRAT_36    0
#define LV_FONT_MONTSERRAT_38    0
#define LV_FONT_MONTSERRAT_40    0
#define LV_FONT_MONTSERRAT_42    0
#define LV_FONT_MONTSERRAT_44    0
#define LV_FONT_MONTSERRAT_46    0
#define LV_FONT_MONTSERRAT_48    0

/*Demonstrate special features*/
#define LV_FONT_MONTSERRAT_12_SUBPX      0
#define LV_FONT_MONTSERRAT_28_COMPRESSED 0  /*bpp = 3*/
#define LV_FONT_DEJAVU_16_PERSIAN_HEBREW 0  /*Hebrew, Arabic, Perisan letters and all their forms*/
#define LV_FONT_SIMSUN_16_CJK            0  /*1000 most common CJK radicals*/

/*Pixel perfect monospace fonts*/
#define LV_FONT_UNSCII_8        0
#define LV_FONT_UNSCII_16       0

/*Optionally declare custom fonts here.
 *You can use these fonts as default font too and they will be available globally.
 *E.g. #define LV_FONT_CUSTOM_DECLARE   LV_FONT_DECLARE(my_font_1) LV_FONT_DECLARE(my_font_2)*/
#define LV_FONT_CUSTOM_DECLARE

/*Always set a default font*/
#define LV_FONT_DEFAULT &lv_font_montserrat_14

/*Enable handling large font and/or fonts with a lot of characters.
 *The limit depends on the font size, font face and bpp.
 *Compiler error will be triggered if a font needs it.*/
#define LV_FONT_FMT_TXT_LARGE   0

/*Enables/disables support for compressed fonts.*/
#define LV_USE_FONT_COMPRESSED  0

/*Enable subpixel rendering*/
#define LV_USE_FONT_SUBPX       0
#if LV_USE_FONT_SUBPX
/*Set the pixel order of the display. Physical order of RGB channels. Doesn't matter with "normal" fonts.*/
#define LV_FONT_SUBPX_BGR       0  /*0: RGB; 1:BGR order*/
#endif

/*==================
 *  WIDGET USAGE
 *================*/

/*Documentation of the widgets: https://docs.lvgl.io/latest/en/html/widgets/index.html*/


#if LV_USE_LABEL
#  define LV_LABEL_TEXT_SELECTION         1   /*Enable selecting text of the label*/
#  define LV_LABEL_LONG_TXT_HINT    1   /*Store some extra info in labels to speed up drawing of very long texts*/
#endif

#if LV_USE_ROLLER
#  define LV_ROLLER_INF_PAGES       7   /*Number of extra "pages" when the roller is infinite*/
#endif

#if LV_USE_TEXTAREA != 0
#  define LV_TEXTAREA_DEF_PWD_SHOW_TIME     1500    /*ms*/
#endif

/*==================
 * EXTRA COMPONENTS
 *==================*/

/*-----------
 * Widgets
 *----------*/
#if LV_USE_CALENDAR
# define LV_CALENDAR_WEEK_STARTS_MONDAY 0
# if LV_CALENDAR_WEEK_STARTS_MONDAY
#  define LV_CALENDAR_DEFAULT_DAY_NAMES {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"}
# else
#  define LV_CALENDAR_DEFAULT_DAY_NAMES {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
# endif

# define LV_CALENDAR_DEFAULT_MONTH_NAMES {"January", "February", "March",  "April", "May",  "June", "July", "August", "September", "October", "November", "December"}
# define LV_USE_CALENDAR_HEADER_ARROW       1
# define LV_USE_CALENDAR_HEADER_DROPDOWN    1
#endif  /*LV_USE_CALENDAR*/



#if LV_USE_SPAN
/*A line text can contain maximum num of span descriptor */
#  define LV_SPAN_SNIPPET_STACK_SIZE   64
#endif


#endif /*LV_CONF_H*/

#endif /*End of "Content enable"*/
