(* ------------------------------------------------ *)
(*   Program Name     :  Directory R1.40            *)
(*   Programmer       :  Arief Wahyu Nugraha        *)
(*                       ZeroBit Tech. R & D        *)
(*                       SMA Negeri 2 Tangerang     *)
(*   Compiler         :  Turbo Pascal 5.50          *)
(*   Program Code     :  #A01.931205.931205.19.$01  *)
(* ------------------------------------------------ *)
(*             Modification in MONTH                *)
(* ------------------------------------------------ *)

Program Directory14;

Uses Dos;

Type
  FileName     = String[12];
  cFile        = File of Char;

Const
  ExtName      : Array[1..3] of String[4] =
                 ('.COM','.EXE','.BAT');
  MonthStr     : Array[1..12] of String[3] =
                 ('Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec');

Function Attribute(Arg : Byte) : String;
Var S : String[4];
Begin                  {SHRA}
  S[0] := #4;
  If (Arg AND SysFile ) <> 0 then S[1] := 'S' else S[1] := 'ú';
  If (Arg AND Hidden  ) <> 0 then S[2] := 'H' else S[2] := 'ú';
  If (Arg AND ReadOnly) <> 0 then S[3] := 'R' else S[3] := 'ú';
  If (Arg AND Archive ) <> 0 then S[4] := 'A' else S[4] := 'ú';
  Attribute := S;
End;

Function LZ(W : Word) : String; { Leading Zero }
Var S : String;
Begin
  Str(W:0,S);
  If Length(S) = 1 then S := '0' + S;
  LZ := S;
End;

Procedure WriteHelp;
Begin
  WriteLn(#10'File lister,  Syntax : DIRZ [path][filename.ext]');
  WriteLn(   'File locator, Syntax : DIRZ [filename][COM|EXE|BAT] /!'#10);
  WriteLn('As a file locator, DIRZ will search the file according to PATH environment');
  WriTeln('variable, and if PATH environment variable is empty, DIRZ will refuse to work.');
  Halt(0);
End;

Var I : Integer;

Procedure Scan(Par : String);
Var
  S            : PathStr;
  F            : cFile;
  Target       : FileName;
  Dir          : SearchRec;
  DT           : DateTime;
  B,
  SAttr        : Word;
  L            : Longint;

Begin
  S := FSearch(Par,GetEnv('PATH'));
  If S <> '' then
    Begin
      S := FExpand(S);
      {$I-}
      Assign(F,S);
      GetFAttr(F,SAttr);
      SetFAttr(F,Archive);
      Reset(F);
      Close(F);
      Reset(F);
      {$I+}
      If IOResult = 0 then
        Begin
          Inc(I);
          GetFTime(F,L);
          UnPackTime(L,DT);
          GetFAttr(F,B);
          With DT do
            WriteLn(S,', ',FileSize(F),', ',Attribute(B),
               ', [',LZ(Day),' ',MonthStr[Month],' ',LZ(Year),', ',
                     LZ(Hour),':',LZ(Min),']');
        End
      else
        Write('Check your hardware because ');
      SetFAttr(F,SAttr);
    End;
End;

Var
  F            : cFile;
  Target       : FileName;
  Dir          : SearchRec;
  P,
  D            : DirStr;
  N            : NameStr;
  E            : ExtStr;
  Help,
  One          : Boolean;
  DT           : DateTime;
  SAttr,
  B            : Word;
  Boo          : Byte;

Begin
  I := 0; One := False; Help := False;
  If ParamStr(1) <> '' then
    Begin
      Help := (ParamStr(1) = '/?') OR (ParamStr(2) = '/?');
      P := ParamStr(1);
      FSplit(P,D,N,E);
      If N = '' then N := '*';
      P := D + N + E;
      One := NOT (ParamStr(2) = '/!');
      If (NOT One) AND (E = '') then E := '.*';
    End
  Else P := '*.*';
  WriteLn;
  WriteLn('Directory R1.30 - (C)1993, ZeroBit TR&D');
  If Help then WriteHelp;
  Write('Processing [',P,']. Working as file ');
  If One then
    WriteLn('locator. Please wait...'#10)
  else
    WriteLn('lister.');
  If NOT One then
    Begin
      FindFirst(P, AnyFile, Dir);
        Repeat
          Target := Dir.Name;
          If ((Dir.Attr AND VolumeID) <> 0) then
            Begin
              FSplit(Target,D,N,E);
              Delete(E,1,1);
              Target := D + N + E;
            End;
          If DosError = 0 then
            Begin
              Write(Target);
              If Length(Target) < 8 then Write(#9#9)
                Else Write(#9);
              Write(#32);
              If ((Dir.Attr AND VolumeID) <> 0) then
                  Write('Label    ');
              If ((Dir.Attr AND Directory) <> 0) then
                  Write('<DIR>    ');
              If ((Dir.Attr AND Archive) <> 0) then
                  Write('Archive  ');
              If ((Dir.Attr AND ReadOnly) <> 0) then
                  Write('ReadOnly ');
              If ((Dir.Attr AND Hidden) <> 0) then
                  Write('Hidden   ');
              If ((Dir.Attr AND SysFile) <> 0) then
                  Write('System   ');
              Inc(I);
            End;
          WriteLn;
          FindNext(Dir);
        Until DosError <> 0;
      End
    Else
      Begin
        If (GetEnv('PATH') = '') then WriteHelp;
        If (E = '') then
          For Boo := 1 to 3 do
            Scan(P+ExtName[Boo])
          else
            Scan(P);
      End;
    If I = 0 then WriteLn('No files found...')
      else WriteLn(#13#10,I,' object(s) found...');
End.
