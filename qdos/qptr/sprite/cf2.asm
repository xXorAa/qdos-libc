* Sprite cf2
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
*       +----|-------+
*       - gg ggg  gg -
*       |g   g   g  g|
*       |g   g      g|
*       |g   gg    g |
*       |g   g    g  |
*       |g   g   g   |
*       | gg g   gggg|
*       +----|-------+
*
        section text

        xdef    _wm_sprite_cf2
        xref    _wm_sprite_zero
_wm_sprite_cf2
        dc.w    $0100,$0000
        dc.w    12,7,4,0
        dc.l    sc4_cf2-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_cf2
        dc.w    $6E00,$6000
        dc.w    $8800,$9000
        dc.w    $8800,$1000
        dc.w    $8C00,$2000
        dc.w    $8800,$4000
        dc.w    $8800,$8000
        dc.w    $6800,$F000
*
        end

