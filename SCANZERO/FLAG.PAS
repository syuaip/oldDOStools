(*
   UNIT FLAG
   Rewrite in Dec 11st, 92
*)

{$B-,I-,R-,F-,A+,D-,L-,V-,N-,E-,S+}

Unit Flag;

INTERFACE

Function _CarryF      : Boolean;
Function _ParityF     : Boolean;
Function _AuxF        : Boolean;
Function _ZeroF       : Boolean;
Function _SignF       : Boolean;
Function _TrapF       : Boolean;
Function _IntrEnableF : Boolean;
Function _DirAscF     : Boolean;
Function _OverflowF   : Boolean;
Procedure _ResetFlags;

IMPLEMENTATION

Uses Dos;

Var Reg : Registers;

Function _CarryF      : Boolean;
Begin
  _CarryF := (Reg.FLAGS AND 1) <> 0;
End;

Function _ParityF     : Boolean;
Begin
  _ParityF := (Reg.FLAGS AND 4) <> 0;
End;

Function _AuxF        : Boolean;
Begin
  _AuxF := (Reg.FLAGS AND 16) <> 0;
End;

Function _ZeroF       : Boolean;
Begin
  _ZeroF := (Reg.FLAGS AND 64) <> 0;
End;

Function _SignF       : Boolean;
Begin
  _SignF := (Reg.FLAGS AND 128) <> 0;
End;

Function _TrapF       : Boolean;
Begin
  _TrapF := (Reg.FLAGS AND 256) <> 0;
End;

Function _IntrEnableF : Boolean;
Begin
  _IntrEnableF := (Reg.FLAGS AND 512) <> 0;
End;

Function _DirAscF     : Boolean;
Begin
  _DirAscF := (Reg.FLAGS AND 1024) <> 0;
End;

Function _OverflowF   : Boolean;
Begin
  _OverflowF := (Reg.FLAGS AND 2048) <> 0;
End;

Procedure _ResetFlags;
Begin
  Reg.FLAGS := 0;
End;

END.