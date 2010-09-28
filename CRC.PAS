
             Пакет CRC32 предназначен  для  вычисления  4-байтового  конт-
        рольного кода любой последовательности байтов по алгоритму, приме-
        няемому, в частности, в архиваторах PKZIP и ARJ.  Распространяется
        SOURCEWARE (свободно с исходным текстом). Написан на Ассемблере  и
        Турбо Паскале 6.0. Поскольку основу пакета составляют ассемблерные
        модули и в документации дано словесное описание  алгоритма,  может
        применяться как пособие для разработки на других языках.

             Для контакта:
                    277028 Молдова, Кишинев,
                    ул. Академии 5,
                    Институт математики АН Молдовы,
                    Колесников Александр Евгеньевич
                    Тел.: (код 0422) 73-80-58, 72-59-82 (дирекция).


{------------------------------ CRC32.DOC ----------------------------------}
                        ----- Пакет CRC32, версия 2 -----
                 ----- Вычисление контрольного кода CRC-32 -----
                     ----- Турбо Паскаль 6.0, Ассемблер -----

             Торговые марки:
        - PKZIP принадлежит PKWARE, Inc.;
        - ARJ принадлежит Роберту К. Янгу (Robert K Jung).;
        - Turbo PASCAL и Turbo Assembler принадлежат  Borland  Internatio-
          nal, Inc.;
        - Turbo Professional принадлежит TurboPower Software.

             CRC32 распространяется по принципу SOURCEWARE  -  свободно  с
        исходным текстом. Он может быть свободно  использован  кем  угодно
        для некоммерческих целей. Его можно распространять,  сохраняя  имя
        автора и не внося никаких изменений.

             CRC32 распространяется AS-IS, то есть, автор отвергает всякую
        ответственность и весь возможный риск ложится на пользователя.

             Copyright (C) 1991, А.Е. Колесников.

             CRC32 состоит из следующих компонент:

        Имя файла   Размер     Дата    Время    CRC-32  Примечание
        ------------------------------------------------------------------
        README.1ST     818 22/05/92 16:00:00  824ccfd3
        CRC32.ASM     2301 28/12/91 19:00:00  020520f1  Для TASM 2.0
        CRC32.DOC     5024 22/05/92 16:00:00  ????????  Этот документ
        CRCDIR.EXE   31296 28/12/91 19:00:00  f8b3583d  После TP 6.0
        CRCTEST.EXE  17072 28/12/91 19:00:00  ba25b170  После TP 6.0
        CRC32.OBJ      343 28/12/91 19:00:00  aa6a19b7  После TASM 2.0
        CRC32.PAS     3300 28/12/91 19:00:00  02e41cfc  Для TP 6.0
        CRCDIR.PAS   10173 28/12/91 19:00:00  a601852c  Печать оглавлений
        CRCTEST.PAS    385 28/12/91 19:00:00  4111c388  Простой пример
        CRC32.TPU     1568 28/12/91 19:00:00  82ea9dec  После TP 6.0
        TPCRT.TPU    26880 04/01/90 05:09:00  0d0d92cc  \ Из Turbo Profes-
        TPDOS.TPU    12448 04/01/90 05:09:00  3b97da9b  | sional 5.09 для
        TPHEAP6.TPU    432 04/01/90 05:09:00  1ad325dd  | CRCDIR.PAS
        TPINLINE.TPU  1792 04/01/90 05:09:00  7ae6f42d  | (доработка
        TPSTRING.TPU 14608 04/01/90 05:09:00  ed9673d9  /  к Паскалю 6.0)
        ------------
        Всего 15 файлов
--------------------------------------------------------------------------
!!! Примечание составителя:
    Бинарные файлы и модули из библиотеки Turbo Professional 5.09
    НЕ ВКЛЮЧЕНЫ по понятным причинам
