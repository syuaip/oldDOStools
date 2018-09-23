(* ------------------------------------------------ *)
(*   Program Name     :  Unit Window R1.10          *)
(*   Programmer       :  Arief Wahyu Nugraha        *)
(*                       0104.920.292 - 1.P.C.T     *)
(*                       STMIK Bina Nusantara       *)
(*   Compiler         :  Turbo Pascal 5.50          *)
(*   Program Code     :  #A04.93.01.19.09.00.$61    *)
(* ------------------------------------------------ *)

{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}
{$M 16384,0,655360}

(*----------------- Unit Declaration ---------------*)

Unit WinZero;

(*----------------- Interface -----------------*)

INTERFACE

(*-------------- Used Unit ------------*)

Uses Crt, Dos, Sys;

(*-------------- Constanta ------------*)

Const
   _SwitchAttr    = 16*LightGray;
   _OkAttr        = 16*LightGray+White;
   _OkPressedAttr = 16*LightGray+LightRed;
   _OkShift       = 5;
   _Intense       : Boolean = False;
   _Sound         : Boolean = True;
   _Quit          : Boolean = False;
   _WindowCounter : Byte = 0;

(*------- Variable Declaration --------*)

Var
   _OkPrompt      : String[10];
   _SysPage,
   _SysAttr,
   _MaxWindow     : Byte;
   _ChrIO         : Char;
   _VidSeg        : Word;

(*------ Functions and Procedures -----*)

Function _Ground(Bits : Byte) : Byte;
Function _CurrentVideo : Byte;
Function _CurrentPage : Byte;
Function _ScreenHalfWide :Byte;
Procedure _FastKey;
Procedure _16ColorOn;
Procedure _16ColorOff;
Procedure _Border(Attr : Byte);
Procedure _Fine;
Procedure _Alert;
Procedure _ErrMsg(St :String);
Procedure _Cursor(Up, Down : Byte);
Procedure _CursorOff;
Procedure _CursorFull;
Procedure _SaveCursor;
Procedure _RestoreCursor;
Procedure _SaveAttr;
Procedure _RestoreAttr;
Procedure _SetPage(Page : Byte);
Procedure _SavePage;
Procedure _RestorePage;
Procedure _SaveAll;
Procedure _RestoreAll;
Procedure _WriteXY(XPos, YPos : Byte; St : String);
Procedure _WriteXYAttr(XPos, YPos, Attr : Byte; St : String);
Procedure _WriteXYMem(XPos, YPos : Byte; St : String);
Procedure _MemXYAttr(XPos, YPos, Attr, Times : Byte);
Procedure _Center(Row, Attr : Byte; St : String);
Procedure _CenterMem(Row : Byte; St : String);
Procedure _ClearKey;
Procedure _Delayer;
Procedure _InputKey(Var Key : Char);
Procedure _SaveScreen;
Procedure _RestoreScreen;
Procedure _MakeBox( X1, Y1, X2, Y2, Box_Type : Byte);
Procedure _ShadowBox( X1, Y1, X2, Y2 : Byte);
Procedure _Clear(X1, X2, Y1, Y2, Attr : Byte);
Procedure _PopBox(X1, Y1, X2, Y2, Box_Type, Attr : Byte);
Procedure _PopCenter(X1, Y1, Box_Type, Attr : Byte);
Procedure _PopBox2(X1, Y1, X2, Y2, Box_Type, Attr : Byte);
Procedure _PopCenter2(X1, Y1, Box_Type, Attr : Byte);
Procedure _ShowSwitch(X, Y, F_Attr, B_Attr, Shift,
                        Shift_Attr : Byte; St : String);
Procedure _SwitchPressed( X, Y, F_Attr, B_Attr, Shift,
                         Shift_Attr : Byte; St : String);
Procedure _SwitchAppear(X,Y, Attr : Byte);
Procedure _GetKey(X, Y, F_Attr, B_Attr, Shift, Shift_Attr : Byte; St : String);
Procedure _KeyEffect( X, Y, F_Attr, B_Attr, Shift,
                    Shift_Attr : Byte; St : String);
Procedure _SwitchPressedAppear(X,Y, Attr : Byte);
Procedure _MakeSure(St_About, St_Msg : String; var Answer : Boolean);
Procedure _Anc(St : String; Ok : Boolean; var Sure : Boolean);
Procedure _Anc2(St : String);
Procedure _CloseAnc;
Procedure _Hold;

(*--------------- Impelementation -------------*)

IMPLEMENTATION

(*-------------- Constanta ------------*)

Const
   OkPrm         = #16'   Ok   '#17;
   CenterErr     = 'Err.rng._PCTR';
   BoxErr        = 'Err.rng._PBOX';
   InvalidPtr    = 'Invalid screen operation';
   ExtKey        =   #0;  AltZ          =  #44;
   Tab           =   #9;  Enter         =  #13;
   Esc           =  #27;  Space         =  #32;
   UpArrow       =  #72;  LfArrow       =  #75;
   RgArrow       =  #77;  DnArrow       =  #80;
   ScreenMem     = 4000;

(*------ Identifier Declaration -------*)

Type
   BuffPtr        = ^Buffer;
   Buffer         = Record
                      Buff : Array[0..ScreenMem-1] of Byte;
                      Prev,
                      Next : BuffPtr;
                    End;

(*------- Variable Declaration --------*)

Var
   UpCursor,
   DnCursor,
   XCursor,
   YCursor         : Byte;
   BoxError,
   CenterError     : String[15];
   Scr,
   ScrSave,
   FirstPtr,
   LastPtr,
   PrevPtr         : BuffPtr;

(*---------- Funcs and Procs ----------*)

Function _Ground(Bits : Byte) : Byte;
begin
   _Ground := Bits AND $F0;
end;

Function _CurrentVideo : Byte;
var Reg : Registers;
begin
   Reg.AH := 15;
   Intr($10,Reg);
   _CurrentVideo := Reg.AL;
end;

Function _CurrentPage : Byte;
var Reg : Registers;
begin
   Reg.AH := 15;
   Intr($10,Reg);
   _CurrentPage := Reg.BH;
end;

Function _ScreenHalfWide : Byte;
Begin
  Case _CurrentVideo of
    0,1 : _ScreenHalfWide := 20;
    2,3 : _ScreenHalfWide := 40;
   Else
     Begin
       _Alert;
       _ScreenHalfWide := 0;
     End;
  End;
End;

Procedure _FastKey;
Var Reg : Registers;
Begin
  Reg.AX := $0305;
  Reg.BX := $0000;
  Intr($16,Reg);
End;

Procedure _16ColorOn;
Var Reg : Registers;
Begin
  If _CGA then
    Port[984] := 9
  else
    Begin
      With Reg do
        Begin
          AH := $10;
          AL := $03;
          BL := $00;
        End;
      Intr($10,Reg);
    End;
End;

Procedure _16ColorOff;
Var Reg : Registers;
Begin
  If _CGA then
    Port[984] := 41
  else
    Begin
      With Reg do
        Begin
          AH := $10;
          AL := $03;
          BL := $01;
        End;
      Intr($10,Reg);
    End;
End;

Procedure _Border(Attr : Byte);
Var Reg : Registers;
Begin
  If _CGA then
    Port[985] := Attr
  else
    Begin
      Reg.AH :=  $10;
      Reg.AL :=   $1;
      Reg.BH := Attr;
      Intr($10,Reg);
    End;
End;

Procedure _Fine;
Begin
  If _Sound then
    Begin
      Sound(750); Delay(100);
      Sound(500); Delay(100);
      NoSound;
    End;
End;

Procedure _Alert;
var X : Byte;
begin
  if _Sound then for X := 1 to 10 do
    begin
      Sound(750); Delay(17);
      Sound(500); Delay(17);
    end;
  NoSound;
end;

Procedure _Cursor(Up, Down : Byte);
var Reg : Registers;
begin
   with Reg do
     Begin
       AH := 1;
       CH := Up;
       CL := Down;
     End;
   Intr($10,Reg);
end;

Procedure _CursorOff;
begin
   _Cursor(32,32);
end;

Procedure _CursorFull;
begin
   if _Mono then _Cursor(0,12) else _Cursor(0,8);
end;

Procedure _SaveCursor;
var Reg : Registers;
begin
   XCursor  := WhereX;
   YCursor  := WhereY;
   Reg.AH := $03;
   Intr($10,Reg);
   UpCursor := Reg.CH;
   DnCursor := Reg.CL;
end;

Procedure _RestoreCursor;
begin
   _Cursor(UpCursor,DnCursor);
   GotoXY(XCursor,YCursor);
end;

Procedure _SaveAttr;
begin
   _SysAttr := TextAttr;
end;

Procedure _RestoreAttr;
begin
   TextAttr := _SysAttr;
end;

Procedure _SetPage(Page : Byte);
var Reg : Registers;
begin
   Reg.AH := 5;
   Reg.AL := Page;
   Intr($10,Reg);
end;

Procedure _SavePage;
begin
   _SysPage := _CurrentPage;
end;

Procedure _RestorePage;
begin
   _SetPage(_SysPage);
end;

Procedure _SaveAll;
begin
   _SavePage;
   _SaveAttr;
   _SaveCursor;
end;

Procedure _RestoreAll;
begin
   _RestoreCursor;
   _RestoreAttr;
   _RestorePage;
end;

Procedure _WriteXY(XPos,YPos : Byte; St : String);
Var F : Text;
begin
   AssignCrt(F);
   ReWrite(F);
   GotoXY(XPos,YPos);
   Write(F,St);
   Close(F);
end;

Procedure _WriteXYAttr(XPos,YPos,Attr : Byte; St : String);
var Old_Attr : Byte;
begin
   Old_Attr := TextAttr;
   TextAttr := Attr;
   _WriteXY(XPos, YPos, St);
   TextAttr := Old_Attr;
end;

Procedure _WriteXYMem(XPos, YPos : Byte; St : String);
Var C : Byte;
Begin
  If (Length(St) <> 0) then
    For C := XPos to (XPos+Length(St)-1) do
      Mem[_VidSeg:(YPos-1)*160+(C-1)*2] := Ord(St[C-XPos+1]);
End;

Procedure _MemXYAttr(XPos, YPos, Attr, Times : Byte);
Var I : Byte;
Begin
  For I := XPos to XPos + Times do
    Mem[_VidSeg:(YPos-1)*160+(I-1)*2+1] := Attr;
End;

Procedure _Center(Row, Attr : Byte; St : String);
var XPos : Byte;
begin
   If _ScreenHalfWide <> 0 then
     XPos := _ScreenHalfWide - Length(St) Div 2
   Else _Alert;
   _WriteXYAttr(XPos,Row,Attr,St);
end;

Procedure _CenterMem(Row : Byte; St : String);
var XPos, C : Byte;
begin
   If _ScreenHalfWide <> 0 then
     XPos := _ScreenHalfWide - Length(St) Div 2
   Else _Alert;
   for C := 0 to Length(St)-1 do
      Mem[_VidSeg:(Row-1)*160+(XPos+C)*2] := Ord(St[C+1]);
end;

Procedure _ClearKey;
var D : Char;
begin
   while Keypressed do D := ReadKey;
end;

Procedure _Delayer;
begin
  delay(150);
end;

Procedure _InputKey(Var Key : Char);
begin
   _ClearKey;
   repeat
     Key := UpCase(ReadKey);
     If Key = ExtKey then Key := ReadKey;
   until Key IN[Enter,Esc,Space,'O',AltZ];
   If Key = AltZ then _Quit := True;
end;

Procedure _SaveScreen;
begin
   If (_WindowCounter < _MaxWindow) then
     Begin
       If FirstPtr = NIL then
         Begin
           New(ScrSave);
           Move(Scr^,ScrSave^,ScreenMem);
           ScrSave^.Next := NIL;
           ScrSave^.Prev := NIL;
           FirstPtr      := ScrSave;
           LastPtr       := ScrSave;
         End
       else
         Begin
           PrevPtr       := LastPtr;
           New(ScrSave);
           Move(Scr^,ScrSave^,ScreenMem);
           PrevPtr^.Next := ScrSave;
           ScrSave^.Next := NIL;
           ScrSave^.Prev := PrevPtr;
           LastPtr       := ScrSave;
         End;
       Inc(_WindowCounter);
     End
   else
     _Alert;
end;

Procedure _RestoreScreen;
begin
  If (ScrSave <> NIL) AND (_WindowCounter > 0) then
    Begin
      Move(ScrSave^,Scr^,ScreenMem);
      PrevPtr^.Next := NIL;
      LastPtr       := ScrSave^.Prev;
      Dispose(ScrSave);
      ScrSave       := LastPtr;
      Dec(_WindowCounter);
    End
  else
    _Alert;
  If _Intense then _16ColorOn Else _16ColorOff;
end;

Procedure _MakeBox( X1, Y1, X2, Y2, Box_Type : Byte);
var
   CountX,
   CountY        : Byte;
   Box_Char      : String[6];
begin
  case Box_Type of
    0  : Box_Char := '      ';
    1  : Box_Char := 'ÚÀ¿ÙÄ³';
    2  : Box_Char := 'ÉÈ»¼Íº';
    3  : Box_Char := 'ÕÔ¸¾Í³';
    4  : Box_Char := 'ÖÓ·½Äº';
    else Box_Char := '°°°°°°';
  end;
  Mem[_VidSeg:(Y1-1)*160+X1*2-2] := Ord(Box_Char[1]);
  Mem[_VidSeg:(Y2-1)*160+X1*2-2] := Ord(Box_Char[2]);
  Mem[_VidSeg:(Y1-1)*160+X2*2-2] := Ord(Box_Char[3]);
  Mem[_VidSeg:(Y2-1)*160+X2*2-2] := Ord(Box_Char[4]);
  for CountX := X1+1 to X2-1 do
    begin
      Mem[_VidSeg:(Y1-1)*160+CountX*2-2] := Ord(Box_Char[5]);
      Mem[_VidSeg:(Y2-1)*160+CountX*2-2] := Ord(Box_Char[5]);
    end;
  for CountY := Y1+1 to Y2-1 do
    begin
      Mem[_VidSeg:(CountY-1)*160+X1*2-2] := Ord(Box_Char[6]);
      Mem[_VidSeg:(CountY-1)*160+X2*2-2] := Ord(Box_Char[6]);
    end;
end;

Procedure _ShadowBox( X1, Y1, X2, Y2 : Byte);
var
   CountX,
   CountY,
   Attr,
   BitKiller       : Byte;

  Procedure Sincronize;
  begin
    If _Intense AND (Attr >= $80) then
      BitKiller := $77
    else
      BitKiller := $87;
  end;

begin
   for CountX := X1+1 to X2+1 do
     begin
       Attr := Mem[_VidSeg:(Y2)*160+CountX*2+1];
       Sincronize;
       Mem[_VidSeg:(Y2)*160+CountX*2+1] := (Attr AND BitKiller);
     end;
   for CountY := Y1+1 to Y2 do
     begin
       Attr := Mem[_VidSeg:(CountY-1)*160+X2*2+3];
       Sincronize;
       Mem[_VidSeg:(CountY-1)*160+X2*2+3] := (Attr AND BitKiller);
       Attr := Mem[_VidSeg:(CountY-1)*160+X2*2+1];
       Sincronize;
       Mem[_VidSeg:(CountY-1)*160+X2*2+1] := (Attr AND BitKiller);
     end;
end;

Procedure _Clear(X1, X2, Y1, Y2, Attr : Byte);
Begin
  Window(X1,X2,Y1,Y2);
  TextAttr := Attr;
  ClrScr;
  Window(1,1,80,25);
  If _Intense then _16ColorOn Else _16ColorOff;
End;

Procedure _PopBox(X1, Y1, X2, Y2, Box_Type, Attr : Byte);
begin
   if ((X1 < 1) OR (X1 > 79) OR (X1 > X2) OR
       (X2 < 1) OR (X2 > 79) OR
       (Y1 < 1) OR (Y1 > 24) OR (Y1 > Y2) OR
       (Y2 < 1) OR (Y2 > 24)) then
      Begin
        _Alert;
        _ErrMsg(BoxError);
        Exit;
      End;
   _Clear(X1,Y1,X2,Y2,Attr);
   _MakeBox(X1,Y1,X2,Y2,Box_Type);
   _ShadowBox(X1,Y1,X2,Y2);
end;

Procedure _PopCenter(X1, Y1, Box_Type, Attr : Byte);
var CX, CY, P, X2, Y2 : Byte;
begin
   if ((X1<1) OR (X1>39) OR (Y1<1) OR (Y1>12)) then
     Begin
       _Alert;
       _ErrMsg(CenterError);
       Exit;
     End;
    CX := 12-Y1; CY := 40-X1;
    X2 := 80-X1; Y2 := 24-Y1;
    For P := 1 to CX do
      Begin
        _Clear(40-P,12-P,40+P,12+P,Attr);
        If (P=3) then
          Begin
           _MakeBox(40-P,12-P,40+P,12+P,Box_Type);
           Delay(30);
          End;
        Delay(10);
      End;
    P := CX;
    Repeat
      Inc(P,6);
      If P > CY then P := CY;
      _Clear(40-P,Y1,40+P,12+CX,Attr);
      Delay(10);
    Until P=CY;
   _MakeBox(X1,Y1,X2,Y2,Box_Type);
   _ShadowBox(X1,Y1,X2,Y2);
end;

Procedure _PopBox2(X1, Y1, X2, Y2, Box_Type, Attr : Byte);
begin
   if ((X1 < 1) OR (X1 > 79) OR (X1 > X2) OR
       (X2 < 1) OR (X2 > 79) OR
       (Y1 < 1) OR (Y1 > 24) OR (Y1 > Y2) OR
       (Y2 < 1) OR (Y2 > 24)) then
      Begin
        _Alert;
        _ErrMsg(BoxError);
        Exit;
      End;
   _Clear(X1,Y1,X2,Y2,Attr);
   _MakeBox(X1+2,Y1+1,X2-2,Y2-1,Box_Type);
   _ShadowBox(X1,Y1,X2,Y2);
end;

Procedure _PopCenter2(X1, Y1, Box_Type, Attr : Byte);
var CX, CY, P, X2, Y2 : Byte;
begin
   if ((X1<1) OR (X1>39) OR (Y1<1) OR (Y1>12)) then
     Begin
       _Alert;
       _ErrMsg(CenterError);
       Exit;
     End;
    CX := 12-Y1; CY := 40-X1;
    X2 := 80-X1; Y2 := 24-Y1;
    For P := 1 to CX do
      Begin
        _Clear(40-P,12-P,40+P,12+P,Attr);
        If (P=3) then
          Begin
            _MakeBox(40-P,12-P,40+P,12+P,Box_Type);
            Delay(30);
          End;
        Delay(10);
      End;
    P := CX;
    Repeat
      Inc(P,6);
      If P > CY then P := CY;
      _Clear(40-P,Y1,40+P,12+CX,Attr);
      Delay(10);
    Until P = CY;
   _MakeBox(X1+2,Y1+1,X2-2,Y2-1,Box_Type);
   _ShadowBox(X1,Y1,X2,Y2);
end;

Procedure _ShowSwitch(X,Y,F_Attr,B_Attr, Shift,
                      Shift_Attr : Byte; St : String);
var Count : Byte;
begin
   _WriteXYAttr(X,Y,F_Attr,St);
   _WriteXYAttr(X+Shift-1,Y,Shift_Attr,Copy(St,Shift,1));
   for Count := 1 to Length(St) do
      _WriteXYAttr(X+Count,Y+1,_Ground(B_Attr),#223);
   _WriteXYAttr(X+Length(St),Y,_Ground(B_Attr),#220);
end;

Procedure _SwitchAppear(X,Y, Attr : Byte);
Begin
  _ShowSwitch(X,Y,_OkAttr,_Ground(Attr),_OkShift,
          _OkPressedAttr,_OkPrompt);
End;

Procedure _SwitchPressed(X,Y,F_Attr,B_Attr, Shift,
                    Shift_Attr : Byte; St : String);
var Count : Byte;
begin
   for Count := 0 to Length(St) do
     _WriteXYAttr(X+Count,Y,B_Attr,#32);
   for Count := 1 to Length(St) do
      _WriteXYAttr(X+Count,Y+1,B_Attr,#32);
   _WriteXYAttr(X+1,Y,F_Attr,St);
   _WriteXYAttr(X+Shift,Y,Shift_Attr,Copy(St,Shift,1));
end;

Procedure _GetKey(X,Y,F_Attr,B_Attr, Shift, Shift_Attr : Byte;
                  St : String);
begin
  _ShowSwitch(X,Y,F_Attr,B_Attr,Shift,Shift_Attr,St);
  _InputKey(_ChrIO);
  _SwitchPressed(X,Y,F_Attr,B_Attr,Shift,Shift_Attr,St);
  _Delayer;
  _ShowSwitch(X,Y,F_Attr,B_Attr,Shift,Shift_Attr,St);
  _Delayer;
end;

Procedure _KeyEffect(X,Y,F_Attr,B_Attr, Shift,
                    Shift_Attr : Byte; St : String);
begin
  _SwitchPressed(X,Y,F_Attr,B_Attr,Shift,Shift_Attr,St);
  _Delayer;
  _ShowSwitch(X,Y,F_Attr,B_Attr,Shift,Shift_Attr,St);
end;

Procedure _SwitchPressedAppear(X,Y, Attr : Byte);
Begin
  _KeyEffect(X,Y,_OkAttr,_Ground(Attr),_OkShift,
          _OkPressedAttr,_OkPrompt);
End;

Procedure _ErrMsg(St : String);
const ErrErr  = 'Error range on _ERRMSG...';
var
   ErrAttr,
   X              : Byte;
begin
   if ((Length(St) < 5) OR (Length(St) > 67)) then St := ErrErr;
   X := 40 - Length(St) Div 2;
   _SaveScreen;
   If _Intense then
     ErrAttr := 16*Red+White+Blink
   Else
     ErrAttr := 16*Red+White;
   _PopBox(X-5,8,85-X,14,2,ErrAttr);
   _Center(8,_Ground(ErrAttr)+Yellow,' '+Copy(ErrErr,1,6));
   _Center(10,ErrAttr,St);
   _GetKey(35,12,_OkAttr,ErrAttr,_OkShift,
       _Ground(_SwitchAttr)+LightRed,_OkPrompt);
   _RestoreScreen;
end;

Procedure _MakeSure(St_About,St_Msg : String; var Answer : Boolean);
const
   Yes_Prm    = #16' Yes '#17;
   No_Prm     = #16' No  '#17;

var
   Yes_Prompt,
   No_Prompt  : String[9];
   Chg,
   YesNo,
   Sure       : Boolean;
   Sure_Attr,
   X          : Byte;

  Procedure Show_Tag;
  begin
     _ShowSwitch(32,13,_SwitchAttr,Sure_Attr,3,
                _Ground(_SwitchAttr)+Red,Yes_Prompt);
     _ShowSwitch(42,13,_SwitchAttr,Sure_Attr,3,
                _Ground(_SwitchAttr)+Red,No_Prompt);
     if YesNo then
        _ShowSwitch(32,13,_OkAttr,Sure_Attr,3,
          _Ground(_OkAttr)+LightRed,Yes_Prompt)
     else
        _ShowSwitch(42,13,_OkAttr,Sure_Attr,3,
          _Ground(_OkAttr)+LightRed,No_Prompt);
  end;

  Procedure Show_Tag_Prez;
  begin
    Show_Tag;
    if YesNo then
      _SwitchPressed(32,13,_OkAttr,Sure_Attr,3,
        _Ground(_OkAttr)+LightRed,Yes_Prompt)
    else
      _SwitchPressed(42,13,_OkAttr,Sure_Attr,3,
        _Ground(_OkAttr)+LightRed,No_Prompt);
  end;

begin
   Yes_Prompt := Yes_Prm;
   No_Prompt := No_Prm;
   YesNo := True;
   Sure := False;
   X := 35-Length(St_Msg) Div 2;
   _SaveScreen;
   Sure_Attr := 16*Magenta+White;
   _PopCenter(X,9,2,Sure_Attr);
   _Center(9,_Ground(Sure_Attr)+Yellow,St_About);
   _WriteXYAttr(X+5,11,Sure_Attr,St_Msg);
   Chg := True;
   repeat
     If Chg then Show_Tag;
     Chg := True;
     _ChrIO := UpCase(ReadKey);
      case _ChrIO of
        ExtKey  : begin
                    _ChrIO := ReadKey;
                      Case _ChrIO of
                        RgArrow,
                        LfArrow    : YesNo := NOT YesNo;
                        AltZ       : Begin
                                       YesNo := True;
                                       _Quit := True;
                                     End;
                      End;
                      Chg := _ChrIO IN[RgArrow,LfArrow];
                  end;
        Tab,
        Space   : YesNo := NOT YesNo;
        Enter   : begin
                    Sure := True;
                    Show_Tag_Prez;
                  end;
        Esc,
        'N'     : begin
                    Sure  := True;
                    YesNo := False;
                    Show_Tag_Prez;
                  end;
        'Y'     : begin
                    Sure  := True;
                    YesNo := True;
                    Show_Tag_Prez;
                  end;
        else Chg := False;
      end;
   until Sure OR _Quit;
   _Delayer;
   Show_Tag;
   _Delayer;
   _RestoreScreen;
   Answer := YesNo;
end;

Procedure _Anc(St : String; Ok : Boolean; var Sure : Boolean);
var
  Ann_Attr,
  YPos,
  XPos            : Byte;
  Key             : Char;
begin
  Sure := True;
  if Ok then
    YPos := 0
  else
    YPos := 1;
  XPos := 40-Length(St) Div 2;
  _SaveScreen;
  If _Intense then
    Ann_Attr := 16*White+Blue
  Else
    Ann_Attr := 16*Blue+White;
  _PopBox(XPos-5,9+YPos,80-(XPos-5),24-(9+YPos),2,Ann_Attr);
  _WriteXYAttr(XPos,11+YPos,Ann_Attr,St);
  if Ok then
    begin
      _ShowSwitch(35,13,_OkAttr,Ann_Attr,_OkShift,
              _Ground(_SwitchAttr)+LightRed,_OkPrompt);
      _InputKey(Key);
      Sure := ((Key = Enter) OR (UpCase(Key)='O'));
      _KeyEffect(35,13,_OkAttr,Ann_Attr,_OkShift,
               _Ground(_SwitchAttr)+LightRed,_OkPrompt);
    end;
end;

Procedure _Anc2(St : String);
const
  Ann_AttrB = 16*Red+White+Blink;
var
  Ann_Attr,
  XPos     : Byte;
begin
  XPos := 40-Length(St) Div 2;
  _SaveScreen;
  If _Intense then
    Ann_Attr := 16*Red+White+Blink
  Else
    Ann_Attr := 16*Red+White;
  _PopCenter2(XPos-4,10,2,Ann_Attr);
  _WriteXYAttr(XPos,12,Ann_AttrB,St);
end;

Procedure _CloseAnc;
begin
   _RestoreScreen;
end;

Procedure _Hold;
begin
   Repeat Until ReadKey <> ExtKey;
end;

(*-------- Main Program of Unit -------*)

Begin
   If _ScreenType = 1 then
        _VidSeg := $B000
   else
        _VidSeg := $B800;
   New(Scr);
   Scr          := Ptr(_VidSeg,0);
   FirstPtr     := NIL;
   ScrSave      := NIL;
   _OkPrompt    := OkPrm;
   CenterError  := CenterErr;
   BoxError     := BoxErr;
   _MaxWindow   := MemAvail DIV 4096;
End.
