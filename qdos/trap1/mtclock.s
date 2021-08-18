;
;   FILE:   mt_clock
;
;   m t _ a c l c k  /  s m s _ a r t c
;   m t _ r c l c k  /  s m s _ r r t c
;   m t _ s c l c k  /  s m s _ s r t c
;   m t _ f r e e    /  s m s _ f r t p
;
; QDOS routines to alter, read and set clock time
; (plus one for free space as compatible parameters)
;
; equal to X routines
;
;   time_t mt_aclck( time_t adj_time )
;   time_t mt_sclck( time_t ql_time )
;   time_t mt_rclck ()
;   long   mt_free ()
;
; AMENDMENT HISTORY
; ~~~~~~~~~~~~~~~~~
;   20 Jul 93   DJW   - Added SMS name as additional entry point
;   27 Jul 93   DJW   - Single file contains all code previously in the
;                       files doclock_s, mtaclck_s, mtrclcks_s and mtsclck_s.
;   30 Jul 93   DJW   - Added mt_free() as compatible entry point
;
;   06 Nov 93   DJW   - Added underscore to entry point names
;
;   24 Jan 94   DJW   - Added (yet another) underscore to entry point names
;                       for name hiding purposes

    .text
    .even

    .globl __mt_rclck         ; QDOS name for call
    .globl __sms_rrtc         ; SMS name for call
__mt_rclck:
__sms_rrtc:
    moveq   #$13,d0         ; set trap value code
    bra     shared

    .globl __mt_sclck         ; QDOS name for call
    .globl __sms_srtc         ; SMS name for call
__mt_sclck:
__sms_srtc:
    moveq   #$14,d0         ; set trap value code
    bra     shared

    .globl __mt_aclck         ; QDOS name for call
    .globl __sms_atrc         ; SMS name for call
__mt_aclck:
__sms_atrc:
    moveq   #$15,d0         ; set trap value code
    bra     shared

    .globl __mt_free
    .globl __sms_frtp
__mt_free:
__sms_frtp:
    moveq   #6,d0

SAVEREG equ 16+4             ; size of saved registers _ return daddress

shared:
    movem.l d2/d3/a2/a3,-(a7)   ; save potential register variables
    move.l  0+SAVEREG(a7),d1    ; set parameter
    trap    #1                  ; do required call
    move.l  d1,d0               ; set return value
    movem.l (a7)+,d2/d3/a2/a3    ; restore saved registers
    rts

