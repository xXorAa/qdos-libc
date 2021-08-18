;
;   s p r i t e _ z e r o   /   s p r i t e _ b u l l
;
;   Sprite Zero Mask
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   First Version       Tony Tebby
;
;   01 Nov 93   DJW   - Added underscore to Entry point name
;                     - Changed entry point name (replacing mes by sprite)

        section text
        xdef    _wm_sprite_zero
        xdef    _wm_sprite_null

_wm_sprite_null
        dc.w    $0100,$0000
        dc.w    1,1,0,0
        dc.l    _wm_sprite_zero-*
        dc.l    _wm_sprite_zero-*
_wm_sprite_zero
        dcb.w   20,0
        end
