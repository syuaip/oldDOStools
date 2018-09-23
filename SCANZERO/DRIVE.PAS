(* ------------------------------------------------ *)
(*   Program Name     :  Unit Drive R1.00           *)
(*   Programmer       :  Arief Wahyu Nugraha        *)
(*                       0104.920.292 - 1.P.C.T     *)
(*                       STMIK Bina Nusantara       *)
(*   Compiler         :  Turbo Pascal 5.50          *)
(*   Program Code     :  #A04.92.10.07.11.31.$02    *)
(* ------------------------------------------------ *)

{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}

(*----------------- Unit Declaration ---------------*)

Unit Drive;

(*----------------- Interface -----------------*)

INTERFACE

Function _Harddisk : Byte;
Function _HarddiskExist : Boolean;
Function _Floppy : Byte;
Function _FloppyExist : Boolean;
Function _DefaultDrive : Byte;
Function _DriveType(Drive : Byte) : Byte;
Procedure _SetDriveType(Drive, DriveType : Byte; Var Error : Boolean);
Procedure _ResetDrive(Drive : Byte);

(*--------------- Impelementation -------------*)

IMPLEMENTATION

(*-------------- Used Unit ------------*)

Uses Dos;

(*---------- Funcs and Procs ----------*)

Function _Harddisk : Byte;
(* ----------------------------------- *)
(* Input  : -                          *)
(* Output : Byte -> Jumlah Harddisk.   *)
(* ----------------------------------- *)
begin
  _Harddisk := Mem[0:1141];
end;

Function _HarddiskExist : Boolean;
(* ----------------------------------- *)
(* Input  : -                          *)
(* Output : True -> Jika ada Harddisk. *)
(* ----------------------------------- *)
begin
  _HarddiskExist := _Harddisk > 0;
end;

Function _Floppy : Byte;
Var Reg : Registers;
Begin
  Reg.AH := $08;
  Reg.DL := $00;
  Intr($13,Reg);
  _Floppy := Reg.DL;
End;

Function _FloppyExist : Boolean;
Begin
  _FloppyExist := _Floppy > 0;
End;

Function _DefaultDrive : Byte;
(* ----------------------------------- *)
(* Input  : -                          *)
(* Output : Byte -> 0 : Drive A        *)
(*                  1 : Drive B        *)
(*                  2 : dst...         *)
(* ----------------------------------- *)
var Reg : Registers;
begin
  Reg.AH := $19;
  MsDos(Reg);
  _DefaultDrive := Reg.AL;
end;

Function _DriveType(Drive : Byte) : Byte;
(* ----------------------------------- *)
(* Input  : No.Drive di Var Drive      *)
(* Output : BL ---> 0 : Tak ada Drive  *)
(*                  1 : 360 KB 5.25"   *)
(*                  2 : 1.2 MB 5.25"   *)
(*                  3 : 720 KB 3.50"   *)
(*                  4 : 1.44MB 3.50"   *)
(*                  5 : Harddisk       *)
(* ----------------------------------- *)
var Reg : Registers;
begin
  If (Drive > 1) AND _HarddiskExist then
    _DriveType := 5
  Else
    Begin
      Reg.AH := $08;
      Reg.DL := Drive;
      Intr($13,Reg);
      _DriveType := Reg.BL;
    End;
end;

Procedure _SetDriveType(Drive, DriveType : Byte; Var Error : Boolean);
(* ----------------------------------- *)
(* Input  : No.Drive di Var Drive      *)
(*          DType ; 0 : Tak ada Drive  *)
(*                  1 : 360 KB 5.25"   *)
(*                  2 : 360 IN 1.2     *)
(*                  3 : 1.2 MB 5.25"   *)
(*                  4 : 720 KB 3.50"   *)
(* ----------------------------------- *)
var Reg : Registers;
begin
end;

Procedure _ResetDrive(Drive : Byte);
var Reg : Registers;
begin
  Reg.DL := Drive;
  If Drive > 1 then
    Reg.AH := $0D
  Else
    Reg.AH := $00;
  Intr($13,Reg);
end;

(*-------- Main Program of Unit -------*)

Begin
End.
