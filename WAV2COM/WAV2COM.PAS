{ Membuat file .COM dari file .WAV, untuk Mikrodata }
{ zeroBIT:L'mirage  STMIK Bina Nusantara 0104920292 }
{                      - Erik, Thanks for your help }

uses dos;

const
  LEN_PSP                  =  256;
  LEN_OBJ                  =  433;
  LEN_WORD_POS             =  $AC;
  SPK_OR_ADLIB             = $1B0;
  TO_ADLIB                 =    0;
  VER_POS                  =  $0E; {alamat relatif posisi
                      kalimat versi dari awal SOUNDIT.COM}
  WAV_LIMIT                = 65535-(LEN_OBJ+LEN_PSP);
                                 {64846}
  OK                       =   0;
  CANCELLED_BY_USR         =   2;
  FILE_NOT_FOUND           =   4; {nilai yang akan dikemba-}
  WAV_FILE_ACCESS_ERROR    =   8; {likan ke DOS}
  NOT_WAV_FILE             =  10;
  FILE_TOO_BIG             =  16;
  COM_FILE_ACCESS_ERROR    =  32;
  FILE_PROCESS_ERROR       =  64;
  FILE_CLOSING_ERROR       = 128;

const cpy                  : string[50] =
  #13'*** WAV2com:r95.01:(c)1995,MikroDATA/mirage'#10;
      version              : array[0..4] of char = '95.01';

function AddExt(fn : pathstr; ext : extstr) : string;
var D: DirStr;   {fungsi mengganti ekstensi file}
    N: NameStr;
    E: ExtStr;
begin
  fsplit(fn,d,n,e);
  AddExt := d + n + ext;
end;

procedure quit(st : string; haltcode : word);
begin
  writeln(#13#10+'fatal!:'+st);
  halt(haltcode)
end;

procedure SOUNDIT_OBJ; external;
{$L SOUNDWAV.OBJ}

type
  stream      = array[0..LEN_OBJ-1] of byte;
  pwavheader  = ^twavheader;
  twavheader  = record
                 id1       : array[0..3] of char;
                 size      : longint;
                 id2       : array[$8..$F] of char;
                 dontcare1 : longint;
                 dontcare2 : word;
                 mode      : word;
                 freq      : longint;
                 dontcare3 : longint;
                 dontcare4 : word;
                 sampling  : word;
                 id3       : array[$24..$27] of char;
                end;
const
  wavplaymode              : array[1..2] of string[6] =
                             ('mono','stereo');

var
  swav, scom               : string;
  ftwav, ftcom             : file;
  bptr                     : ^stream;
  wptr                     : ^word;
  wavheader                : twavheader;
  i, numread, numwrit      : word;
  wavlen                   : longint;
  buff                     : array[0..2047] of byte;
  ch                       : char;

function readkey : char;
inline($b4/0/$cd/$16);

procedure quit_process_file;
begin
  close(ftwav);
  close(ftcom);
  quit('gagal mengolah file',FILE_PROCESS_ERROR);
end;

begin
  write(cpy+#13#10+
  'WAV2com akan membuat file COM dari file WAV'+
     #13#10+#10+'NamaFile [.WAV]'#9#9#9': ');
  readln(swav);
  if (swav = '') then
    quit('dibatalkan oleh pemakai',CANCELLED_BY_USR);

  if (pos('.',swav) = 0) then swav := addext(swav,'.WAV');
  if (FSearch(swav, '') = '') then
    quit('file '+swav+' tidak ditemukan',
             FILE_NOT_FOUND);

  {$i-}
  assign(ftwav,swav);
  reset(ftwav,1);
  blockread(ftwav,wavheader,sizeof(wavheader),numread);
  {$i+}

  if (ioresult <> OK) or (numread <> sizeof(wavheader)) then
    quit('kesalahan akses file WAV',WAV_FILE_ACCESS_ERROR);

  with wavheader do begin
    writeln;
      {buang perintah ini jika anda ingin menggunakan}
      {data suara bukan WAV}
    if id2[$8]+id2[$9]+id2[$A] <> 'WAV' then
        quit('Bentuk file bukan WAV',NOT_WAV_FILE);

    wavlen := size + 8 - sizeof(wavheader);

    writeln(#9#9'Ukuran data WAV = ',wavlen     ,' byte');
    writeln(#9#9'Modus           = ',wavplaymode[mode]);
    writeln(#9#9'Frekwensi       = ',freq       ,' Hz');
    writeln(#9#9'Besaran data    = ',sampling   ,' bit');

    if (wavlen > WAV_LIMIT) then
      quit('file WAV harus lebih kecil dari 64846 byte',
         FILE_TOO_BIG);
  end;

  write(#13#10'NamaFile [',addext(swav,'.COM'),']'#9#9': ');
  readln(scom);

  if (scom = '') then
    scom := addext(swav,'.COM')
  else
    if (pos('.',scom) = 0) then
      scom := addext(scom,'.COM');

  write(#13#10'Keluaran WAV ke [I]nternal speaker atau ke '+
         '[S]oundcard ? ');
  repeat
    ch := upcase(readkey);
  until ch in ['I','S'];
  writeln(ch);

  write(#13#10'mengolah '+swav+' ke '+scom+' [',
                wavlen+LEN_OBJ,' byte]... ');

  {$i-}
  assign(ftcom,scom);
  rewrite(ftcom,1);
  {$i+}
  if (ioresult <> OK) then
    quit('kesalahan akses file COM',COM_FILE_ACCESS_ERROR);

  bptr  := @SOUNDIT_OBJ;         {tunjuk ke awal routine &}
  wptr  := @bptr^[LEN_WORD_POS]; {lakukan perubahan sesuai}
  wptr^ := word(wavlen);         {dengan data file .WAV}
  for i := 0 to 4 do
      bptr^[VER_POS+i] := byte(version[i]);
  if ch='S' then bptr^[SPK_OR_ADLIB] := TO_ADLIB
    else bptr^[SPK_OR_ADLIB] := TO_ADLIB+1;
                                   {tulis versi WAV2com}
  {$i-}                            {di file .COM}
  write('(  0%)');
  blockwrite(ftcom,bptr^[0],LEN_OBJ,numwrit);

  if numwrit <> LEN_OBJ then
    quit_process_file
  else
    i := LEN_OBJ;
  repeat
    blockread(ftwav,buff,sizeof(buff),numread);
    blockwrite(ftcom,buff,numread,numwrit);
    if (ioresult <> OK) then quit_process_file;
    inc(i,numwrit);
    write(#8#8#8#8#8#8'(',
        (i div ((wavlen+LEN_OBJ) div 100)):3,'%)');
  until (numread = 0) or (numread < numwrit);
  close(ftwav);
  close(ftcom);
  {$i+}
  if (ioresult <> OK) then
    quit('gagal menutup file',FILE_CLOSING_ERROR);

  writeln(#13#10#10'*** WAV2com Oke!');
end.
