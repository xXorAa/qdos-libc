* Sprite arrow
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*
*       Mode 4
*       +-|---------+
*       |aa         |
*       -awa        -
*       |awwa       |
*       |awwwa      |
*       |awwwwa     |
*       |awwwwwa    |
*       |awwwwwwa   |
*       |awwwwwwwa  |
*       |awwwwwwwwa |
*       |awwwwwwwwwa|
*       |awwwwwwaaa |
*       |awwaawwa   |
*       |awa awwa   |
*       | a   awwa  |
*       |     awwa  |
*       |     aaaa  |
*       +-|---------+
*
        section text
        xdef    _wm_sprite_arrow
_wm_sprite_arrow
        dc.w    $0100,$0000
        dc.w    11,16,1,1
        dc.l    mcs_arrow-*
        dc.l    mms_arrow-*
        dc.l    0
mcs_arrow
        dc.w    $0000,$0000
        dc.w    $4040,$0000
        dc.w    $6060,$0000
        dc.w    $7070,$0000
        dc.w    $7878,$0000
        dc.w    $7C7C,$0000
        dc.w    $7E7E,$0000
        dc.w    $7F7F,$0000
        dc.w    $7F7F,$8080
        dc.w    $7F7F,$C0C0
        dc.w    $7E7E,$0000
        dc.w    $6666,$0000
        dc.w    $4646,$0000
        dc.w    $0303,$0000
        dc.w    $0303,$0000
        dc.w    $0000,$0000
mms_arrow
        dc.w    $C0C0,$0000
        dc.w    $E0E0,$0000
        dc.w    $F0F0,$0000
        dc.w    $F8F8,$0000
        dc.w    $FCFC,$0000
        dc.w    $FEFE,$0000
        dc.w    $FFFF,$0000
        dc.w    $FFFF,$8080
        dc.w    $FFFF,$C0C0
        dc.w    $FFFF,$E0E0
        dc.w    $FFFF,$C0C0
        dc.w    $FFFF,$0000
        dc.w    $EFEF,$0000
        dc.w    $4747,$8080
        dc.w    $0707,$8080
        dc.w    $0707,$8080
*
        end

