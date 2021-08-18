* Sprite f3
*
*       Mode 4
*       +|------+
*       -ggg gg -
*       |g  g  g|
*       |g     g|
*       |gg  gg |
*       |g     g|
*       |g  g  g|
*       |g   gg |
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
        xdef    _wm_sprite_f3
        xref    _wm_sprite_zero
_wm_sprite_f3
        dc.w    $0100,$0000
        dc.w    7,7,0,0
        dc.l    sc4_f3-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f3
        dc.w    $EC00,$0000
        dc.w    $9200,$0000
        dc.w    $8200,$0000
        dc.w    $CC00,$0000
        dc.w    $8200,$0000
        dc.w    $9200,$0000
        dc.w    $8C00,$0000
*
        end

