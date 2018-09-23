; Cara membuat SOUNDWAV.OBJ untuk WAV2COM.PAS :
;    a. TASM SOUNDIT
;    b. TLINK /T SOUNDIT
;    c. BINOBJ SOUNDIT.COM SOUNDWAV SOUNDIT_OBJ. <selesai>
;
; title Copyright (c) 1993 by Yo Wei Tjong
; modifikasi : mendukung SoundCard, oleh mirage:zeroBIT

IntCon    equ 20h ; 8259 interrupt control

IntMask   equ 21h ; 8259 interrupt mask
SysCount  equ 40h ; 8254 channel 0 control port
SpkCount  equ 42h ; 8254 channel 2 control port
TControl  equ 43h ; 8254 timer mode control port
Kbd       equ 60h ; 8255 port A
Kbd1      equ 61h ; 8255 port B
Spk       equ 61h ; 8255 port B

AdLibIdx  equ 388h   ; index port
AdLibReg  equ 389h   ; register port
ToAdLib   equ   0h

BufLen    equ 0FFFFh

;.286

.model Tiny    ;.model TPascal

.data          ;.code
SysOld     dd ?
KbdOld     dd ?
SpkOrAdLib db 0

Buffer label byte

.code
org 100h
command: jmp short talk
                         ;û VER_POS = 10Eh
file_id db 13,'WAVtalker/r??.??/@mikroDATA',1ah

; ------------------------------------------
; ISR 8: System timer
; ------------------------------------------
Int8  proc  far
      cli               ; disable interrupts

      mov   al,cl
      cmp   SpkOrAdLib, ToAdLib
      je    NotSpk
      out   SpkCount,al ; play sample
      jmp   short @GoOn1

NotSpk:
      mov   dx,AdLibReg
      out   dx,al ; play sample

@GoOn1:
      dec   bl
      jnz   Continue    ; divide clock by 2
      mov   bl,bh
      lodsb             ; get new sample
    ; shr   al,2    ; ini kode 286
      shr   al,1    ;   diganti dengan kode 8086
      shr   al,1
      shr   al,1    ; !!! sample div 8 ?

      inc   al          ; scale sample --> sample div 4 + 1
      mov   cl,al

      cmp   si,di       ; last sample ?
      jne   Continue
      not   ch          ; set finish flag

  Continue:
      mov   al,20h
      out   IntCon,al   ; send end of interrupt

      sti               ; enable interrupts
      iret              ; interrupt return
int8  endp

; ------------------------------------------
; ISR 9: Keyboard controller
; ------------------------------------------
int9  proc  far
      cli               ; disable interrupts

      in    al,Kbd      ; get key code
      mov   ah,al
      in    al,Kbd1
      or    al,80h
      out   Kbd1,al     ; reset output buffer
      and   al,7fh
      out   Kbd1,al

      mov   al,20h
      out   IntCon,al   ; send end of interrupt

      test  ah,ah       ; was it key released ?
      js    short Yes
      not   ch          ; set finish flag

  Yes:
      sti               ; enable interrupts
      iret              ; interrupt return
int9  endp

; ------------------------------------------
; SoundIt: plays samples in the buffer
; ------------------------------------------
;SoundIt proc near Buffer:word, BufStart:word, BufLen:word
                     ; public SoundIt
talk:
      mov   ax,3508h
      int   21h                     ; get system timer ISR
      mov   word ptr cs:[SysOld],bx ; and save it
      mov   word ptr cs:[SysOld+2],es

      cmp   SpkOrAdLib, ToAdLib
      jne   s01
      call  InitAdLib

