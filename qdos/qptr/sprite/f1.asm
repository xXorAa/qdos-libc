* Sprite f1
*
*       Mode 4
*       +|------+
*       -ggg  g -
*       |g   gg |
*       |g    g |
*       |gg   g |
*       |g    g |
*       |g    g |
*       |g   ggg|
*       +|------+
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
        xdef    _wm_sprite_f1
        xref    _wm_sprite_zero
_wm_sprite_f1
        dc.w    $0100,$0000
        dc.w    7,7,0,0
        dc.l    sc4_f1-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f1
        dc.w    $E400,$0000
        dc.w    $8C00,$0000
        dc.w    $8400,$0000
        dc.w    $C400,$0000
        dc.w    $8400,$0000
        dc.w    $8400,$0000
        dc.w    $8E00,$0000
*
        end