--------------------------------------------------------------------------
             Модуль CRC32.TPU вычисляет контрольный код CRC-32 для  задан-
        ной последовательности байтов. Это тот самый контрольный код,  ко-
        торый используется архиваторами PKZIP фирмы PKWARE,  Inc.,  и  ARJ
        Роберта К. Янга. Известно, что CRC-32 вычисляется на неупакованном
        файле.

             Для вычисления CRC-32 заданной последовательности байтов надо
        применить три процедуры. Первая - InitCRC - инициализирует  CRC-32
        значением $FFFFFFFF. Затем надо помещать порции заданной  последо-
        вательности в буфер и для каждой порции вызывать IncCRC.  В  конце
        FinishCRC инвертирует все биты результата.

             Две другие функции, CRCFileB и  CRCFile,  позволяют  получить
        CRC-32 заданного файла. Они возвращают целый результат -  значение
        IOResult, полученное в процессе чтения (порции)  файла.  Если  ре-
        зультат -  0, все в порядке; ненулевой результат  означает  ошибку
        чтения.

             Включены две демонстрационные программы -  CRCTEST и CRCDIR.

             Две основные программы реализованы на TASM 2.0, остальные  на
        Turbo PASCAL 6.0 с использованием Turbo Professional 5.09.

             CRC-32 инициализируется значением $FFFFFFFF. Потом для каждо-
        го байта B входной последовательности CRC-32 сдвигается вправо  на
        1 байт. Если байты CRC-32 были {C1,C2,C3,C4} (C1 - старший,  C4  -
        младший), сдвиг дает {0,C1,C2,C3}. Младший байт C4 побитно склады-
        вается с B по модулю 2 (C4 xor B). Новым  значением  CRC-32  будет
        его сдвинутое значение, сложенное побитно  по  модулю  2  (xor)  с
        4-байтовой величиной  из  "магической"  таблицы  с  использованием
        [B xor C4] в качестве индекса.
             Было: CRC-32 = {C1,C2,C3,C4} и получили очередной байт B.
             Стало:
                   CRC-32 = { 0,C1,C2,C3} xor Magic[B xor C4].
             На Паскале:
             CRC := (CRC shr 8) xor Magic[B xor byte(CRC and $FF)];
             (здесь CRC - longint, Magic - array[byte] of longint).

             Последний этап вычисления CRC-32 - инвертировать все биты:
        CRC := not CRC;

             Инициализация магической таблицы очень сложна и я  воздержусь
        от ее описания здесь. Почитайте CRC32.ASM.

             Очевидное применение этих алгоритмов -  проверка  целостности
        файлов.

             Для контакта:
                      277028 Молдова, Кишинев,
                      ул. Академии 5,
                      Институт математики АН Молдовы,
                      Колесников Александр Евгеньевич
                      Тел.: (код 0422) 73-80-58, 72-59-82 (дирекция).


{------------------------ CRC32.PAS -----------------------------------------}
{$B-,D-,F-,I-,R-,S-,V-}
unit CRC32;

{ This unit is to obtain CRC-32 check code as it is evaluated by
  PKZIP of PKWARE, Inc., and ARJ by Robert K Jung. }

interface

  procedure InitCRC(var CRC: longint);
  { Initialize CRC-32 before evaluation }

  procedure IncCRC(var Buff; Count: word; var CRC: longint);
  { Accumulate CRC-32 for Count bytes from buffer Buff }

  procedure FinishCRC(var CRC: longint);
  { Complete CRC-32 evaluation }

  function CRCFileB(FileName: string;
                    var Buff; BuffLen: word; var CRC: longint): word;
  { Evaluate CRC-32 of a given file through user-disposed buffer;
    returns 0 if file is OK, IOResult on file error, $FFFF on BuffLen = 0 }

  function CRCFile(FileName: string; var CRC: longint): word;
  { Evaluate CRC-32 of a given file using GetMem for buffer;
    returns 0 if file is OK, IOResult on file error }

