* Sprite f5
*
*       Mode 4
*       +|-------+
*       -ggg gggg-
*       |g   g   |
*       |g   ggg |
*       |gg     g|
*       |g      g|
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
        xdef    _wm_sprite_f5
        xref    _wm_sprite_zero
_wm_sprite_f5
        dc.w    $0100,$0000
        dc.w    8,7,0,0
        dc.l    sc4_f5-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_f5
        dc.w    $EF00,$0000
        dc.w    $8800,$0000
        dc.w    $8E00,$0000
        dc.w    $C100,$0000
        dc.w    $8100,$0000
        dc.w    $8900,$0000
        dc.w    $8600,$0000
*
        end

