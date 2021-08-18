* Sprite move
*
*       Mode 4
*       +------|-----+
*       |aaaaaaaa    |
*       |aaggggaa    |
*       |aaggggaa    |
*       |aaggaaaaaaaa|
*       -aaaaaaaaggaa-
*       |    aaggggaa|
*       |    aaggggaa|
*       |    aaaaaaaa|
*       +------|-----+
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
        xdef    _wm_sprite_move
        xref    _wm_sprite_zero

_wm_sprite_move
        dc.w    $0100,$0000
        dc.w    12,8,6,4
        dc.l    sc4_move-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_move
        dc.w    $FFFF,$0000
        dc.w    $C3FF,$0000
        dc.w    $C3FF,$0000
        dc.w    $CFFF,$F0F0
        dc.w    $FFFF,$30F0
        dc.w    $0C0F,$30F0
        dc.w    $0C0F,$30F0
        dc.w    $0F0F,$F0F0
*
        end
