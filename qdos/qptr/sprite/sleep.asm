* Sprite ssleep
*
*       Mode 4
*       +------|-------+
*       |aaaaaa        |
*       |   aa         |
*       |  aa  aaaa    |
*       - aa     a     -
*       |aaaaaa a   aaa|
*       |      aaaa  a |
*       |           aaa|
*       +------|-------+
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
        xdef    _wm_sprite_sleep
        xref    _wm_sprite_zero
_wm_sprite_sleep
        dc.w    $0100,$0000
        dc.w    14,7,6,3
        dc.l    sc4_slep-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_slep
        dc.w    $FCFC,$0000
        dc.w    $1818,$0000
        dc.w    $3333,$C0C0
        dc.w    $6060,$8080
        dc.w    $FDFD,$1C1C
        dc.w    $0303,$C8C8
        dc.w    $0000,$1C1C
*
        end
