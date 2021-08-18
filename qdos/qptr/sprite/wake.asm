* Sprite sprite_wake
*
*       Mode 4
*       +------|-------+
*       |             a|
*       |            a |
*       |      a   aa  |
*       |     aa aaa   |
*       -    aaaaaa    -
*       |   aaa aa     |
*       |  aa   a      |
*       | a            |
*       |a             |
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
        xdef    _wm_sprite_wake
        xref    _wm_sprite_zero

_wm_sprite_wake
        dc.w    $0100,$0000
        dc.w    14,9,6,4
        dc.l    sc4_sprite_wake-*
        dc.l    _wm_sprite_zero-*
        dc.l    0
sc4_sprite_wake
        dc.w    $0000,$0404
        dc.w    $0000,$0808
        dc.w    $0202,$3030
        dc.w    $0606,$E0E0
        dc.w    $0F0F,$C0C0
        dc.w    $1D1D,$8080
        dc.w    $3131,$0000
        dc.w    $4040,$0000
        dc.w    $8080,$0000
*
        end
