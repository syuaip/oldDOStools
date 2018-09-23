(* ------------------------------------------------ *)
(*   Program Name     :  Unit String Change R1.00   *)
(*   Programmer       :  Arief Wahyu Nugraha        *)
(*                       ZeroBit Soft. Development  *)
(*                       STMIK Bina Nusantara       *)
(*   Compiler         :  Turbo Pascal 5.50          *)
(*   Program Code     :  #A09.92.10.20.06.31a.$03   *)
(* ------------------------------------------------ *)

{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}

(*----------------- Unit Declaration ---------------*)

Unit StrChg;

(*----------------- Interface -----------------*)

INTERFACE

Function _UpStr      (St : String) : String;
Function _DownStr    (St : String) : String;
Function _Encrypt    (St : String) : String;
Function _Decrypt    (St : String) : String;
Function _Decode     (St : String) : String;
Function _Backward   (St : String) : String;
Function _Trim       (St : String) : String;
Function _WideString (X : Byte; St : String) : String;
Function _ZeroString (X : String; N : Byte)  : String;
Function _ZeroByte   (X,          N : Byte)  : String;
Function _ZeroWord   (X : Word;   N : Byte)  : String;
Function _Rep        (St : String; X : Byte) : String;

(*--------------- Impelementation -------------*)

IMPLEMENTATION

(*---------- Funcs and Procs ----------*)

Function _UpStr(St : String) : String;
var C : Byte;
begin
   For C := 0 to Length(St) do St[C] := UpCase(St[C]);
   _UpStr := St;
end;

Function _DownStr(St : String) : String;
var C : Byte;
begin
   For C := 0 to Length(St) do
     If St[C] IN['A'..'Z'] then St[C] := Chr(Ord(St[C]) - $20);
   _DownStr := St;
end;

Function _Encrypt(St : String) : String;
var C : Byte;
begin
   for C := 1 to Length(St) do
     if ((Ord(St[C]) > (255-8))) then
        St[C] := Chr((Ord(St[C]) - $F8))
     else
        St[C] := Chr(Ord(St[C])+8);
   _Encrypt := St;
end;

Function _Decrypt(St : String) : String;
var C : Byte;
begin
   for C := 1 to Length(St) do
     if ((Ord(St[C]) < 8)) then
        St[C] := Chr((Ord(St[C]) + $F8))
     else
        St[C]:= Chr(Ord(St[C])-8);
   _Decrypt := St;
end;

Function _Decode(St : String) : String;
var C : Byte;
begin
   for C := 1 to Length(St) do St[C] := Chr(255-Ord(St[C]));
   _Decode := St;
end;

Function _Backward(St : String) : String;
Var C : Byte; T : String;
Begin
  T[0] := Chr(Length(St));
  For C := 1 to Length(St) do T[C] := St[Length(St)+1-C];
  _Backward := T;
End;

Function _Trim(St : String) : String;
Begin
  Repeat
    If St[1] = #32 then Delete(St,1,1);
  Until St[1] <> #32;
  Repeat
    If St[Length(St)] = #32 then Delete(St,Length(St),1);
  Until St[Length(St)] <> #32;
  _Trim := St;
End;

Function _WideString(X : Byte; St : String) : String;
Begin
   While Length(St) < X do St := ' '+St+' ';
   _WideString := St;
End;

Function _ZeroString (X : String; N : Byte) : String;
Begin
  While (Length(X) < N) do X := '0' + X;
  _ZeroString := X;
End;

Function _ZeroByte (X, N : Byte) : String;
Var S : String;
Begin
  Str(X,S);
  _ZeroByte := _ZeroString(S,N);
End;

Function _ZeroWord (X : Word; N : Byte) : String;
Var S : String;
Begin
   Str(X,S);
  _ZeroWord := _ZeroString(S,N);
End;

Function _Rep (St : String; X : Byte) : String;
Var
  T : String;
  I : Byte;
Begin
  T := '';
  If (X > 0) then
    For I := 1 to X do If (Length(T+St) < 255) then T := T + St;
  _Rep := T;
End;


(*-------- Main Program of Unit -------*)

Begin
End.