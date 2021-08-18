* Sprite cf4
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*
*       Mode 4
*       +|----------+
*       - gg ggg  g -
*       |g   g   gg |
*       |g   g  g g |
*       |g   gg g g |
*       |g   g ggggg|
*       |g   g    g |
*       | gg g    g |
*       +|----------+
*
        section text

        xdef    _wm_sprite_cf4
        xref    _wm_sprite_zero
_wm_sprite_cf4
        dc.w    $0100,$0000
        dc.w    11,7,0,0
        dc.l    sc4_cf4-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_cf4
        dc.w    $6e00,$4000
        dc.w    $8800,$c000
        dc.w    $8900,$4000
        dc.w    $8d00,$4000
        dc.w    $8b00,$e000
        dc.w    $8800,$4000
        dc.w    $6800,$4000
*
        end
