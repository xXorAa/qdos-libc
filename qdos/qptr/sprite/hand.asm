* Sprite hand
*
*       Mode 4
*       +----|----------+
*       |    aa         |
*       -   awwa        -
*       |   awwa        |
*       |   awwaaa      |
*       | a awwawwaaa   |
*       |awaawwawwawwaa |
*       |awwawwawwawwawa|
*       |awwawwawwawwawa|
*       |awwawwwwwwwwwwa|
*       |awwwwwwwwwwwwwa|
*       | awwwwwwwwwwwwa|
*       | awwwwwwwwwwwa |
*       |  awwwwwwwwwa  |
*       +----|----------+
*
* AMENDMENT HISTORY
* ~~~~~~~~~~~~~~~~~
*   First Version       Tony Tebby
*
*   01 Nov 93   DJW   - Added underscore to Entry point name
*                     - Changed entry point name (replacing mes by sprite)
*                     - Changed section name to text
*
        section sprite
        xdef    _wm_sprite_hand
_wm_sprite_hand
        dc.w    $0100,$0000
        dc.w    15,13,4,1
        dc.l    sc4_hand-*
        dc.l    sm4_hand-*
        dc.l    0
sc4_hand
        dc.w    $0000,$0000
        dc.w    $0C0C,$0000
        dc.w    $0C0C,$0000
        dc.w    $0C0C,$0000
        dc.w    $0D0D,$8080
        dc.w    $4D4D,$B0B0
        dc.w    $6D6D,$B4B4
        dc.w    $6D6D,$B4B4
        dc.w    $6F6F,$FCFC
        dc.w    $7F7F,$FCFC
        dc.w    $3F3F,$FCFC
        dc.w    $3F3F,$F8F8
        dc.w    $1F1F,$F0F0
sm4_hand
        dc.w    $0C0C,$0000
        dc.w    $1E1E,$0000
        dc.w    $1E1E,$0000
        dc.w    $1F1F,$8080
        dc.w    $5F5F,$F0F0
        dc.w    $FFFF,$FCFC
        dc.w    $FFFF,$FEFE
        dc.w    $FFFF,$FEFE
        dc.w    $FFFF,$FEFE
        dc.w    $FFFF,$FEFE
        dc.w    $7F7F,$FEFE
        dc.w    $7F7F,$FCFC
        dc.w    $3F3F,$F8F8
*
        end
