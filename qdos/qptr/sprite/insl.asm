* Sprite insl
*
*       Mode 4
*       +---|---+
*       |rrrrrrr|
*       |rrrrrrr|
*       |rrrrrrr|
*       |rrrrrrr|
*       |rrrrrrr|
*       -rrrrrrr-
*       |rrrrrrr|
*       |rrrrrrr|
*       |rrrrrrr|
*       |rrrrrrr|
*       +---|---+
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*                     - Changed section name to text
*
        section text
        xdef    _wm_sprite_insl
_wm_sprite_insl
        dc.w    $0100,$0c00             ; on for 12 ticks
        dc.w    7,10,3,5
        dc.l    sc4_insl-*
        dc.l    sm4_insl-*
        dc.l    4
        dc.w    $0100,$1800             ; off for 12 ticks
        dc.w    1,10,3,5
        dc.l    so4_insl-*
        dc.l    sm4_insl-*
        dc.l    0

sc4_insl
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000
        dc.w    $00FE,$0000

so4_insl
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000
        dc.w    $0080,$0000

sm4_insl
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
*
        end