implementation

  const Magicon: longint = $EDB88320; { Constant used to fill array Magic }

  var Magic: array[byte] of longint;  { Table used to translate bytes to
                                        CRC-32 increments }

  procedure InitCRC(var CRC: longint);
  { Initialize CRC-32 before evaluation }
  begin
    CRC := $FFFFFFFF;
  end { InitCRC };

  {$F+}

  procedure InitMagic; external;

  procedure IncCRC(var Buff; Count: word; var CRC: longint); external;
  { Accumulate CRC-32 for Count bytes from buffer Buff }

  {$F-}

  {$L CRC32.OBJ}

  procedure FinishCRC(var CRC: longint);
  { Complete CRC-32 evaluation }
  begin
    CRC := not CRC;
  end { FinishCRC };

  function CRCFileB(FileName: string;
                    var Buff; BuffLen: word; var CRC: longint): word;
  { Evaluate CRC-32 of a given file through user-disposed buffer;
    returns 0 if file is OK, IOResult on file error, $FFFF on BuffLen = 0 }
    var
      Rest: longint;
      Portion, IOError, SaveFileMode: word;
      Fi: file;
  begin
    if BuffLen = 0 then begin
      CRC := 0; CRCFileB := $FFFF; Exit;
    end;
    SaveFileMode := FileMode;
    FileMode := 0;
    Assign(Fi, FileName);
    Reset(Fi, 1);
    IOError := IOResult;
    if IOError <> 0 then begin
      CRC := 0; CRCFileB := IOError; Exit;
    end;
    InitCRC(CRC);
    Rest := FileSize(Fi);
    IOError := IOResult;
    if IOError <> 0 then begin
      CRC := 0; CRCFileB := IOError; Close(Fi); Exit;
    end;
    while Rest > 0 do begin
      Portion := BuffLen;
      if Portion > Rest then Portion := Rest;
      BlockRead(Fi, Buff, Portion);
      IOError := IOResult;
      if IOError <> 0 then begin
        CRC := 0; CRCFileB := IOError; Close(Fi); Exit;
      end;
      IncCRC(Buff, Portion, CRC);
      Dec(Rest, Portion)
    end;
    Close(Fi);
    FileMode := SaveFileMode;
    FinishCRC(CRC);
    CRCFileB := 0;
  end { CRCFileB };

  function CRCFile(FileName: string; var CRC: longint): word;
  { Evaluate CRC-32 of a given file using GetMem for buffer;
    returns 0 if file is OK, IOResult on file error }
    const MaxBuffLen = 65520;
    var pBuff: ^char;
  begin
    GetMem(pBuff, MaxBuffLen);
    CRCFile := CRCFileB(FileName, pBuff^, MaxBuffLen, CRC);
    FreeMem(pBuff, MaxBuffLen)
  end { CRCFile };

begin
  InitMagic;
end.


{----------------------- CRC32.ASM -----------------------------------------}
                .MODEL  TPASCAL

                .DATA

                EXTRN   Magic : DWORD            ; 256-DWORD array
                EXTRN   Magicon : DWORD          ; Magic constant

                .CODE

InitMagic       PROC FAR
                PUBLIC  InitMagic

                std
                push    ds
                pop     es
                mov     di,OFFSET Magic+03FEh    ; Last WORD of the array
                push    bp
                mov     bp,0FFh
im0:
                mov     cx,8
                mov     dx,bp
                xor     ax,ax
im1:
                shr     ax,1
                rcr     dx,1
                jnc     im2
                xor     dx,WORD PTR Magicon
                xor     ax,WORD PTR Magicon+2
im2:
                loop    im1
                stosw
                xchg    ax,dx
                stosw
                dec     bp
                jns     im0
                pop     bp
                ret

InitMagic       ENDP

IncCRC          PROC FAR pBuff:DWORD,Count:WORD,pCRC:DWORD
                PUBLIC  IncCRC

                les     si,pCRC
                mov     cx,es:[si]
                mov     dx,es:[si+2]
                mov     di,OFFSET Magic
                les     si,pBuff
                cld
                push    bp
                mov     bp,Count
                inc     bp
                jmp     SHORT ic1
ic0:
                xor     ax,ax
                lods    BYTE PTR es:[si]
                mov     bx,ax
                xor     bl,cl
                mov     cl,ch
                mov     ch,dl
                mov     dl,dh
                mov     dh,bh
                shl     bx,1
                shl     bx,1
                xor     cx,[bx+di]
                xor     dx,[bx+di+2]
                test    si,si
                jnz     ic1
                mov     ax,es
                add     ax,1000h
                mov     es,ax
ic1:
                dec     bp
                jnz     ic0
                pop     bp
                les     si,pCRC
                mov     es:[si],cx
                mov     es:[si+2],dx
                ret

IncCRC          ENDP

CODE            ENDS

                END


