* Sprite f4
*
*       Mode 4
*       +|-------+
*       -ggg g   -
*       |g   g g |
*       |g   g g |
*       |gg  gggg|
*       |g     g |
*       |g     g |
*       |g     g |
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
        xdef    _wm_sprite_f4
        xref    _wm_sprite_zero
_wm_sprite_f4
        dc.w    $0100,$0000
        dc.w    8,7,0,0
        dc.l    sc4_f4-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f4
        dc.w    $E800,$0000
        dc.w    $8A00,$0000
        dc.w    $8A00,$0000
        dc.w    $CF00,$0000
        dc.w    $8200,$0000
        dc.w    $8200,$0000
        dc.w    $8200,$0000
*
        end

