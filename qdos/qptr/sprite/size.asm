* Sprite size
*
*       Mode 4
*       +------|-----+
*       |aaaaaaaaaaaa|
*       |aaggggggggaa|
*       |aaggggggggaa|
*       -aaggaaaaaaaa-
*       |aaggaaggggaa|
*       |aaggaaggggaa|
*       |aaaaaaaaaaaa|
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
        xdef    _wm_sprite_size
        xref    _wm_sprite_zero
_wm_sprite_size
        dc.w    $0100,$0000
        dc.w    12,7,6,3
        dc.l    sc4_size-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_size
        dc.w    $FFFF,$F0F0
        dc.w    $C0FF,$30F0
        dc.w    $C0FF,$30F0
        dc.w    $CFFF,$F0F0
        dc.w    $CCFF,$30F0
        dc.w    $CCFF,$30F0
        dc.w    $FFFF,$F0F0
*
        end
