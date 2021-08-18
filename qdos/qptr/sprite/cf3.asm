* Sprite cf3
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*                     - Changed section name to text
*
*       Mode 4
*       +|----------+
*       - gg ggg gg -
*       |g   g  g  g|
*       |g   g     g|
*       |g   gg  gg |
*       |g   g     g|
*       |g   g  g  g|
*       | gg g   gg |
*       +|----------+
*
        section text

        xdef    _wm_sprite_cf3
        xref    _wm_sprite_zero
_wm_sprite_cf3
        dc.w    $0100,$0000
        dc.w    11,7,0,0
        dc.l    sc4_cf3-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_cf3
        dc.w    $6e00,$c000
        dc.w    $8900,$2000
        dc.w    $8800,$2000
        dc.w    $8c00,$c000
        dc.w    $8800,$2000
        dc.w    $8900,$2000
        dc.w    $6800,$c000
*
        end
