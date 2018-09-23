(* -------------------------------------------------- *)
(*  Program Name     :  CLEANDRIVE R0.01              *)
(*  Program Type     :  Tools                         *)
(*  Program Code     :  #T45.921012.931121.22.$02     *)
(*  Compiler         :  Turbo Pascal 5.50             *)
(*  Programmer       :  Arief Wahyu Nugraha           *)
(*                      ZeroBit Tech. Research & Dev. *)
(* -------------------------------------------------- *)

{$DEFINE OKAY}

{$IFDEF OKAY}
  {$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
  {$M 16384,0,655360}
{$ELSE}
  {$A+,B+,D+,E+,F-,I+,L+,N+,O+,R+,S+,V+}
  {$M 65520,0,655360}
{$ENDIF}

Program CleanDrive;

Uses Dos;

Procedure Reset_Drive(Drive : Byte);
Var Reg : Registers;
Begin
   Reg.AH := 0;
   Reg.DL := Drive;
   Intr($13,Reg);
End;

Procedure Disk(Drive,Track,Side,Sec:Byte; Var Err : Byte);
Var Reg : Registers;
Begin
   With Reg do
   Begin
      AX := $0401;
      CH := Track;
      CL := Sec;
      DH := Side;
      DL := Drive;
   End;
   Intr($13,Reg);
   Err := Reg.AH;
End;

Procedure Error(St : String);
Begin
  WriteLn(#13+St);
  Halt(0);
End;

Procedure SoundEFX;
Var D1, D2 : Word;
Begin
  For D1 := 0 to 3 do For D2 := 0 to 65535 do ;
End;

Var
   DrvStr    : String[3];
   DrvChr    : Char;
   Err,
   Drv,
   Trc,
   Sec,
   Sd,
   X         : Byte;

Begin
   WriteLn('CLEAN R1.0 þ Disk Drive Head Cleaner');
{   WriteLn('(C)1992, ZeroBit PC Software Development');}
   WriteLn('(C)1992-1993, ZeroBit Technology R & D');
   WriteLn;
   Randomize;
   If ParamCount <> 1 then
     Error('Syntax : CLEAN [drive:] <enter>')
   Else
     Begin
       DrvStr := ParamStr(1);
       DrvChr := UpCase(DrvStr[1]);
       Drv    := Ord(DrvChr)-65;
       If (NOT (Drv IN [0,1])) OR (Length(DrvStr) > 2) then
         Error('Drive must be A: or B: !');
       Trc := Random(40);
       Sd  := Random(2);
       WriteLn('Insert cleaning disk on drive ',DrvChr,':');
       Write('Press ENTER when ready...');
       ReadLn;
       WriteLn;
       Reset_Drive(Drv);
       WriteLn('Cleaning in progress. Access track ',Trc,', side ',Sd,'.');
       Write(#10'<start>.........<end>');
       Write(#13'<START>');
       InLine($b4/1/$b5/32/$b1/32/$cd/$10);
       For X := 1 to 9 do
         Begin
           Disk(Drv,Trc,Sd,Sec,Err);
           Write(#231#8);
           SoundEFX;
           If Err In[151,152] then
             Begin
               WriteLn;
               Error('Disk drive error...'#7);
             End;
           Write('.');
         End;
       WriteLn('<END>');
       InLine($b4/1/$b5/0/$b1/9/$cd/$10);
     End;
   WriteLn;
End.