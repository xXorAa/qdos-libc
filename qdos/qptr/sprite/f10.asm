* Sprite f10
*
*       Mode 4
*       +|----------+
*       -ggg  g   g -
*       |g   gg  g g|
*       |g    g  g g|
*       |gg   g  g g|
*       |g    g  g g|
*       |g    g  g g|
*       |g   ggg  g |
*       +|----------+
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*                     - Changed section name to text
*
        SECTION text
        xdef    _wm_sprite_f10
        xref    _wm_sprite_zero
_wm_sprite_f10
        dc.w    $0100,$0000
        dc.w    11,7,0,0
        dc.l    sc4_f10-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f10
        dc.w    $E400,$4000
        dc.w    $8C00,$A000
        dc.w    $8400,$A000
        dc.w    $C400,$A000
        dc.w    $8400,$A000
        dc.w    $8400,$A000
        dc.w    $8E00,$4000
*
        END

