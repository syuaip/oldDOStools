(* -------------------------------------------------- *)
(*  Program Name     :  Tiny 160 R1.76                *)
(*  Program Type     :  Tools (Lister)                *)
(*  Program Code     :  #T01.931114.931114.18.$01     *)
(*  Compiler         :  Turbo Pascal 5.50             *)
(*  Programmer       :  Arief Wahyu Nugraha           *)
(*                      ZeroBit Tech. Research & Dev. *)
(* -------------------------------------------------- *)
(*  Addition in this version :                        *)
(*    - a new parameter '/FOLIO'                      *)
(* -------------------------------------------------- *)

{$DEFINE OKAY}

{$IFDEF OKAY}
  {$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
  {$M 16384,0,655360}
{$ELSE}
  {$A+,B+,D+,E+,F-,I+,L+,N+,O+,R+,S+,V+}
  {$M 65520,0,655360}
{$ENDIF}

Program Tiny176;

Uses Crt;

Function Rep(St : String; Times : Byte) : String;
Var B : String; X : Byte;
Begin
  If (Times <> 0) AND (Length(St) <> 0) then
    Begin
      B := '';
      For X := 1 to Times do B := B + St;
      Rep := B;
    End
  else
    Rep := '';
End;

Function SaveString(St : String) : String;
var C : Byte;
begin
   For C := 1 to Length(St) do
     Case St[C] of
      {#09        : St[C] := #09;} { If H-TAB then let-it-be... }
       #07        : St[C] := '0';  {      Kill Bell }
       #15        : St[C] := '=';  {      Condensed }
       #126..#255 : St[C] := '.';  {      Extended Chars }
       #12        : St[C] := '*';  {      Form-Feed }
       #13        : St[C] := '<';  {      Carriage-Return }
       #10        : St[C] := '|';  {      Line-Feed }
       #11        : St[C] := '^';  {      Vertical-TAB }
       #24        : St[C] := '#';  {      Cancel-Line }

       {... etc}

     End;
   SaveString := St;
end;

Function UpStr(St : String) : String;
var C : Byte;
begin
   For C := 1 to Length(St) do St[C] := UpCase(St[C]);
   UpStr := St;
end;

Function Decode(St : String) : String;
var C : Byte;
begin
   For C := 1 to Length(St) do St[C] := Chr(Ord(St[C])-2);
   Decode := St;
end;

Function Zero(Page : Word; Rep : Byte) : String;
Var St : String;
Begin
  Str(Page,St);
  If Rep <> 0 then While Length(St) < Rep do St := '0' + St;
  Zero := St;
End;

Procedure Quit(St : String);
Begin
  ClrEOL;
  WriteLn(St);
  Halt;
End;

Const
  Help       : Boolean = FALSE;
  Form       : Boolean = FALSE;
  Italic     : Boolean = FALSE;
  Emphasis   : Boolean = FALSE;
  FlatFF     : Boolean = FALSE;
  NOT_Ascii  : Boolean =  TRUE;
  Hold       : Boolean =  TRUE;
  Nums       : Boolean =  TRUE;
  Bar        : Word    =   135;
  LeftM      : Byte    =    12;
  Page       : Word    =     1;
  FileName   : String  =    '';
  Intrped    : String[23] = 'Interrupted by user...'#7;
Var
  Ch         : Char;
  F,
  LST        : Text;
  Prm,
  Zeroes     : Byte;
  Lines,
  X          : Word;
  St,
  Print,
  Header,
  Footer,
  BoldName,
  Parameter,
  OutStr     : String;
  Code       : Integer;

Function ParamCounter : Byte;
Var X, Y : Byte;
Begin
  X := 0;
  If (Parameter <> '') then
    Begin
      For Y := 1 to Length(Parameter) do
        If (Parameter[Y] = #32) then Inc(X);
      Inc(X);
    End;
  ParamCounter := X;
End;

Function ParamString(Idx : Byte) : String;
Var X, Y : Byte; StBuff : String;
Begin
  If (Parameter = '') OR (Idx > ParamCounter) then
    ParamString := ''
  else
    Begin
      StBuff := Parameter;
      X := 0;
      For Y := 1 to (Idx - 1) do
        Repeat
          Inc(X);
        Until StBuff[X] = #32;
      Delete(StBuff,1,X);
      X := 1;
      While StBuff[X] <> #32 do Inc(X);
      Delete(StBuff,X,Length(StBuff) - X + 1);
      ParamString := StBuff;
    End;
End;

Procedure InitParam;
Var I, J : Byte;
Begin
  Parameter := '';
  For I := 1 to ParamCount do
    Parameter := Parameter + #32 + ParamStr(I);
  If Parameter <> '' then
    Begin
      Delete(Parameter,1,1);
      Parameter := UpStr(Parameter);
      I := 1;
      While (I < Length(Parameter)) do
        Begin
          If (I <> 1) AND
             (Parameter[I] = '/') AND
             (Parameter[I-1] <> #32) then
            Insert(#32,Parameter,I);
          Inc(I);
        End;
    End
End;

Function AfterPage : String;
Var Sum : Byte;
Begin
  If (Bar < 140) AND NOT FlatFF then
    Sum := 140 - Bar + 13
  else
    Sum := 5;
  If Form then
    Begin
      If (Page MOD 3) = 0 then Inc(Sum);
      AfterPage := #13+Rep(#10,Sum);
    End
  else
    AfterPage := #12;
End;

Function Spaces : String;
Begin
  Spaces := Rep(#32,LeftM);
End;

Begin
  Print  := 'Printing...'#13;
  Header := '*** Tiny Lister R1.76 - (C)1993, '+Decode('\gtqDkv')+' TR&D ';
  Footer := '*** Better technology may lead us to better life ***';
  OutStr := 'LPT1';

  If (Mem[$40:$49] <> CO80) then TextMode(CO80); { cek layar }

  InitParam;
                                   { cek parameter }
  If (ParamCounter > 0) then
    For Prm := 1 to ParamCounter do
      Begin
        If ('/?'     = ParamString(Prm)) then Help := True;
        If ('/FF'    = ParamString(Prm)) then Form := True;
        If ('/!'     = ParamString(Prm)) then Hold := False;
        If ('/NN'    = ParamString(Prm)) then Nums := False;
        If ('/NFL'   = ParamString(Prm)) then FlatFF := True;
        If ('/I'     = ParamString(Prm)) then Italic := True;
        If ('/E'     = ParamString(Prm)) then Emphasis := True;
        If ('/A'     = ParamString(Prm)) then NOT_Ascii := False;
        If ('/FOLIO' = ParamString(Prm)) then Bar := 160;
        If (Copy(ParamString(Prm),1,3) = '/L:') then
          Begin
            Val(Copy(ParamString(Prm),4,Length(ParamString(Prm))-3),Bar,Code);
            If (Code <> 0) then Bar := 135;
            If (Bar = 0) then Bar := 65535;
          End;
        If (Copy(ParamString(Prm),1,3) = '/M:') then
          Begin
            Val(Copy(ParamString(Prm),4,Length(ParamString(Prm))-3),LeftM,Code);
            If (Code <> 0) then LeftM := 12;
          End;
        If (Copy(ParamString(Prm),1,3) = '/P:') then
          Begin
            Val(Copy(ParamString(Prm),4,Length(ParamString(Prm))-3),Page,Code);
            If (Code <> 0) OR (Page = 0) then Page := 1;
          End;
        If (Copy(ParamString(Prm),1,3) = '/O:') then
          OutStr := Copy(ParamString(Prm),4, Length(ParamString(Prm))-3);
        If (Copy(ParamString(Prm),1,1) <> '/') then
          FileName := ParamString(Prm);
      End;

  If Help then       { cetak teks petunjuk }
    Begin
      Writeln(Header + '***'#10);
      WriteLn('Syntax  : TINY [input] [/O:output] [/M:margin] [/L:line] [/P:page]');
      WriteLn('[/FF]':20,' [/NFL] [/NN] [/I] [/E] [/A] [/!] [/FOLIO] [/?]'#10);
      WriteLn('input  :':18,' file to be printed (filename.ext)');
      WriteLn('output :':18,' device to be written (default=LPT1)');
      WriteLn('margin :':18,' left margin in every page (default=12)');
      WriteLn('line   :':18,' line in every page (default=135)');
      WriteLn('page   :':18,' start page number (default=1)');
      WriteLn('FF     :':18,' print in form feed mode');
      WriteLn('NFL    :':18,' do not calculate footer length');
      WriteLn('NN     :':18,' do not print line numbers');
      WriteLn('FOLIO  :':18,' print on folio sheet');
      WriteLn('I      :':18,' print in italic style');
      WriteLn('E      :':18,' print filename in emphasis style');
      WriteLn('A      :':18,' print in the real Ascii-way');
      WriteLn('!      :':18,' print all page without stopping'#10);
      WriteLn('Example : A>TINY/FF/NN/I/A A:\TINYLIST.DOC/E /P:8/O:B:\TEMPFILE/FOLIO/!'#10);
      Quit(Decode('\gtqDkv')+' Technology R&D (TI-'+Decode('UVOKM"DP')+') -'+
           Decode('"R0Q0DQZ"48:')+', Tangerang 15'+Zero(1,3)+'.');
    End
  else
    Begin
      TextAttr := $1F;        { siapkan layar }
      ClrScr;
      InLine($b4/$0b/$b3/$01/$cd/$10);  { border BLUE }
    End;

  Writeln(Header + '***'#10);

  If FileName = '' then
    Begin
      Write('Filename and extention : ');
      ReadLn(FileName);
      WriteLn;
      If (FileName = '') then Quit(Intrped);
    End;
                 { parsing FileName untuk mengambil namafile saja }

  BoldName := UpStr(FileName);
  While (Pos('\',BoldName) > 0) OR (Pos(':',BoldName) > 0) do
    Delete(BoldName,1,1);

  If Emphasis then BoldName := #027#069+BoldName+#027#070;

  Assign(LST,OutStr);
  Assign(F,FileName);
  {$I-}
  Reset(F);
  If (IOResult <> 0) then
    Quit('Input access error...'#7)
  else
    Begin
      ReWrite(LST);
      WriteLn(LST);            { cek alat keluaran }
      If (IOResult <> 0) then
        Quit('Output access error...'#7)
      else                                  { kirim kode huruf tiny }
        Begin
          WriteLn(Lst,#027#050#002#027#120#000#027#116#001#018#020#027#087#000+
                      #027#070#027#072#027#084#027#053#027#051#015#015#027#083+
                      #000#027#077);
          If Italic then Write(Lst,#027#052);
          If Nums then                        { pakai nomor, so itung baris }
            Begin
              Write('Calculating total lines of the file...'#13);
              Lines := 0;
              While NOT EOF(F) do
                Begin
                  Inc(Lines);            { biar ketauan zeroes-nya... }
                  ReadLn(F,St);          { zeroes := trunc(log(lines))+1 }
                End;
              Reset(F);
              Str(Lines,St);
              Zeroes := Length(St);
            End;

          ClrEOL; Write(Print);

          Lines := 0;
          While NOT EOF(F) do
            Begin
              Inc(Lines);
              If ((Lines MOD Bar) = 1) then
                Begin
                  If (Lines <> 1) then
                    Begin
                      Inc(Page);
                      Writeln(Lst,#10 + Spaces + 'Continued on next page...'+
                                         AfterPage);
                      If Hold then
                        Begin
                          ClrEOL; Write('Press any key when ready...'#13);
                          Repeat
                            Ch := ReadKey
                          Until Ch <> #0;
                          If Ch = #27 then Quit(Intrped);
                          ClrEOL; Write(Print);
                        End;
                    End;
                  Writeln(Lst);
                  Writeln(Lst,Spaces + Header + '- Listing of '+BoldName+
                            ' - Page : ',Zero(Page,2),' ***'#10);
                End;

              ReadLn(F,St);
              If NOT_Ascii then St := SaveString(St);

              Write(Lst,Spaces);
              If Nums then
                Begin
                  Write(Lst,Zero(Lines,Zeroes));
                  If Italic then
                    Write(Lst,'  ')
                  else
                    Write(Lst,' | ');
                End;
              WriteLn(LST,St);
              If IOResult <> 0 then Quit('Output access error...');

            End;
          If (Lines <> 0) then
            Begin
              Writeln(Lst,#10 + Spaces + Footer + Rep(#10,10));
              If NOT Form then Write(Lst,#12);
            End;
        End;
    End;
  {$I+}
  ClrEOL; WriteLn(#13,'Done...');
End.
