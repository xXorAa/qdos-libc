* Sprite left
*
*       Mode 4
*       +|---------------+
*       |      a         |
*       |    aa        aa|
*       |  aaaa      aa  |
*       -aaaaaaaaaaaa    -
*       |  aaaa      aa  |
*       |    aa        aa|
*       |      a         |
*       +|---------------+
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
        xdef    _wm_sprite_left
_wm_sprite_left
        dc.w    $0100,$0000
        dc.w    16,7,0,3
        dc.l    sc4_left-*
        dc.l    sm4_left-*
        dc.l    0
sc4_left
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0202,$0000
        dc.w    $0C0C,$0303
        dc.w    $3C3C,$0C0C
        dc.w    $FFFF,$F0F0
        dc.w    $3C3C,$0C0C
        dc.w    $0C0C,$0303
        dc.w    $0202,$0000
sm4_left
        dc.w    $0202,$0000
        dc.w    $0C0C,$0303
        dc.w    $3C3C,$0C0C
        dc.w    $FFFF,$F0F0
        dc.w    $3C3C,$0C0C
        dc.w    $0C0C,$0303
        dc.w    $0202,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
        dc.w    $0000,$0000
*
        end
