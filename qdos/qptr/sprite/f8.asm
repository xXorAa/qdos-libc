* Sprite f8
*
*       Mode 4
*       +|-------+
*       -ggg  gg -
*       |g   g  g|
*       |g   g  g|
*       |gg   gg |
*       |g   g  g|
*       |g   g  g|
*       |g    gg |
*       +|-------+
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
        xdef    _wm_sprite_f8
        xref    _wm_sprite_zero
_wm_sprite_f8
        dc.w    $0100,$0000
        dc.w    8,7,0,0
        dc.l    sc4_f8-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f8
        dc.w    $E600,$0000
        dc.w    $8900,$0000
        dc.w    $8900,$0000
        dc.w    $C600,$0000
        dc.w    $8900,$0000
        dc.w    $8900,$0000
        dc.w    $8600,$0000
*
        end
