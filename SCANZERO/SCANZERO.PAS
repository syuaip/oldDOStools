(* ------------------------------------------------------ *)
(*   Program Name     : Universal Anti Boot Virus R2.10   *)
(*   Programmer       : Arief Wahyu Nugraha               *)
(*                      0104.920.292 - 1.P.C.T            *)
(*                      STMIK Bina Nusantara              *)
(*   Compiler         : Turbo Pascal 5.50                 *)
(*   Program Code     : #P1.BN.921019.930209.17.$49       *)
(* ------------------------------------------------------ *)
(*           ANTI VIRUS VERSI PUBLIK (SHAREWARE)          *)
(* ------------------------------------------------------ *)

{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}

Program ScanZero21;

Uses Crt, Dos, StrChg, Sys, Drive, Flag, WinZero;

{$I KEYS.INC}

Const
   MenuAttr       : Byte    = 16*Blue+White;
   BarAttr        : Byte    = 16*Brown;
   Chg            : Boolean = True;
   HelpOn         : Boolean = False;
   InfoOn         : Boolean = False;
   AboutOn        : Boolean = False;
   DriveOn        : Boolean = False;
   DelayFX        : Boolean = True;
   Bar            : Boolean = True;
   BackGround     : Boolean = False;
   VirusIsExist   : Boolean = False;
   VirusWiped     : Boolean = False;
   MaxMenu        = 3;
   Try            = 5;                  { Try access max. 5 times }
   Menu           : Byte = 1;
   CapCtr         : Byte = 1;
   DrvCtr         : Byte = 0;
   Tag            : Array[1..MaxMenu] of String[19] =
                    (  #16'      Drive      '#17,
                       #16'      Scan       '#17,
                       #16'      Quit!      '#17   );
   Status         : Array[1..MaxMenu] of Boolean = (False,False,False);

Type
   Buffer         = Array[0..511] of Byte;
   Diskette       = (DoubleDensity, HighDensity, QuadDensity, UnKnown);

Const
   BootRecord33   : Buffer = { PCDOS 3.30 }
                    (
                      235,052,$90,$49,$42,$4D,$20,$33,
                      046,$33,$30,000,002,002,001,000,
                      002,112,000,072,003,253,002,000,
                      010,000,002,000,000,000,000,000,
                      000,000,000,000,015,000,000,000,
                      000,001,000,000,000,000,000,018,
                      000,000,000,000,001,000,250,051,
                      192,142,208,188,000,124,022,007,
                      187,120,000,054,197,055,030,086,
                      022,083,191,043,124,185,011,000,
                      252,172,038,128,061,000,116,003,
                      038,138,005,170,138,196,226,241,
                      006,031,137,071,002,199,007,043,
                      124,251,205,019,114,103,160,016,
                      124,152,247,038,022,124,003,006,
                      028,124,003,006,014,124,163,063,
                      124,163,055,124,184,032,000,247,
                      038,017,124,139,030,011,124,003,
                      195,072,247,243,001,006,055,124,
                      187,000,005,161,063,124,232,159,
                      000,184,001,002,232,179,000,114,
                      025,139,251,185,011,000,190,214,
                      125,243,166,117,013,141,127,032,
                      190,225,125,185,011,000,243,166,
                      116,024,190,119,125,232,106,000,
                      050,228,205,022,094,031,143,004,
                      143,068,002,205,025,190,192,125,
                      235,235,161,028,005,051,210,247,
                      054,011,124,254,192,162,060,124,
                      161,055,124,163,061,124,187,000,
                      007,161,055,124,232,073,000,161,
                      024,124,042,006,059,124,064,056,
                      006,060,124,115,003,160,060,124,
                      080,232,078,000,088,114,198,040,
                      006,060,124,116,012,001,006,055,
                      124,247,038,011,124,003,216,235,
                      208,138,046,021,124,138,022,253,
                      125,139,030,061,124,234,000,000,
                      112,000,172,010,192,116,034,180,
                      014,187,007,000,205,016,235,242,
                      051,210,247,054,024,124,254,194,
                      136,022,059,124,051,210,247,054,
                      026,124,136,022,042,124,163,057,
                      124,195,180,002,139,022,057,124,
                      177,006,210,230,010,054,059,124,
                      139,202,134,233,138,022,253,125,
                      138,054,042,124,205,019,195,013,
                      010,078,111,110,045,083,121,115,
                      116,101,109,032,100,105,115,107,
                      032,111,114,032,100,105,115,107,
                      032,101,114,114,111,114,013,010,
                      082,101,112,108,097,099,101,032,
                      097,110,100,032,115,116,114,105,
                      107,101,032,097,110,121,032,107,
                      101,121,032,119,104,101,110,032,
                      114,101,097,100,121,013,010,000,
                      013,010,068,105,115,107,032,066,
                      111,111,116,032,102,097,105,108,
                      117,114,101,013,010,000,073,066,
                      077,066,073,079,032,032,067,079,
                      077,073,066,077,068,079,083,032,
                      032,067,079,077,000,000,000,000,
                      000,000,000,000,000,000,000,000,
                      000,000,000,000,000,000,$55,$AA
                    );

   BootRecord40   : Buffer = { MSDOS 4.0 }
                    (
                      235,060,144,073,066,077,032,032,
                      052,046,048,000,002,001,001,000,
                      002,224,000,096,009,249,007,000,
                      015,000,002,000,000,000,000,000,
                      000,000,000,000,000,000,041,201,
                      023,058,018,000,000,000,000,000,
                      000,000,000,000,046,048,070,065,
                      084,049,050,032,032,032,250,051,
                      192,142,208,188,000,124,022,007,
                      187,120,000,054,197,055,030,086,
                      022,083,191,062,124,185,011,000,
                      252,243,164,006,031,198,069,254,
                      015,139,014,024,124,136,077,249,
                      137,071,002,199,007,062,124,251,
                      205,019,114,124,051,192,057,006,
                      019,124,116,008,139,014,019,124,
                      137,014,032,124,160,016,124,247,
                      038,022,124,003,006,028,124,019,
                      022,030,124,003,006,014,124,131,
                      210,000,163,080,124,137,022,082,
                      124,163,073,124,137,022,075,124,
                      184,032,000,247,038,017,124,139,
                      030,011,124,003,195,072,247,243,
                      001,006,073,124,131,022,075,124,
                      000,187,000,005,139,022,082,124,
                      161,080,124,232,135,000,114,032,
                      176,001,232,161,000,114,025,139,
                      251,185,011,000,190,219,125,243,
                      166,117,013,141,127,032,190,230,
                      125,185,011,000,243,166,116,024,
                      190,147,125,232,081,000,050,228,
                      205,022,094,031,143,004,143,068,
                      002,205,025,088,088,088,235,232,
                      187,000,007,185,003,000,161,073,
                      124,139,022,075,124,080,082,081,
                      232,058,000,114,230,176,001,232,
                      084,000,089,090,088,114,201,005,
                      001,000,131,210,000,003,030,011,
                      124,226,226,138,046,021,124,138,
                      022,036,124,139,030,073,124,161,
                      075,124,234,000,000,112,000,172,
                      010,192,116,041,180,014,187,007,
                      000,205,016,235,242,059,022,024,
                      124,115,025,247,054,024,124,254,
                      194,136,022,079,124,051,210,247,
                      054,026,124,136,022,037,124,163,
                      077,124,248,195,249,195,180,002,
                      139,022,077,124,177,006,210,230,
                      010,054,079,124,139,202,134,233,
                      138,022,036,124,138,054,037,124,
                      205,019,195,013,010,078,111,110,
                      045,083,121,115,116,101,109,032,
                      100,105,115,107,032,111,114,032,
                      100,105,115,107,032,101,114,114,
                      111,114,013,010,082,101,112,108,
                      097,099,101,032,097,110,100,032,
                      112,114,101,115,115,032,097,110,
                      121,032,107,101,121,032,119,104,
                      101,110,032,114,101,097,100,121,
                      013,010,000,073,066,077,066,073,
                      079,032,032,067,079,077,073,066,
                      077,068,079,083,032,032,067,079,
                      077,000,000,000,000,000,000,000,
                      000,000,000,000,000,000,085,170
                    );

  BootRecord50   : Buffer =  { MSDOS 5.0 }
                    (
                      235,060,144,077,083,068,079,083,
                      053,046,048,000,002,002,001,000,
                      002,112,000,208,002,253,002,000,
                      009,000,002,000,000,000,000,000,
                      000,000,000,000,000,000,041,$74,
                      $19,$09,$15,078,079,032,078,065,
                      077,069,032,032,032,032,070,065,
                      084,049,050,032,032,032,250,051,
                      192,142,208,188,000,124,022,007,
                      187,120,000,054,197,055,030,086,
                      022,083,191,062,124,185,011,000,
                      252,243,164,006,031,198,069,254,
                      015,139,014,024,124,136,077,249,
                      137,071,002,199,007,062,124,251,
                      205,019,114,121,051,192,057,006,
                      019,124,116,008,139,014,019,124,
                      137,014,032,124,160,016,124,247,
                      038,022,124,003,006,028,124,019,
                      022,030,124,003,006,014,124,131,
                      210,000,163,080,124,137,022,082,
                      124,163,073,124,137,022,075,124,
                      184,032,000,247,038,017,124,139,
                      030,011,124,003,195,072,247,243,
                      001,006,073,124,131,022,075,124,
                      000,187,000,005,139,022,082,124,
                      161,080,124,232,146,000,114,029,
                      176,001,232,172,000,114,022,139,
                      251,185,011,000,190,230,125,243,
                      166,117,010,141,127,032,185,011,
                      000,243,166,116,024,190,158,125,
                      232,095,000,051,192,205,022,094,
                      031,143,004,143,068,002,205,025,
                      088,088,088,235,232,139,071,026,
                      072,072,138,030,013,124,050,255,
                      247,227,003,006,073,124,019,022,
                      075,124,187,000,007,185,003,000,
                      080,082,081,232,058,000,114,216,
                      176,001,232,084,000,089,090,088,
                      114,187,005,001,000,131,210,000,
                      003,030,011,124,226,226,138,046,
                      021,124,138,022,036,124,139,030,
                      073,124,161,075,124,234,000,000,
                      112,000,172,010,192,116,041,180,
                      014,187,007,000,205,016,235,242,
                      059,022,024,124,115,025,247,054,
                      024,124,254,194,136,022,079,124,
                      051,210,247,054,026,124,136,022,
                      037,124,163,077,124,248,195,249,
                      195,180,002,139,022,077,124,177,
                      006,210,230,010,054,079,124,139,
                      202,134,233,138,022,036,124,138,
                      054,037,124,205,019,195,013,010,
                      078,111,110,045,083,121,115,116,
                      101,109,032,100,105,115,107,032,
                      111,114,032,100,105,115,107,032,
                      101,114,114,111,114,013,010,082,
                      101,112,108,097,099,101,032,097,
                      110,100,032,112,114,101,115,115,
                      032,097,110,121,032,107,101,121,
                      032,119,104,101,110,032,114,101,
                      097,100,121,013,010,000,073,079,
                      032,032,032,032,032,032,083,089,
                      083,077,083,068,079,083,032,032,
                      032,083,089,083,000,000,085,170
                    );

Var
   C8,
   Error     : Boolean;
   Prog_Name : String[8];
   SysMode,
   MaxVirus  : Byte;
   VirusList : Array[Byte] of Record
                 Name    : String[15];
                 ID      : Array[0..2] of Byte;
                 Offset  : Word;
                 Track,
                 Side,
                 Block,
                 Intrp   : Byte;
               End;

Procedure Init_;
Begin
   _FastKey;
   CheckBreak  := False;
   DirectVideo := True;
   CheckSnow   := _ScreenType IN[0,1,2];
   _SaveAll;
   _SaveScreen;
   _SetPage(0);
   SysMode := _CurrentVideo;
   C8 := (SysMode = CO80) OR (SysMode = BW80);
   If NOT C8 then
     Begin
       TextMode(CO80);
       TextBackGround(Blue);
       ClrScr;
     End;
   _Border(Blue);
   _CursorOff;
End;

Procedure Done_;
Begin
   If NOT C8 then _SetVideo(SysMode);
   _16ColorOff;
   _RestoreScreen;
   _RestoreAll;
End;

Procedure SerialNumber;
Begin
  _Anc('Serial Number : $001.931.002.·',True);
  _CloseAnc;
End;

Procedure WipeOut; Forward;
Procedure DataBase; Forward;
Procedure Scan(Drv : Byte); Forward;
Procedure Scan_Mem; Forward;
Procedure About; Forward;
Procedure Info; Forward;
Procedure Help; Forward;

Procedure Ask_Quit;
begin
   _MakeSure(' Quit '+Prog_Name+' ','Are you sure to quit ?',_Quit);
end;

Procedure AskDrive;

  Function DriveStr(NumDrv : Byte) : String;
  Var
    I : Byte;
    S : String;
  Begin
    S := #16'   Drive Í   '#17;
    S[11] := Chr(65+NumDrv);
    DriveStr := S;
  End;

const
  Ask_Attr   = 16*Blue+White;
  ShiftDrv   = 11;
  X          = 18;
  Y          = 4;
  MaxDrv     = 3;
  DrvExist   : Byte = 0;

var
  I,
  DrvBuff1,
  DrvBuff2,
  Drv        : Byte;
  Chg,
  Sure       : Boolean;
  DrvLogic   : Array[0..MaxDrv] of Boolean;

  Procedure Show_Tag;
  Var C : Byte;
  begin
      For C := 0 to DrvExist-1 do
          _ShowSwitch(X,Y+2*C,_SwitchAttr,Ask_Attr,ShiftDrv,
                _Ground(_SwitchAttr)+Red,DriveStr(C));
     _ShowSwitch(X,Y+2*DrvCtr,_OkAttr,Ask_Attr,ShiftDrv,
        _Ground(_OkAttr)+LightRed,DriveStr(DrvCtr));
  end;

  Procedure Tag_Pressed;
  begin
     _SwitchPressed(X,Y+2*DrvCtr,_OkAttr,Ask_Attr,ShiftDrv,
        _Ground(_OkAttr)+LightRed,DriveStr(DrvCtr));
     _Delayer;
  end;

begin
   DrvBuff1 := DrvCtr;   { simpan status drive, restore jika _Esc }
   Sure := False;
   DrvExist := 0;
   DrvLogic[0] := _DriveType(0) IN [1..4];  { cek drive terpasang }
   DrvLogic[1] := _DriveType(1) IN [1..4];
   DrvLogic[2] := _HarddiskExist AND (_DriveType($80) = 5);
   DrvLogic[3] := (_Harddisk > 1) AND (_DriveType($81) = 5);
   For I := 0 to MaxDrv do
     If DrvLogic[I] then Inc(DrvExist);
   DrvBuff2 := DrvExist - 1;               { hitung jumlah drive }
   _SaveScreen;
   _PopBox(X-6,Y-2,20+X,Y+(2*DrvExist),1,Ask_Attr);
   _WriteXYAttr(X-3,Y-2,_Ground(Ask_Attr)+Yellow,' Choose Active Drive ');
   DriveOn := True;
   Chg     := True;
   repeat
     If Chg then Show_Tag;
     Chg := True;
     _ChrIO := UpCase(ReadKey);
      case _ChrIO of
        _ExtKey : begin
                    _ChrIO := ReadKey;
                    Case _ChrIO of
                      _F1,_AltH : If NOT HelpOn then Help;
                      _F2,_AltA : If NOT AboutOn then About;
                      _F3,_AltQ : Ask_Quit;
                      _F4,_AltI : If NOT InfoOn then Info;
                      _F5,_AltS : Scan(DrvCtr);
                      _F6,_AltM : Scan_Mem;
                      _F7,_AltO : _Sound := NOT _Sound;
                      _F9,_AltB : DataBase;
                     _F10,_AltW : WipeOut;
                      _ShiftF10 : SerialNumber;
                      _UpArrow  : If DrvCtr = 0 then
                                    DrvCtr := DrvBuff2
                                  Else
                                    Dec(DrvCtr);
                      _DnArrow  : If DrvCtr = DrvBuff2 then
                                    DrvCtr := 0
                                  Else
                                    Inc(DrvCtr);
                      _Home     : DrvCtr := 0;
                      _End      : DrvCtr := DrvBuff2;
                    end;
                    Chg := _ChrIO IN [_UpArrow,_DnArrow,_Home,_End];
                  end;
        _Tab,
        _Space  : If DrvCtr = DrvBuff2 then
                    DrvCtr := 0
                  Else
                    Inc(DrvCtr);
        _Esc    : begin
                    Sure := True;
                    DrvCtr := DrvBuff1;
                  end;
        _Enter  : begin
                    Sure := True;
                    Tag_Pressed;
                  end;
        'A'..'D' : begin
                     If DrvLogic[Ord(_ChrIO)-65] then Begin
                       Sure := True;
                       DrvCtr := Ord(_ChrIO)-65;
                       Show_Tag;
                       Tag_Pressed;
                     end else Chg := False;
                   end;
        _CtrlEnter : Begin
                       WipeOut;
                       Chg := False;
                     End;
        Else Chg := False;
      end;
   until Sure OR _Quit;
   Show_Tag;
   DriveOn := False;
   If NOT (_ChrIO = _Esc) then _Delayer;
   _RestoreScreen;
end;

Function DiskErrMsg : String;
Begin
  Case DosError of
     $00 : DiskErrMsg := 'Program structure error';
     $01 : DiskErrMsg := 'Controller command error';
     $02 : DiskErrMsg := 'Address Mark $ File not found';
     $03 : DiskErrMsg := 'Disk write protected';
     $04 : DiskErrMsg := 'Sector not found';
     $05 : DiskErrMsg := 'Access denied';
     $06 : DiskErrMsg := 'System internal error';
     $07 : DiskErrMsg := 'Invalid drive parameter';
     $08 : DiskErrMsg := 'Buffer allocation error / Not enough memory';
     $09 : DiskErrMsg := 'DMA operation error';
     $0B : DiskErrMsg := 'Invalid track flag. Re-Format !';
     $10 : DiskErrMsg := 'Bad error check / Invalid environtment';
     018 : DIskErrMsg := 'No more files';
     $20 : DiskErrMsg := 'Controller failure';
     $40 : DiskErrMsg := 'Bad seek operation';
     103 : DiskErrMsg := 'File not open';
     150 : DiskErrMsg := 'Disk is write protected';
     152,
     $80 : DiskErrMsg := 'Drive not ready';
     $BB : DiskErrMsg := 'Complex disk error';
     $FF : DiskErrMsg := 'Bad sense operation';
     Else  DiskErrMsg := 'General disk error';
  End;
End;

Procedure Configuration;
Var
  Ctr   : Byte;
  Code  : Integer;
  FL    : Text;
  St15  : String[15];
  Path  : PathStr;
  Dir   : DirStr;
  Name  : NameStr;
  Ext   : ExtStr;

Begin
  Path  := ParamStr(0);
  FSplit(Path,Dir,Name,Ext);           { ambil directory ScanZero }
  Path  := Dir + Prog_Name + '.CFG';
  DosError := 0;
  {$I-}
  Assign(FL,Path);
  Reset(FL);
  If (IOResult = 0) AND (DosError = 0) then
    Begin
      _Anc('READING CONFIGURATION',False);
      _Delayer;
      While NOT EOF(FL) do
        Begin
          If KeyPressed then
            Begin
              _ClearKey;
              _CloseAnc;
              Exit;
            End;
          ReadLn(FL,St15);
          St15 := _Trim(St15);
          If Copy(_UpStr(St15),1,6) = _UpStr('#delay') then
            Begin
              St15 := Copy(St15,8,1);
              If St15 = '1' then DelayFX := True
                Else If St15 = '0' then DelayFX := False;
            End;
          If Copy(_UpStr(St15),1,5) = _UpStr('#menu') then
            Begin
              St15 := Copy(_UpStr(St15),7,3);
              Val(St15,Ctr,Code);
              If Code = 0 then MenuAttr := Ctr AND $7F;
            End;
          If Copy(_UpStr(St15),1,6) = _UpStr('#sound') then
            Begin
              St15 := Copy(St15,8,1);
              If St15 = '1' then _Sound := True
                Else If St15 = '0' then _Sound := False;
            End;
          If Copy(_UpStr(St15),1,4) = _UpStr('#bar') then
            Begin
              St15 := Copy(St15,6,1);
              If St15 = '1' then Bar := True
                Else If St15 = '0' then Bar := False;
            End;
          If Copy(_UpStr(St15),1,5) = _UpStr('#back') then
            Begin
              St15 := Copy(St15,7,1);
              If St15 = '1' then BackGround := True
                Else If St15 = '0' then BackGround := False;
            End;
        End;
      _CloseAnc;
      Close(FL);
    End;
  {$I+}
End;

Procedure DataBase;
Var
  Ctr   : Byte;
  Code  : Integer;
  FL    : Text;
  St20  : String[15];
  St128 : ComStr;
  Path  : PathStr;
  Dir   : DirStr;
  Name  : NameStr;
  Ext   : ExtStr;

Begin
  MaxVirus := 0;
  Error := False;
  Path  := ParamStr(0);
  FSplit(Path,Dir,Name,Ext);
  Path  := Dir + Prog_Name + '.DBV';
  _Anc(_UpStr(_Backward('!esabatad gnidaer')),False);
  _Delayer;
  DosError := 0;
  {$I-}
  Assign(FL,Path);
  Reset(FL);
  If (IOResult <> 0) OR (DosError <> 0) then
    Begin
      _CloseAnc;
      _Alert;
      _ErrMsg('Error reading database file : '+_UpStr(Path));
      Error := True;
      Exit;
    End
  Else
    Begin
      While NOT EOF(FL) do
        Begin
          If KeyPressed then
            Begin
              _ClearKey;
              _CloseAnc;
              Error := MaxVirus = 0;
              Exit;
            End;
          ReadLn(FL,St128);
          St128 := _Trim(St128);
          If (St128 <> '') AND (St128[1] <> '#') then
            Begin
              St20 := _Trim(Copy(St128,2,16));
              Delete(St20,Length(St20),1);
              If St20 = '' then
                VirusList[MaxVirus].Name := 'Generic'
              else
                VirusList[MaxVirus].Name := St20;
              Val(Copy(St128,34,3),VirusList[MaxVirus].Offset,Code);
              If Code <> 0 then Error := True;
              Val(Copy(St128,41,2),VirusList[MaxVirus].Track,Code);
              If Code <> 0 then Error := True;
              Val(Copy(St128,44,2),VirusList[MaxVirus].Side,Code);
              If Code <> 0 then Error := True;
              Val(Copy(St128,47,2),VirusList[MaxVirus].Block,Code);
              If Code <> 0 then Error := True;
              Val(Copy(St128,53,3),VirusList[MaxVirus].Intrp,Code);
              If Code <> 0 then Error := True;
              For Ctr := 0 to 2 do
                Begin
                  Val(Copy(St128,19+Ctr*4,3),VirusList[MaxVirus].ID[Ctr],Code);
                  If Code <> 0 then Error := True;
                End;
              If NOT Error then
                Begin
                  _CenterMem(12,_WideString(23,VirusList[MaxVirus].Name));
                  If DelayFX then
                    Begin
                      Code := 100 - MaxVirus;
                      If Code < 50 then Code := 50;
                      Delay(Code);
                    End;
                  If MaxVirus < 255 then
                    Inc(MaxVirus)
                  Else
                    Begin
                      _CloseAnc;
                      _Alert;
                      _ErrMsg('Too much data on database file. Ignored...');
                      Exit;
                    End;
                End;
            End;
        End;
    End;
    Error := False;
    If MaxVirus <> 0 then
      Dec(MaxVirus)
    else
      _ErrMsg('File format error. Please report to ZeroBit');
    Close(FL);
    {$I+}
    _CloseAnc;
    _Delayer;
End;

Procedure ReadDisk(Drive,Side : Byte; Sec : Word; var DBuff : Buffer;
               var Error : Boolean);
var
  Ctr : Byte;
  Reg : Registers;
  Yes, Ok : Boolean;
Begin
  Ctr := 0;
  If Drive >= 2 then Inc(Drive,$80-2);
  Repeat
    Inc(Ctr);
    _ResetFlags;
    _ResetDrive(Drive);
    DosError := 0;
    With Reg do
      Begin
        AX := $0201;              { baca, 1 sektor }
        DH := Side;
        DL := Drive;
        CX := Sec;
        ES := Seg(DBuff[0]);
        BX := Ofs(DBuff[0]);
      End;
    Intr($13,Reg);
    Error := (
               _CarryF OR
               (DosError <> 0) OR
               ((Drive IN [0,1]) AND (Reg.AX <> 1)) OR
               ((Drive IN [2,3]) AND (Reg.AX <> 0))
             );
    If DosError = 0 then DosError := Reg.AH;
    Ok := NOT Error;
    If Error AND (DosError IN[3,4,5,$40,$80,150]) AND (Ctr < Try) then
          Begin
            _Alert;
            _MakeSure(' '+DiskErrMsg+' ','Do you wish to retry ?',Yes);
            Ok := NOT Yes;
          End;
  Until Ok OR (Ctr >= Try);
  If (Ctr >= Try) AND NOT Ok then
    Begin
      Error := True;
      If NOT (DosError IN[3,4,5,$40,$80,150]) then DosError := $06;
    End;
End;

Procedure WriteDisk(Drive, Side : Byte; Sec : Word; var DBuff : Buffer;
                var Error : Boolean);
Var
  Ctr : Byte;
  Reg : Registers;
  Yes, Ok : Boolean;
Begin
  Ctr := 0;
  If Drive >= 2 then
    Begin
      _Alert;
      _ErrMsg('Harddisk is still in Read-Only mode. Aborted...');
      Exit;
    End;
  Repeat
    Inc(Ctr);
    _ResetFlags;
    _ResetDrive(Drive);
    DosError := 0;
    With Reg do
      Begin
        AX := $0301;
        DH := Side;
        DL := Drive;
        CX := Sec;
        ES := Seg(DBuff[0]);
        BX := Ofs(DBuff[0]);
      End;
    Intr($13,Reg);
    Error := (
               _CarryF OR
               (DosError <> 0) OR
               ((Drive IN [0,1]) AND (Reg.AX <> 1)) OR
               ((Drive IN [2,3]) AND (Reg.AX <> 0))
             );
    If DosError = 0 then DosError := Reg.AH;
    Ok := NOT Error;
    If Error AND (DosError IN[3,4,5,$40,$80,150]) AND (Ctr < Try) then
          Begin
            _Alert;
            _MakeSure(' '+DiskErrMsg+' ',
                'Do you wish to retry the operation ?',Yes);
            Ok := NOT Yes;
          End;
  Until Ok OR (Ctr >= Try);
  If (Ctr >= Try) AND NOT Ok then
    Begin
      Error := True;
      If NOT (DosError IN[3,4,5,$40,$80,150]) then DosError := $06;
    End;
End;

{ Cek boot-record sesuai dengan konvensi DOS ? }
Function BootValid (var DBuff : Buffer) : Boolean;
Begin
  BootValid := (DBuff[510] = $55) AND (DBuff[511] = $AA);
End;

Procedure Ask_Boot(Virus : String);
Var
  Yes,
  Buff : Boolean;
  St   : String;
Begin
  St := ' Virus '+Virus+' detected ';
  _Alert;
  Buff := _Intense;
  _Intense := True;
  _MakeSure(St,'Do you want to reboot ?', Yes);
  If Yes then
    Begin
      _Border(Black);
      TextAttr := Black;
      ClrScr;
      _Fine;
      _Delayer;
      Inline($ea/0/0/$ff/$ff);       { JMP FFFF:0000  ; COLD BOOT }
    End;
  _Intense := Buff;
End;

Function AskCap : Diskette;
const
  Ask_Attr   = 16*Blue+White;
  X          = 49;
  Y          = 3;
  MaxCap     = 3;
  CapStr     : Array[1..MaxCap] of String[14] =
               ( #16'    360K    '#17,
                 #16'    1.2M    '#17,
                 #16'    1.4M    '#17
               );
  Chg        : Boolean = True;

  Procedure Show_Tag;
  Var C : Byte;
  begin
      For C := 1 to MaxCap do
          _ShowSwitch(X,Y+2*C,_SwitchAttr,Ask_Attr,2,
                _Ground(_SwitchAttr)+Red,CapStr[C]);
     _ShowSwitch(X,Y+2*CapCtr,_OkAttr,Ask_Attr,2,
        _Ground(_OkAttr)+LightRed,CapStr[CapCtr]);
  end;

  Procedure Tag_Pressed;
  begin
     _SwitchPressed(X,Y+2*CapCtr,_OkAttr,Ask_Attr,2,
        _Ground(_OkAttr)+LightRed,CapStr[CapCtr]);
     _Delayer;
  end;

Var
  SavCap : Byte;
  Sure   : Boolean;

begin
   _SaveScreen;
   AskCap := UnKnown;
   _PopBox(X-6,Y,20+X,Y+8,1,Ask_Attr);
   _WriteXYAttr(X-3,Y,_Ground(Ask_Attr)+Yellow,' Choose Disk Capasity ');
   SavCap := CapCtr;
   Sure := False;
   repeat
     If Chg then Show_Tag;
     Chg := True;
     _ChrIO := ReadKey;
      case _ChrIO of
        _ExtKey : begin
                    _ChrIO := ReadKey;
                    Case _ChrIO of
                      _AltZ      : _Quit := True;
                      _F3, _AltQ : Ask_Quit;
                      _F5, _AltS : Scan(DrvCtr);
                      _F6, _AltM : Scan_Mem;
                      _F7, _AltO : Begin
                                     _Sound := NOT _Sound;
                                     Chg := False;
                                   End;
                      _F9, _AltB : DataBase;
                      _F10,_AltW : WipeOut;
                      _ShiftF10  : SerialNumber;
                      _UpArrow : If CapCtr = 1 then
                                   CapCtr := MaxCap
                                 Else
                                   Dec(CapCtr);
                      _DnArrow : If CapCtr = MaxCap then
                                   CapCtr := 1
                                 Else
                                   Inc(CapCtr);
                      _Home    : CapCtr := 1;
                      _End     : CapCtr := MaxCap;
                    end;
                    Chg := _ChrIO IN[_UpArrow,_DnArrow,_Home,_End];
                  end;
        _Tab,
        _Space  : If CapCtr = MaxCap then
                    CapCtr := 1
                  Else
                    Inc(CapCtr);
        _Esc    : begin
                    Sure := True;
                    CapCtr := SavCap;
                  end;
        _Enter  : begin
                    Sure := True;
                    Tag_Pressed;
                  end;
        _CtrlEnter : Begin
                       WipeOut;
                       Chg := False;
                     End;
        Else Chg := False;
      end;
   until Sure Or _Quit;
   Show_Tag;
   _RestoreScreen;
   Case CapCtr of
     1 : AskCap := DoubleDensity;
     2 : AskCap := HighDensity;
     3 : AskCap := QuadDensity;
   End;
   If _Quit then _Delayer;
End;

Function Capacity : Diskette;
Var
  Bff : Buffer;
  Err : Boolean;
Begin
  ReadDisk(DrvCtr,0,2,Bff,Err);      { Ambil Byte Pertama di FAT }
  If NOT Err then
    Case Bff[0] of
        $FD : Capacity := DoubleDensity;
        $F9 : Capacity := HighDensity;
        $F0 : Capacity := QuadDensity;
      Else Capacity := UnKnown;
    End
  Else
    Capacity := AskCap;
End;

Procedure OverWrite;
Var
  DB  : Buffer;
  Yes : Boolean;
Begin
   Case Lo(DosVersion) of
     3 : DB := BootRecord33;  { timpa sesuai dengan versi dos aktif }
     4 : DB := BootRecord40;
     5 : DB := BootRecord50;
    Else
      Begin
        _Alert;
        _MakeSure(_UpStr(_Backward(' ! g n i n r a w ')),
           'The disk may become un-bootable. Proceed anyway ?',Yes);
        If Yes then
          DB := BootRecord50
        Else Exit;
      End;
   End;
   DB[12] := 2;
   DB[26] := 2;
   Case Capacity of     { set boot record sesuai dengan jenis disk }
      DoubleDensity : Begin
                        DB[13] :=   2;
                        DB[21] := $FD;
                        DB[22] :=   2;
                        DB[24] :=   9;
                        DB[17] := 112;
                      End;
      HighDensity   : Begin
                        DB[13] :=   1;
                        DB[21] := $F9;
                        DB[22] :=   7;
                        DB[24] :=  15;
                        DB[17] := 224;
                      End;
      QuadDensity   : Begin
                        DB[13] :=   2;
                        DB[21] := $F0;
                        DB[22] :=   6;
                        DB[24] :=  18;
                        DB[17] := 224;
                      End
     Else
       Begin
         _ErrMsg('Incompatible disk type');
         Exit;
       End;
   End;
   If _Quit OR (_ChrIO = _Esc) then Exit;
   WriteDisk(DrvCtr,0,1,DB,Error);
   If Error AND NOT (DosError IN [3,4,5,$40,$80,150]) then
     _ErrMsg(DiskErrMsg)
   Else
     If NOT Error then
       Begin
         _Anc(_UpStr(_Backward('detirwrevo drocer toob')),False);
         _Fine;
         Delay(2000);
         VirusWiped := True;
         _CloseAnc;
       End
     Else _ErrMsg('Access error');
End;

Procedure AskOverWrite(St : String);
Var Yes : Boolean;
Begin
   _MakeSure(' Verify Overwrite ',St, Yes);
   If Yes then OverWrite;
End;

Procedure WipeOut;
Begin
  AskOverWrite('This operation will reset the boot record. Proceed ?');
End;

Procedure Scan(Drv : Byte);
  Procedure DiskVirusFound(Virus : Byte; DBuff : Buffer);
    Procedure CleanDisk(Virus : Byte; DB : Buffer);
      Procedure Copy2Boot(Track, Side, Sec : Byte);
      Var
        Buff : Buffer;
        Err,
        Yes  : Boolean;

      Begin
        ReadDisk(DrvCtr, Side, 256*Track+Sec,Buff,Err);
        If NOT BootValid(Buff) then
          Begin
            _Alert;
            _ErrMsg('Invalid Boot Record Table');
            AskOverWrite('Invalid Boot Table. Overwrite with new one ?');
            Exit;
          End
        Else
          If Err then
          Begin
            _Alert;
            _ErrMsg('Disk Read Error');
            AskOverWrite('Can''t find the real boot record. Overwrite Virus ?');
            Exit;
          End
        Else
          Begin
            WriteDisk(DrvCtr,0,1,Buff,Err);
            If Err then
              Begin
                _Alert;
                _ErrMsg('Error writing boot record');
                Exit;
              End
            Else
              Begin
                _Anc(_UpStr(_Backward('demover suriv')),False);
                _Fine;
                Delay(1000);
                VirusWiped := True;
                _CloseAnc;
              End;
          End;
      End; { Copy2Boot }

    Begin
      With VirusList[Virus] do
        Begin
          If NOT ((Track = 0) AND (Side = 0) AND (Block = 0)) then
             Copy2Boot(Track,Side,Block)
          Else
             AskOverWrite(' No such information on database. '+
                'Overwrite boot record ?');
        End;
    End; { CleanDisk }

  Var
    Yes    : Boolean;
    VirStr : String;

  Begin
    _Alert;
    VirStr := 'Virus ['+VirusList[Virus].Name+'] founded ! Proceed cleaning ?';
    _MakeSure(' Verify Disk Cleaning ', VirStr, Yes);
    If Yes then CleanDisk(Virus,DBuff);
  End; { DiskVirusFound }

Var
  Yes,
  VirusExist : Boolean;
  I,
  K          : Byte;
  DiskBuff   : Buffer;

Begin
  VirusExist := False;
  VirusWiped := False;
  _Anc2('Scanning disk for viruses');
  ReadDisk(Drv,0,1,DiskBuff,Error);
  _CloseAnc;
  If Error then
    Begin
      _Alert;
      _ErrMsg(DiskErrMsg);
      Exit;
    End
  Else
    Begin
      I := 0;
      While (I < MaxVirus) AND (NOT VirusExist) do
        With VirusList[I] do
          Begin
            K := Offset;
            If ((DiskBuff[K]   = ID[0]) AND
                (DiskBuff[K+1] = ID[1]) AND
                (DiskBuff[K+2] = ID[2]))
              then
                Begin
                  VirusExist   := True;
                  VirusIsExist := True;
                  DiskVirusFound(I,DiskBuff);
                End;
            Inc(I);
          End;
    End;
    If NOT VirusExist then
      Begin
        _Fine;
        _Anc(_UpStr(_Backward('detceted suriv on')),True);
        _CloseAnc;
      End;
    If NOT (BootValid(DiskBuff) OR VirusWiped) then
      Begin
        _Alert;
        If DrvCtr < 2 then
          AskOverwrite('Invalid media descryptor byte. Overwrite ?')
        Else
          Begin
            _Anc('Disk media descryptor byte is invalid',True);
            _CloseAnc;
          End;
      End;
End;

Procedure Scan_Mem;
Var
  Segment : Longint;
  I,
  K,
  T       : Byte;
  SavPtr  : Pointer;
  Proceed : Boolean;

Begin
   Segment :=  Trunc(_MainMemory * 64);   { Dapatkan jumlah paragraph }
   _Anc2('Scanning memory for viruses');
   Delay(500);
   I := 0;
   While (I < MaxVirus) AND NOT VirusIsExist do
     With VirusList[I] do
       Begin
         K := Offset;
         If ((Mem[Segment:K]   = ID[0]) AND
             (Mem[Segment:K+1] = ID[1]) AND
             (Mem[Segment:K+2] = ID[2])) then
           Begin
             VirusIsExist := True;
             If Intrp <> 0 then
               Begin
                 _MakeSure('Redirect 13h Interrupt',
                           'This operation will change the system. Proceed ?',
                           Proceed);
                 If Proceed then
                   Begin
                     _Anc2('Resetting 13h Interrupt');
                     GetIntVec(Intrp, SavPtr);
                     If SavPtr <> NIL then
                       Begin
                         SetIntVec($13, SavPtr);
                         _Fine
                       End
                     else
                       Begin
                         _Alert;
                         _ErrMsg('Can''t do ! System will crash !')
                       End;
                     _CloseAnc;
                   End
                 else
                   Ask_Boot(Name);
               End
             else
               Ask_Boot(Name);
           End;
         Inc(I);
       End;
   _CloseAnc;
End;

Procedure Help;
Const
   X         = 13;
   Y         = 4;
   Help_Attr = 16*LightGray+Blink;
Var
   Saved  : Boolean;
   C      : Char;

Begin
   _SaveScreen;
   Saved := _Intense;
   _Intense := True;
   _PopCenter(X,Y,4,_Ground(Help_Attr)+Blue);
   _WriteXYAttr(X+2,Y,_Ground(Help_Attr),' Help ');
   _WriteXY(X+3,Y+2,Prog_Name+' is an anti boot virus utility.');
   _WriteXY(X+3,Y+4,'Viruses which can be detected are listed on the');
   _WriteXY(X+3,Y+5,Prog_Name+' database file, '+_UpStr(Prog_Name)+'.DBV.');
   _WriteXY(X+3,Y+6,'You can add the virus list by modifying the file.');
   _WriteXY(X+3,Y+7,'It can handle up to 250 viruses. You can also');
   _WriteXY(X+3,Y+8,'determine amount memory detected by DOS to make');
   _WriteXY(X+3,Y+9,'sure that your memory is virus-free. And it is');
   _WriteXY(X+3,Y+10,'wise to reboot if a virus detected in memory.');
   _WriteXY(X+3,Y+12,'Happy Virus Bustering !');
   _SwitchAppear(35,22-Y,Help_Attr);
   HelpOn := True;
   Repeat
      C := UpCase(ReadKey);
      Case C of
        _ExtKey : Begin
                    C := ReadKey;
                    Case C of
                      _AltZ      : _Quit := True;
                      _F2, _AltA : If NOT AboutOn then About;
                      _F3, _AltQ : Ask_Quit;
                      _F4, _AltI : If NOT InfoOn then Info;
                      _F5, _AltS : Scan(DrvCtr);
                      _F6, _AltM : Scan_Mem;
                      _F7, _AltO : Begin
                                     _Sound := NOT _Sound;
                                     Chg := False;
                                   End;
                      _F8, _AltD : If NOT DriveOn then AskDrive;
                      _F9, _AltB : DataBase;
                      _F10,_AltW : WipeOut;
                      _ShiftF10  : SerialNumber;
                    End;
                  End;
        'D'     : If NOT DriveOn then AskDrive;
        _CtrlEnter : WipeOut;
      End;
   Until (C IN [_Esc,_Enter,_Space,'O']) OR _Quit;
   HelpOn := False;
   If NOT _Quit then
     _SwitchPressedAppear(35,22-Y,Help_Attr)
   Else
     _Delayer;
   _RestoreScreen;
   _Intense := Saved;
End;

Procedure Info;
  Function Existance(DeviceExist : Boolean) : String;
  Begin
    If DeviceExist then
      Existance := 'Attached'
    Else
      Existance := 'None';
  End;

Const
   Date : Array[0..6] of String[9] =
          ('yadnuS','yadnoM','yadseuT','yadsendeW',
           'yadsruhT','yadirF','yadrutaS');
   Sys_Attr = 16*Brown+Blue+Blink;
   X = 14;
   Y =  5;

Var
   Saved : Boolean;
   Reg   : Registers;
   C     : Char;

Begin
   Saved := _Intense;
   _Intense := True;
   _SaveScreen;
   _PopBox(X-4,Y-4,X+24,Y+18,4,Sys_Attr);
   _WriteXYAttr(X,Y-2,_Ground(Sys_Attr),_Decrypt('([Å{|mu(Qvnwzui|qwv('));
   GotoXY(X,Y+00);
   Write(_Backward('P MBI : retupmoC'));
   Case _ComputerType of
      0 : Write('C');
      1,
      4 : Write('C/XT');
      2 : Write('Cjr');
      3 : Write('C/AT');
      5 : Write('S/2-30');
      6 : Write('C-Conv');
      7 : Write('S/2-80');
     Else Write(_Backward('nwonknU'#8#8#8#8#8));
   End;
   GotoXY(X,Y+01); Write('BIOS     : ',_BIOS);
   GotoXY(X,Y+02); Write('Memory   : ',_MainMemory,' KB');
   GotoXY(X,Y+03); Write('ExtAvail : ');
     If _ComputerType IN [0,1,2,4] then
       Write('0')
     else
       Write(_ExtMemAvail);
     Write(' KB');
   GotoXY(X,Y+04); Write('Bus      : ');
   If _MCAExist then
     Write('M.C.A')
   Else
     Write(_UpStr(_Backward('asie/asi')));
   GotoXY(X,Y+05); Write('Math Co  : ',Existance(_MathCoExist));
   GotoXY(X,Y+06); Write('Monitor  : ');
   Case _ScreenType of
      1 : Write('Monochrome');
      2 : Write('CGA');
      3 : Write('EGA');
      4 : Write('PGA');
      5 : Write('MCGA Mono');
      6 : Write('MCGA');
      7 : Write('VGA Mono');
      8 : Write('VGA');
     Else Write('Unknown');
   End;
   GotoXY(X,Y+07); Write('Floppy   : ');
   If _FloppyExist then
     If _Floppy > 1 then
       Write(_Floppy,' drives')
     Else
       Write('1 drive')
   Else
     Write('None');
   GotoXY(X,Y+08); Write('Harddisk : ');
   If _HarddiskExist then
     If _Harddisk > 1 then
       Write(_Harddisk,' drives')
     Else
       Write('1 drive')
   Else
     Write('None');
   GotoXY(X,Y+09); Write('Mouse    : ');
   If _MouseExist then
     Write(_MouseButton,' buttons')
   Else
     Write('None');
   GotoXY(X,Y+10); Write('LightPen : ',Existance(_LightPenExist));
   GotoXY(X,Y+11); Write('Modem    : ',Existance(_IntModemExist));
   GotoXY(X,Y+12); Write('System   : ');
     Case _DosType of
       2 : Write('MS');
       1 : Write('PC');
       Else ;               { Unknown DOS ! DRDOS ? }
      End;
     Write('DOS ',Lo(DosVersion),'.',_ZeroByte(Hi(DosVersion),2));
   Reg.AH := $2A;
   MsDos(Reg);
   GotoXY(X,Y+13); Write('Day      : ',_Backward(Date[Reg.AL]));
   GotoXY(X,Y+14); Write('Date     : ',_ZeroByte(Reg.DH,2),'/',
                                       _ZeroByte(Reg.DL,2),'/',Reg.CX);
   _SwitchAppear(X+5,Y+16,Sys_Attr);
   InfoOn := True;
   Repeat
      C := UpCase(ReadKey);
      Case C of
        _ExtKey : Begin
                    C := ReadKey;
                    Case C of
                      _AltZ      : _Quit := True;
                      _F1, _AltH : If NOT HelpOn then Help;
                      _F2, _AltA : If NOT AboutOn then About;
                      _F3, _AltQ : Ask_Quit;
                      _F5, _AltS : Scan(DrvCtr);
                      _F6, _AltM : Scan_Mem;
                      _F7, _AltO : Begin
                                     _Sound := NOT _Sound;
                                     Chg := False;
                                   End;
                      _F8, _AltD : If NOT DriveOn then AskDrive;
                      _F9, _AltB : DataBase;
                      _F10,_AltW : WipeOut;
                      _ShiftF10  : SerialNumber;
                    End;
                  End;
        'D'     : If NOT DriveOn then AskDrive;
        _CtrlEnter : WipeOut;
      End;
   Until (C IN [_Esc,_Enter,_Space,'O']) OR _Quit;
   InfoOn := False;
   If NOT _Quit then
     _SwitchPressedAppear(X+5,Y+16,Sys_Attr)
   Else _Delayer;
   _RestoreScreen;
   _Intense := Saved;
End;

Procedure About;
Const
   About_Attr = 16*Blue+White+Blink;
   X = 37;
   Y =  6;
Var
   C     : Char;
   Saved : Boolean;
Begin
   Saved := _Intense;
   _Intense := True;
   _SaveScreen;
   _PopBox2(X,Y,X+38,Y+11,2,About_Attr);
   _WriteXYAttr(X+12,Y+2,_Ground(About_Attr)+Yellow,
               _Decrypt('['#1'K'#1'I'#1'V'#1'b'#1'M'#1'Z'#1'W'));
   TextAttr := About_Attr;
   _WriteXY(X+14,Y+3,_Decrypt('Zmtmi{m(:69'));
   _WriteXY( X+5,Y+4,_Decrypt('KwxÅzqop|(0K19AA;4(bmzwJq|(XK'));
   _WriteXY( X+6,Y+5, _Decode('Ø—∞—ΩêáﬂÕ…«ﬂ´ûëòöçûëòﬂŒ œœŒ'));

   _WriteXY( X+9,Y+7,_Backward('nettirw dna dengiseD'));
   _WriteXY(X+18,Y+8, 'by');
   _WriteXY(X+10,Y+9,_Decode(_Encrypt('∂Öéíë◊†ñè~Ç◊©ÇêÖñèñ')));
   AboutOn := True;
   repeat
     C := UpCase(ReadKey);
     Case C of
       _ExtKey : Begin
                   C := ReadKey;
                   Case C of
                     _AltZ      : _Quit := True;
                     _F1, _AltH : If NOT HelpOn then Help;
                     _F3, _AltQ : Ask_Quit;
                     _F4, _AltI : If NOT InfoOn then Info;
                     _F5, _AltS : Scan(DrvCtr);
                     _F6, _AltM : Scan_Mem;
                     _F7, _AltO : Begin
                                    _Sound := NOT _Sound;
                                    Chg := False;
                                  End;
                     _F8, _AltD : If NOT DriveOn then AskDrive;
                     _F9, _AltB : DataBase;
                     _F10,_AltW : WipeOut;
                     _ShiftF10  : SerialNumber;
                   End;
                 End;
       'D'     : If NOT DriveOn then AskDrive;
       _CtrlEnter : WipeOut;
     End;
   until (C IN [_Esc,_Enter,_Space,'O']) OR _Quit;
   AboutOn := False;
   _Delayer;
   _RestoreScreen;
   _Intense := Saved;
End;

Procedure DisplayMenu;
Const Y = 6;
Var I : Byte;
Begin
  If (_ChrIO <> _Enter) then
    For I := 1 to MaxMenu do
      _ShowSwitch(30,Y+I*3,_SwitchAttr,MenuAttr,8,_SwitchAttr+Red,Tag[I]);
  _ShowSwitch(30,Y+Menu*3,_OkAttr,MenuAttr,8,_SwitchAttr+LightRed,Tag[Menu]);
  If Status[Menu] then
    Begin
      _KeyEffect(30,Y+3*Menu,_OkAttr,MenuAttr,8,_SwitchAttr+LightRed,Tag[Menu]);
      Case Menu of
        1 : AskDrive;
        2 : Scan(DrvCtr);
        3 : _Quit := True;
      End;
      For I := 1 to MaxMenu do Status[I] := False;
    End;
End;

Procedure Get_Key;
Begin
   Chg := True;
   _ChrIO := UpCase(ReadKey);
   Case _ChrIO of
      'D'     : Begin
                  Menu := 1;
                  Status[1] := True;
                End;
      'S'     : Begin
                  Menu := 2;
                  Status[2] := True;
                End;
      'Q'     : Begin
                  Menu := 3;
                  Status[3] := True;
                End;
      _Space  : If Menu = MaxMenu then
                  Menu := 1
                Else Inc(Menu);
      _Esc,
      _CtrlX,
      _CtrlQ  : Ask_Quit;
      _Enter  : Status[Menu] := True;
      _ExtKey : Begin
                   _ChrIO := ReadKey;
                   Case _ChrIO of
                      _AltH, _F1    : Help;
                      _AltA, _F2    : About;
                      _AltX,
                      _AltQ, _F3    : Ask_Quit;
                      _AltI, _F4    : Info;
                      _AltS, _F5    : Scan(DrvCtr);
                      _AltM, _F6    : Scan_Mem;
                      _AltO, _F7    : _Sound := NOT _Sound;
                      _AltD, _F8    : AskDrive;
                      _AltB, _F9    : DataBase;
                      _AltW, _F10   : WipeOut;
                      _UpArrow      : If Menu = 1 then
                                        Menu := MaxMenu
                                      Else
                                        Dec(Menu);
                      _DnArrow      : If Menu = MaxMenu then
                                        Menu := 1
                                      Else
                                        Inc(Menu);
                      _Home         : Menu := 1;
                      _End          : Menu := MaxMenu;
                      _AltZ         : _Quit := True;
                      _ShiftF10     : SerialNumber;
                   End;
                   Chg := _ChrIO IN [_UpArrow,_DnArrow,_Home,_End];
                End;
       _CtrlEnter : Begin
                      WipeOut;
                      Chg := False;
                    End;
      Else Chg := False;
   End;
End;

Procedure DrawBar;
Const Line = 22;
Begin
  _PopBox(2,Line-1,78,Line+1,1,BarAttr);
  _WriteXY(4,Line,'F1-Help F2-About F3-Quit F4-Info F5-Scan '+
               'F6-Mem F7-sOund F8-Drive F9-Base');
  TextAttr := _Ground(BarAttr)+(_Ground(BarAttr) SHR 4)+8;
  _WriteXY(07,Line,'H'); _WriteXY(15,Line,'A'); _WriteXY(24,Line,'Q');
  _WriteXY(32,Line,'I'); _WriteXY(40,Line,'S'); _WriteXY(48,Line,'M');
  _WriteXY(56,Line,'O'); _WriteXY(64,Line,'D'); _WriteXY(73,Line,'B');
End;

Procedure DrawMat;
Var W : Word;
Begin
  If Mem[0:$417] = 9 then
    Begin
      For W := 0 to 1999 do MemW[_VidSeg:W*2] := (219)+256*($1F);
      _Border(White);
    End
  else
    If Mem[0:$417] = 10 then
      Begin
        For W := 0 to 1999 do MemW[_VidSeg:W*2] := (0)+256*($00);
        _Border(Black);
      End
    else
      Begin
        For W := 0 to 1999 do
          If (W MOD 160) < 80 then
            MemW[_VidSeg:W*2] := (222)+256*(W MOD 80)
          else
            MemW[_VidSeg:W*2] := (221)+256*(80-(W MOD 80));
      End
End;

(* ------------------------------------------------ *)
(*                       Main                       *)
(* ------------------------------------------------ *)

Begin
   Prog_Name := _Decode(_Backward('êçö•ëûú¨'));
   If (ParamCount <> 0) OR (Lo(DosVersion) < 3) OR (MemAvail < 20480) then
     Begin
       WriteLn(Prog_Name,_Decrypt('(:69('#6'(0K19AA;4(bmzwJq|(XK'),^J);
       If (Lo(DosVersion) < 3) then
         WriteLn('Only support DOS 3.0 and above')
       Else
         If (ParamCount <> 0) then
           WriteLn(_Backward('detroppus sretemarap oN'))
         Else
           WriteLn('More memory required');
       Halt(2);
     End;
   Init_;
   If _SysPage <> 0 then ClrScr;
   Configuration;
   If BackGround then DrawMat;
   _PopCenter(17, 5, 1, MenuAttr);
   _Center(5,_Ground(MenuAttr)+Yellow,' '+Prog_Name+' ');
   _Center(19,_Ground(MenuAttr),_Decrypt('(0K19AA;4(bmzwJq|(XK('));
   If Bar then DrawBar;
   _ChrIO := _ExtKey;
   DisplayMenu;
   DataBase;
   If NOT Error then
     Begin
       Scan_Mem;
       If NOT ((_MainMemory = 256) OR
               (_MainMemory = 512) OR
               (_MainMemory = 640)) then
         Begin
           _MakeSure(' Memory Verification ',
             'Are you sure the memory is virus-free ?', _Quit);
           _Quit := NOT _Quit;  { keluar jika jawab "Ya" }
         end;
       Repeat
         If (Chg AND (NOT _Quit)) then DisplayMenu;
         If NOT _Quit then Get_Key;
       Until _Quit;
       If VirusIsExist then Ask_Boot('has been');
     End;
   _Delayer;
   Done_;
   If VirusIsExist then Halt(1); { jika ada virus, beri exit-code #1 ke DOS }
   If Error then Halt(4);        { jika ada error, exit-code = #4 }
End.
