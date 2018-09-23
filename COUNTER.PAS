(*------------------------------------------------*)
(*--- Program penghitung Boot-Up dari Harddisk ---*)
(*    Diprogram oleh  :  A Nugraha                *)
(*                       Divisi Utility           *)
(*                       ZeroBit Soft.Dev         *)
(*----------------- 92.05.23.22.42 ---------------*)
(*----------------- 92.09.06.09.17 ---------------*)

Uses Dos;

const
   Head          = 'COUNTER Release 1.0 þ (c)1992 ZeroBit';
   Counter_File  = 'C:\COUNTER.INI';
   Error         = 'Error opening file...';
   Help          = 'Usage : C:\>COUNTER [/C] [/D] <enter>';
   Boot_Dat      = 'Boots up counter : ';

var
   Str_Buff  : String[2];
   Chr_Buff  : Char;
   Counter   : Longint;
   FL        : Text;
   Add_Up    : Boolean;

procedure Quit(St : String);
begin
   WriteLn(St); Halt(2);
end;

procedure Delayer(L : Byte);
var I, J : Byte;
begin
  for I := 0 to L do
    for J := 1 to 30 do
      begin
      end;
end;

procedure Scream;
var I : Byte;
begin
  Port[97] := Port[97] OR 3;      { Turn On Speaker }
  for I := 0 to 255 do
    begin
      Port[66] := 255;
      Delayer(15);
    end;
  Port[97] := Port[97] AND 252;   { Turn Off Speaker }
end;

procedure Access;
begin
   {$I-}
   Assign(FL,Counter_File);
   SetFAttr(FL,$20); {Archive}
   Reset(FL);
   if IOResult <> 0 then Quit(Error);
   ReadLn(FL,Counter);
   if Add_Up then
     begin
       Inc(Counter);
       ReWrite(FL);
       WriteLn(FL,Counter);
     end;
   if (Counter Mod 100) = 0 then Scream;
   Close(FL);
   SetFAttr(FL,$03); {ReadOnly AND Hidden}
   {$I+}
end;

begin
   Str_Buff := '';
   Add_Up := False;
   Str_Buff := ParamStr(1);
   Chr_Buff := UpCase(Str_Buff[2]);
   case Chr_Buff of
     'C'    : begin
                 Add_Up := True; Access;
              end;
     'D'    : begin
                 WriteLn(Head);
                 Add_Up := False; Access;
                 WriteLn(Boot_Dat,Counter);
              end;
     else
       begin
         WriteLn(Head);
         Quit(Help);
       end;
   end;
end.