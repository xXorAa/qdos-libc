* Sprite insg
*
*       Mode 4
*       +---|---+
*       |ggggggg|
*       |ggggggg|
*       |ggggggg|
*       |ggggggg|
*       |ggggggg|
*       -ggggggg-
*       |ggggggg|
*       |ggggggg|
*       |ggggggg|
*       |ggggggg|
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
        xdef    _wm_sprite_insg
_wm_sprite_insg
        dc.w    $0100,$0c00             ; on for 12 ticks
        dc.w    7,10,3,5
        dc.l    sc4_insg-*
        dc.l    sm4_insg-*
        dc.l    4
        dc.w    $0100,$1800             ; off for 12 ticks
        dc.w    1,10,3,5
        dc.l    so4_insg-*
        dc.l    sm4_insg-*
        dc.l    0

sc4_insg
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000
        dc.w    $fe00,$0000

so4_insg
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000
        dc.w    $8000,$0000

sm4_insg
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