{------------------------- CRCDIR.PAS --------------------------------------}
{$B-,D-,F-,I+,R-,S-,V-}
{$M 65520,65535,655360}
program CRCDir;

  uses
    Dos, TPCrt, TPString, TPDos, CRC32;

  const
    MaxWidth = 80;

  var
    Out: text;
    Options: string;
    Masks: array[1..64] of string;
    LineCount, NMasks: word;
    b, DisplayCRC, Help, Page, SubDirs, Wide: Boolean;
    ClustersAvailable, TotalClusters, BytesPerSector, SectorsPerCluster: word;
    BytesPerCluster: longint;

  procedure WaitAKey;
    var c: char;
  begin
    while KeyPressed do begin
      c := ReadKey; if c = #0 then c := ReadKey;
    end;
    repeat until KeyPressed;
    c := ReadKey; if c = #0 then c := ReadKey;
  end { WaitAKey };

  procedure WriteLine(s: string);
  begin
    if CtrlBreakFlag then Halt;
    Writeln(Out, s);
    if Page then begin
      Inc(LineCount);
      if LineCount = CurrentHeight then begin
        Write('...press any key...'); WaitAKey; Writeln; LineCount := 0;
      end;
    end;
  end { WriteLine };

  procedure HelpInfo;
  begin
    WriteLine('CRCDIR [mask ...] [/HNPSW]');
    WriteLine('   mask   - 0, 1, or more filename masks;');
    WriteLine('            dir, path, wildcards are OK, default is *.*;');
    WriteLine('   /HNPSW - 0..5 options;');
    WriteLine('   /H, /? - this Help info;');
    WriteLine('   /N     - No CRC-32 display;');
    WriteLine('   /P     - display one Page at a time;');
    WriteLine('   /S     - scan Subdirectories;');
    WriteLine('   /W     - Wide display.');
    WriteLine('');
  end { HelpInfo };

  procedure LastHelp;
  begin
    if not Help then begin
      if Page then begin
        WriteLine('CRCDIR /? - help info.');
        if LineCount <> 0 then WriteLine('') end
      else begin
        Writeln('CRCDIR /? - help info.');
        Writeln;
      end;
    end;
    if Page and (LineCount <> 0) then begin
        Write('...press any key...'); WaitAKey; Writeln;
    end;
  end { LastHelp };

  procedure ScanParms;
    var
      DriveLetterPos: array['A'..'Z'] of word;
      c: char;
      i: word;
      s: string;
  begin
    Options := '';
    DriveLetterPos['A'] := 1;
    for c := 'B' to 'Z' do DriveLetterPos[c] := 0;
    for i := 1 to ParamCount do begin
      s := StUpcase(ParamStr(i));
      if s[1] = '/' then
        Options :=  Options + s
      else begin
        if (Length(s) < 2) or (s[2] <> ':') then
          c := DefaultDrive
        else
          c := s[1]; { Drive letter };
        if c <> 'Z' then Inc(DriveLetterPos[Succ(c)]);
      end;
    end;
    for c := 'B' to 'Z' do Inc(DriveLetterPos[c], DriveLetterPos[Pred(c)]);
    NMasks := 0;
    for i := 1 to ParamCount do begin
      s := StUpcase(ParamStr(i));
      if s[1] <> '/' then begin
        if (Length(s) < 2) or (s[2] <> ':') then
          s := DefaultDrive + ':' + s;
        c := s[1];
        if c < Chr(Ord('A')+NumberOfDrives-1) then begin
          Inc(NMasks);
          Masks[DriveLetterPos[c]] := s; Inc(DriveLetterPos[c]);
        end;
      end;
    end;
    DisplayCRC := (Pos('N', Options) = 0);
    Help := (Pos('?', Options) <> 0) or (Pos('H', Options) <> 0);
    Page := (Pos('P', Options) <> 0) and HandleIsConsole(StdOutHandle);
    LineCount := 0;
    if Help then HelpInfo;
    SubDirs := (Pos('S', Options) <> 0);
    Wide := (Pos('W', Options) <> 0);
    if NMasks = 0 then begin
      if Help and DisplayCRC and
         not Page and not Subdirs and not Wide
      then Halt;
      NMasks := 1;
      Masks[1] := DefaultDrive + ':*.*';
    end;
  end { ScanParms };

  {$I-}
  procedure DisplayDirectory(Mask, LeadIn: string);
    var
      F: SearchRec;
      Count, FCount, DirCount, TotalClu, Clu, w: word;
      S: string;
      T: DateTime;
      CRC, Total : longint;
    procedure DisplayFile;
    const
      MonthStr: array[0..12] of string[3] = (
        '   ',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    begin
      if Wide then begin
        w := Length(S);
        if (F.Attr and Directory) = 0
        then S := S + Pad(F.Name, 13)
        else S := S + Pad(F.Name+'\', 13);
        if DisplayCRC then begin
          if (F.Attr and Directory) = 0 then begin
            if CRCFile(LeadIN+F.Name, CRC) = 0
            then S := S + ' ' + StLocase(HexL(CRC))
            else S := S + '  -Error-'; end
          else
            S := S + ' --------'
        end;
        S := S + '  ';
        if 2*Length(S) - w > MaxWidth then begin
          WriteLine(S); S := '';
        end; end
      else begin
        Str(Count: 5, S);
        S := S  + ' ';
        if (F.Attr and Directory) = 0
        then S := S +
                  Pad(F.Name, 13) +
                  LeftPad(Long2Str(F.Size), 11) + ' ' +
                  LeftPad(Long2Str(Clu), 5)
        else S := S + Pad(F.Name+'\', 13) + ' -Directory      ';
        if (F.Attr and Hidden) = 0
        then S := S + ' .'
        else S := S + ' H';
        if (F.Attr and SysFile) = 0
        then S := S + '.'
        else S := S + 'S';
        if (F.Attr and ReadOnly) = 0
        then S := S + '.'
        else S := S + 'R';
        if (F.Attr and Archive) = 0
        then S := S + '. '
        else S := S + 'A ';
        UnpackTime(F.Time, T);
        if (T.Month < 1) or (12 < T.Month) then T.Month := 0;
        S := S + ' ' +
             MonthStr[T.Month] + '-' +
             LeftPadCh(Long2Str(T.Day), '0', 2) + '-' +
             Long2Str(T.Year) + ' ' +
             LeftPadCh(Long2Str(T.Hour), '0', 2) + '.' +
             LeftPadCh(Long2Str(T.Min), '0', 2) + '.' +
             LeftPadCh(Long2Str(T.Sec), '0', 2);
        if DisplayCRC then begin
          if (F.Attr and Directory) = 0 then begin
            if CRCFile(LeadIN+F.Name, CRC) = 0
            then S := S + ' ' + StLocase(HexL(CRC))
            else S := S + '  -Error-'; end
          else
            S := S + ' --------';
        end;
        WriteLine(S); S := '';
      end
    end { DisplayFile };
  begin
    Count := 0; FCount := 0; DirCount := 0; TotalClu := 0; Total := 0;
    S := '';
    WriteLine('Directory of '+Mask);
    WriteLine('');
    if not Wide then begin
      S := '    # Filename.Ext        Size   Clu Attr         Date     Time';
      if DisplayCRC then S := S + '   CRC-32';
      WriteLine(S);
      if DisplayCRC then S := CharStr('-', 72) else S := CharStr('-', 63);
      WriteLine(S);
    end;
    FindFirst(Mask, ReadOnly+Hidden+SysFile+Directory+Archive, F);
    while DosError = 0 do begin
      Inc(Count);
      if (F.Attr and Directory) = 0 then begin
        Inc(FCount);
        Inc(Total, F.Size);
        Clu := (F.Size + BytesPerCluster - 1) div BytesPerCluster;
        Inc(TotalClu, Clu); end
      else
        Inc(DirCount);
      DisplayFile;
      FindNext(F);
    end;
    if S <> '' then WriteLine(S);
    if not Wide then begin
      if DisplayCRC then S := CharStr('-', 72) else S := CharStr('-', 63);
      WriteLine(S);
    end;
    Str(FCount: 5, S);
    S := S  +
         ' file(s)      ' +
         LeftPad(Long2Str(Total), 11) + ' ' +
         LeftPad(Long2Str(TotalClu), 5) + '=' +
         LeftPad(Long2Str(BytesPerCluster*longint(TotalClu)), 11);
    WriteLine(S);
    Str(DirCount: 5, S);
    S := S +
         ' dir(s)             Total;  Clu=       Used';
    WriteLine(S);
    WriteLine('') ;
  end { DisplayDirectory };
  {$I+}

  procedure ProcessMask(Mask, LeadIn: string); forward;

  {$I-}
  procedure ScanSubdirectories(Path, FileMask: string);
    var
      S: SearchRec;
  begin
    FindFirst(Path+'*.*', Directory, S);
    while DosError = 0 do begin
      if (S.Name[1] <> '.') and ((S.Attr and Directory) <> 0) then
        ProcessMask(Path+S.Name+'\'+FileMask, Path+S.Name+'\');
      FindNext(S);
    end;
  end { ScanSubdirectories };
  {$I+}

  procedure ProcessMask(Mask, LeadIn: string);
  begin
    DisplayDirectory(Mask, LeadIn);
    if SubDirs then ScanSubdirectories(LeadIn, JustFileName(Mask));
  end { ProcessMask };

  {$I-}
  procedure DisplayVolId(Drive: char);
    var V: SearchRec;
  begin
    FindFirst(Drive+':\*.*', VolumeId, V);
    while DosError = 0 do begin
      if (V.Attr and VolumeId) <> 0 then begin
        if Length(V.Name) > 8 then Delete(V.Name, 9, 1);
        WriteLine('Volume in drive '+Drive+': is '+V.Name);
        WriteLine('');
        Exit;
      end;
      FindNext(V);
    end;
    WriteLine('Volume in drive '+Drive+': has no label');
    WriteLine('');
  end { DisplayVolId };
  {$I+}

  procedure DisplayFreeBytes(Drive: char);
    var
      f: longint;
      s: string;
  begin
    f := longint(ClustersAvailable) *  BytesPerCluster;
    s := ' Volume in drive ' + Drive + ': cluster(s) ' +
         LeftPad(Long2Str(ClustersAvailable), 5) + '=' +
         LeftPad(Long2Str(f), 11) + ' byte(s) free';
    WriteLine(s);
    WriteLine('');
  end { DisplayFreeBytes };

  procedure ScanMasks;
    var
      i, j, p: word;
      Drive: char;
      SearchMask, LeadIn, s: string;
      bDisk, bMask: Boolean;
  begin
    for i := 1 to NMasks do begin
      Drive := Masks[i][1];
      if (i = 1) or (Drive <> Masks[i-1][1]) then begin
        bDisk := GetDiskInfo(Ord(Drive)-64,
                             ClustersAvailable, TotalClusters,
                             BytesPerSector, SectorsPerCluster);
        if bDisk then begin
          BytesPerCluster :=
            longint(BytesPerSector) * longint(SectorsPerCluster);
          DisplayVolId(Drive);
        end;
      end;
      if bDisk then begin
        s := FExpand(Masks[i]);
        bMask := ParsePath(s, SearchMask, LeadIn);
        if bMask then ProcessMask(SearchMask, LeadIn);
      end;
      if bDisk and ((i = NMasks) or (Drive <> Masks[i+1][1])) then
        DisplayFreeBytes(Drive);
    end;
  end { ScanMasks };

begin
  b := OpenStdDev(Out, StdOutHandle);
  ScanParms;
  ScanMasks;
  LastHelp;
  Close(Out);
end.


{------------------------ CRCTEST.PAS --------------------------------------}
{$B-,D-,F-,I+,R-,S-,V-}
program CRCTest;

  uses TPString, CRC32;

  var
    InpFN: string;
    CRC: longint;

begin
  repeat
    Write('Input filename? '); Readln(InpFN);
    if CRCFile(InpFN, CRC) = 0 then
      Writeln('File ', StUpcase(InpFN), ' has CRC-32 = $',HexL(CRC))
    else
      Writeln('Error in file ', StUpcase(InpFN));
  until InpFN = '';
end.



{http://www.warsh.com - Библиотека программиста - http://bp.da.ru}
{Более 100 исходников, более гигабайта русской документации, не верите?}
{Зайдите, посмотрите! Удачной компиляции!}
