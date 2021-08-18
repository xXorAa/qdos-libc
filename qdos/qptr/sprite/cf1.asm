* Sprite cf1
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
*       |g   g    g |
*       |g   gg   g |
*       |g   g    g |
*       |g   g    g |
*       | gg g   ggg|
*       +|----------+
*
        section text

        xdef    _wm_sprite_cf1
        xref    _wm_sprite_zero
_wm_sprite_cf1
        dc.w    $0100,$0000
        dc.w    11,7,0,0
        dc.l    sc4_cf1-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_cf1
        dc.w    $6E00,$4000
        dc.w    $8800,$C000
        dc.w    $8800,$4000
        dc.w    $8C00,$4000
        dc.w    $8800,$4000
        dc.w    $8800,$4000
        dc.w    $6800,$E000
*
        end

