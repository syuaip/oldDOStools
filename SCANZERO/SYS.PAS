(* ------------------------------------------------ *)
(*   Program Name     :  Unit Sys R1.03             *)
(*   Programmer       :  Arief Wahyu Nugraha        *)
(*                       0104.920.292 - 1.P.C.T     *)
(*                       STMIK Bina Nusantara       *)
(*   Compiler         :  Turbo Pascal 5.50          *)
(*   Program Code     :  #A04.93.01.17.02.31.$03    *)
(* ------------------------------------------------ *)

{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}

(*----------------- Unit Declaration ---------------*)

Unit Sys;

(*----------------- Interface -----------------*)

INTERFACE

Function _MainMemory    : Word;
Function _ExtMemAvail   : Word;
Function _ComputerType  : Byte;
Function _VGA           : Boolean;
Function _VGAMono       : Boolean;
Function _MCGA          : Boolean;
Function _MCGAMono      : Boolean;
Function _PGA           : Boolean;
Function _EGA           : Boolean;
Function _CGA           : Boolean;
Function _Mono          : Boolean;
Function _ScreenType    : Byte;
Function _BIOS          : String;
Function _LightPenExist : Boolean;
Function _MouseExist    : Boolean;
Function _MouseButton   : Byte;
Function _MCAExist      : Boolean;   { MicroChannelArchitecture ! }
Function _MathCoExist   : Boolean;
Function _IntModemExist : Boolean;
Function _DosType       : Byte;

(*--------------- Impelementation -------------*)

IMPLEMENTATION

(*-------------- Used Unit ------------*)

Uses Dos;

(*-------- Private Global Vars --------*)

Var
  ScreenByte : Byte;
  HighScreen : Boolean;

(*---------- Funcs and Procs ----------*)

Function _MainMemory : Word;
Var Reg : Registers;
Begin
  Intr($12,Reg);
  _MainMemory := Reg.AX;
End;

Function _ExtMemAvail : Word;
Var Reg : Registers;
Begin
  Reg.AH := $88;
  Intr($15,Reg);
  _ExtMemAvail := Reg.AX;
End;

Function _ComputerType : Byte;
Begin
  _ComputerType := 255 - Mem[$FFFF:$E];
End;

Function _VGA : Boolean;
Begin
  _VGA := HighScreen AND ((ScreenByte = $8) OR (ScreenByte = $5));
End;

Function _VGAMono : Boolean;
Begin
  _VGAMono := HighScreen AND (ScreenByte = $7) AND ((Mem[0:$487] AND 2) = 2);
End;

Function _MCGA : Boolean;
Begin
  _MCGA := HighScreen AND (ScreenByte = $0C);
End;

Function _MCGAMono : Boolean;
Var Ok : Boolean;
Begin
  _MCGAMono := HighScreen AND (ScreenByte = $0B);
End;

Function _PGA : Boolean;
Begin
  _PGA := HighScreen AND (ScreenByte = $6);
End;

Function _EGA : Boolean;        { Apakah EGA termasuk HighScreen ? }
Begin
  _EGA := (NOT HighScreen) AND
          (((Mem[0:$488] AND $F) = $9) OR ((Mem[0:$488] AND $F) = $3));
End;

Function _Mono : Boolean;
var Reg : Registers;
begin
  Intr($11,Reg);
  _Mono := ((Lo(Reg.AX) AND $30) = $30) OR (Mem[0:$449] = 7);
end;

Function _CGA : Boolean;
Var Reg : Registers;
Begin
  Intr($11,Reg);
  _CGA := (NOT (HighScreen AND (ScreenByte = $4)
                           AND (ScreenByte = $5)
                           AND (ScreenByte = $6)
                           AND (ScreenByte = $7)
                           AND (ScreenByte = $8)
                           AND (ScreenByte = $B)
                           AND (ScreenByte = $C)))
          AND (((Reg.AX AND $30) Shr 4) = $1) OR
              (((Reg.AX AND $30) Shr 4) = $2);
End;

Function _ScreenType : Byte;
Begin
   If _VGA           then _ScreenType := 8                 { VGA       }
     else If _VGAMono  then _ScreenType := 7               { VGA Mono  }
       else If _MCGA     then _ScreenType := 6             { MCGA      }
         else If _MCGAMono then _ScreenType := 5           { MCGA Mono }
           else If _PGA      then _ScreenType := 4         { PGA       }
             else If _EGA      then _ScreenType := 3       { EGA       }
               else If _CGA      then _ScreenType := 2     { CGA       }
                 else If _Mono     then _ScreenType := 1   { Monokrome }
                   else _ScreenType := 0;                  { Unknown   }
End;

Function _BIOS : String;
Var St : String; I :Byte;
Begin
   St := '';
   For I := 5 to 12 do St := St + Chr(Mem[$FFFF:I]);
   Insert('19',St,7);
   _BIOS := St;
End;

Function _LightPenExist : Boolean;
Var Reg : Registers;
Begin
  Reg.AH := 4;
  Intr($10,Reg);
  _LightPenExist := Reg.AH = 1;
End;

Function _MouseExist : Boolean;
Var Reg : Registers;
Begin
  Reg.AX := 0;
  Intr($33,Reg);
  _MouseExist := Reg.AX <> 0;
End;

Function _MouseButton : Byte;
Var Reg : Registers;
Begin
  Reg.AX := 0;
  Intr($33,Reg);
  _MouseButton := Reg.BX;
End;

Function _MCAExist : Boolean;
Var Reg  : Registers;
Begin
  Reg.AH := $C0;
  Intr($15,Reg);
  _MCAExist := (Mem[Reg.ES:Reg.BX+5] AND 2) <> 0;
End;

Function _MathCoExist : Boolean;
Var Reg  : Registers;
Begin
  Intr($11,Reg);
  _MathCoExist := (Reg.AX AND 2) <> 0;
End;

Function _IntModemExist : Boolean;
Var Reg  : Registers;
Begin
  Intr($11,Reg);
  _IntModemExist := (Reg.AH AND 32) <> 0;
End;

Function _DosType : Byte;
Var B : Byte;
Begin
  B := Mem[$0000:$520];
  Case B of
    77 : _DosType := 2;
    73 : _DosType := 1;
  Else _DosType := 0;
  End;
End;

Procedure Init;
Var Reg : Registers;
Begin
  Reg.AX := $1A00;
  Intr($10,Reg);
  HighScreen := Reg.AL = $1A;
  ScreenByte := Reg.BL;
End;

(*-------- Main Program of Unit -------*)

Begin
  Init;
End.