s01:
      mov   al,09h
      int   21h                     ; get keyboard ISR
      mov   word ptr cs:[KbdOld],bx ; and save it
      mov   word ptr cs:[KbdOld+2],es

      in    al,IntMask
      or    al,3        ; mask interrupt from system timer
      out   IntMask,al  ; and keyboard

      push  ds
      push  cs
      pop   ds
      mov   dx,offset Int8
      mov   ax,2508h
      int   21h             ; set new system timer ISR
      mov   dx,offset Int9
      mov   al,09h
      int   21h             ; set new keyboard ISR

      mov   si, offset Buffer  ;[BufStart] ;init start index
    ; add   si,[Buffer]
      mov   di,BufLen       ; <-- LEN_WORD_POS = 01ACh
      dec   di
      add   di,si           ; init end index
      cld                   ; move  forward
      xor   ch,ch           ; reset finish flag
      mov   bx,0202h        ; set clock divider = 2
    ; mov   ds,[Buffer+2]   ; get sample segment

      mov   ax,34h      ; channel 0 (system timer) set to
      out   TControl,al ; rate generator mode with new freq
      mov   al,36h
      out   SysCount,al
      mov   al,ah
      out   SysCount,al ; set frequency to 22 KHz

      mov   al,90h      ; channel 2 (speaker) set to
      out   TControl,al ; interrupt-on terminal count mode
      in    al,Spk
      or    al,3
      out   Spk,al      ; gate channel 2 and enable speaker

      in    al,IntMask
      and   al,0FCh     ; enable interrupt from system timer
      out   IntMask,al  ; and keyboard

  Loc_loop:
      or    ch,ch
      jz    Loc_loop    ; loop until finish

      cli               ; disable interrupts
      in    al,IntMask
      or    al,3        ; mask interrupt from system timer
      out   IntMask,al  ; and keyboard
      sti               ; enable interrupts

      in    al,Spk
      and   al,0FCh
      out   Spk,al      ; stop gating ch2, disable speaker
      mov   al,0B6h     ; channel 2 (speaker) set to
      out   TControl,al ; square-wave rate generator mode
      mov   ax,533h
      out   SpkCount,al
      mov   al,ah
      out   spkCount,al ; set frequency to 894 Hz

      mov   ax,34h      ; channel 0 (system timer) set to
      out   TControl,al ; rate generator mode with new freq
      mov   al,ah
      out   SysCount,al
      out   SysCount,al ; set frequency to 18.2 Hz

      lds   dx,dword ptr cs:[SysOld]
      mov   ax,2508h               ; get old system timer ISR
      int   21h                    ; and restore it
      lds   dx,dword ptr cs:[KbdOld]
      mov   al,09h                    ; get old keyboard ISR
      int   21h                       ; and restore it
      pop   ds

      in    al,IntMask
      and   al,0FCh     ; enable interrupt from system timer
      out   IntMask,al  ; and keyboard
      ret

InitAdLib proc near
      mov   al, 000h
      mov   bl, 000h
      call  AdLib
      mov   al, 020h
      mov   bl, 021h
      call  AdLib
      mov   al, 060h
      mov   bl, 0F0h    ; attack = 15, decay = 0
      call  AdLib
      mov   al, 080h
      mov   bl, 0F0h    ; sustain = 15, release = 0
      call  AdLib
      mov   al, 0C0h
      mov   bl, 001h
      call  AdLib
      mov   al, 0E0h
      mov   bl, 000h    ; waveform =  sinusodial
      call  AdLib
      mov   al, 043h
      mov   bl, 03Fh    ; operator  =  4, level = 63
      call  AdLib
      mov   al, 0B0h
      mov   bl, 001h
      call  AdLib
      mov   al, 0A0h
      mov   bl, 08Fh
      call  AdLib
      mov   al, 0B0h
      mov   bl, 02Eh
      call  AdLib
      mov   al, 0B0h
      mov   bl, 020h
      call  AdLib
      mov   al, 0A0h
      mov   bl, 000h
      call  AdLib

      mov   dx, AdlibIdx
      mov   al, 40h
      out   dx, al

      ret

InitAdLib   endp

AdLib proc  near
      mov   dx, AdLibIdx ; index port
      out   dx, al       ; set index

    REPT 6              ; for delay sake only to
      in    al, dx      ; make sure to give time
    ENDM                ; to hardware to respond

      inc   dx          ; register  port
      mov   al,  bl
      out   dx, al      ; set value of register

      dec   dx

    REPT 35
      in    al, dx
    ENDM

      ret
AdLib endp

      ends
      end command
