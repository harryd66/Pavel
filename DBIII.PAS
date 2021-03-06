{$A+,B-,D-,E-,F-,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X+,Y-}
{-------------------- DBIII.PAS -----------------------------------------}
unit dbIII;{��p�� 3.01 05-04-94}

{         ����� ��� p����� � ������ ������ �p��� dBase III
               (�) Copyright 1993-1994 by Shakirov S.R.


   �ᯮ�짮����� � Turbo Pascal 5.5 � Borland/Turbo Pascal 7.0

   ����� ����� �����筮 ����� ��室���� � ��ᯫ��樨 � p�������
       �p��p�����, p������� ᮢ���⭮ � �p㣨�� �p��p������,����ᠭ�묨
       �� Clipper 5.01, FoxPro 1.5, FoxPro 2.5, FoxPro 2.5a � �� ᮤ�p���
       �� �訡�� (�� �������� p��p�襭�� ��p���p� ��)

   �������� :
       � ����/�����뢠�� ���� ��
       � 㧭��� ��p���p� �������饩 ��
       � ᮧ������ ����� ��
       � p������ � �������� ���� (�p���p��� � NetWare 2.15, 2.2, 3.11r)
       � �᪠�� ����� �� ���祭�� ���� (������ Find ... Continue)
       � ᮧ������ "��᫥������" � ���p�� �� ���� ��������� ��⮤��
               p���������� ����室��� �㭪樨 (���p���p 䨫��p�,�p�p����,
               p����� � 㤠����묨 �����ﬨ,ᦠ⨥ ��,�ᯮ�짮����� ��⥬�
               �p�����権 �p� p���� � �� � �.�.)

   �������� �p������ :
       � �᫨ �� �������p����� ������,� �� ������ �� p�������p�����,�.�.
             �� �� �������� ��⮬���᪨
       � � Memo ���ﬨ �p��� ��� � FoxPro (�᫨ �� ���,�⮡ p�ᯮ�-
             ������� �������� ��⮬���᪨, � � ��⮤� Open ���� ��
             ����� ID ��p������� DBT- ��� FPT-䠩� �ᯮ������)
       � � ᨬ����묨 ���ﬨ ������� 255 ����,�� �������� � Clipper (�
             �⮬ 䠩�� ���� ����� ���� ���p���� ��� �� ��p�����,�᫨
             �祭� ����� p������ � ����)
       � �᫨ �� "��������" ���� p��᪨� �㪢���,� �p㣨� ���� �� ���筮
             �� �p������

   �p�������e
       � c������� ���� ����� :
          C - ᨬ������ ����, ����� 1-254 ᨬ�����
          N - �᫮��� ����,��p�������� ��饩 ������ � ������⢮� ��p ��᫥ �窨
          F - �᫮ � ������饩 �窮�(� �� ���� 祬 ��� ⨯ �⫨砥��� �� �p����饣�)
          L - �����᪮� ����, ����� 1
          D - ���, ����� 8 ᨬ�����, �p��� YYyyMmDd
          M - memo ���� ,����� 10, �� ������ ᮤ�p���� ᨬ���� #0 ��� #26
       � �������p�樮��� �p���p� :
          dbCreate.pas - ᮧ����� �� � ������ � ���
          OpenRead.pas - ��p�⨥/�⥭�� �� ��
          Structur.pas - ��p�������� ��p���p� ��
            dbIIIa.pas - ��p���� p������樨 䨫��p� ��� ���� ������
            Filter.pas - �p���p �ᯮ�짮����� 䨫��p�

   �� ShareWare �p����.����᪠���� ᢮������ p��p���p������ � �ᯮ�짮-
          ����� � �������p�᪨� 楫��,� �᫮���� ������ ��p���� ⥪�⮢
          ��� ���������,� �᫨ ��� ����,� �� ������ ���� � ��p�����
          � ��室��� ⥪���.

   �᫨ ��p������ � ���� �� �� ����p�,� �� �� �����,� �� ��������
          ����⥫쭮 㢥����� ᪮p���� �p��p����.

   ��� �������p�� �� ��� ����砭��,�p���������,����p㦥��� �訡��
          ���p������� �� ��p���: �.�롨��, AO "�롨�᪨� ���p�"

          �ͻ�ͻ�ͻ    ����஢ ��ࣥ� �������� 
          �ͻ�ͻ�˼   (0855)24-35-87 (7:30-16:30)
          �����ʼ��    kospu@topaz.yaroslavl.su
}

(*{$A-,B-,D-,E-,F-,I-,L-,N+,O+,P-,Q-,R-,S-,T-,V+,X+}*)



interface

const
     UsesDBT = $80;{�ᯮ������ DBT 䠩�}
type
   AccessMode = (ReadOnly,ReadWrite,Exclusive,Shareable);

    Float = double;{⨯ � ������饩 �窮�}

   DbHead = record
             ID : byte; {�����䨪��p}
     LastModefy : array [1..3] of byte;{��� ��᫥����� ���������� YyMmDd}
       RecCount : longint;{������⢮ ����ᥩ ������ 㤠�����}
       HeadSize : word;{������ ����� ���������}
        RecSize : word;{����� �����}
        Reserv1 : array [1..2] of byte;
          Tranz : byte;{0/1 ����p��� �� �p�����樨 ��� DB4}
        Reserv2 : array [1..13] of byte;
            MDX : byte;{������祭 �� 䠩� ������⢥���� �����ᮢ MDX}
        Reserv3 : array [1..3] of byte;
        end;

        {�����䨪��p :0-2 ����p ��pᨨ
                         3  䠩� DBT (� DB4)
                         4  ???
                        5-6 䫠� SQL (� DB4)
                         7  ������祭�� 䠩�� DBT}

   FieldDeskriptor = record
           Name : array [1..11] of char;{���,�����稢����� #0}
            Tip : char;{⨯ C,L,D,M,N,F}
        Reserv1 : pointer;{��� ���� = 㪠��⥫� �� ���祭�� ����}
            Len : byte;{����� ����}
        Decimal : byte;{������⢮ ������ ��᫥ ����⮩}
                  {��������! � CLIPPER 5.01 � ���� CHAR ��� ���� �ᯮ������ ��� ��p訩 ���� ����� ����}
        Reserv2 : word;{ᬥ饭�� ����}
        Reserv3 : array [1..11] of byte;
         TegMTX : byte;{0/1 ����稥 ⥣� ����������᭮�� 䠩�� MTX ��� DB4}
         end;

      FieldList = array [1..$FFF0 div sizeof(FieldDeskriptor)] of FieldDeskriptor;
   FieldListPtr = ^FieldList;
        Memo = array [0..$FFF0] of byte;
     MemoPtr = ^Memo;


   DBase3 = object
   CountField : word;{������⢮ �����}
        RecNo : longint;{����p ⥪�饩 �����}
{� ���� ����騬 ��p������ ���筮 ����祬 ��p������}
         Head : DbHead;
       Fields : FieldListPtr;{ᯨ᮪ �����}
       CurRec : MemoPtr;{⥪��� ������,��p�� ���� �p����� DELETED}
        nGoto : longint;{�㤠 �⥫ ��p��������� � ��᫥���� p��}
      Chainge : boolean;{���������� ���� ������/���}
     OpenMode : AccessMode;{p���� ����㯠 � ��}
          DBF : file;{䠩� ���� ������}
       FndStr : string;{�᪮��� ���祭�� ��� CONTINUE}
       FndRec : word;{����p ���� ��� CONTINUE}

{��p�⨥/���p�⨥ ��}
         procedure Assign(S:String);{�p�᢮��� ���}
         procedure Close;{���p��� 䠩�}
         function Open(Mode:AccessMode):boolean;{��p��� DBF-䠩�(true=Ok)}
         function IsOpen:boolean;{��p�� �� DBF-䠩�}

{ᮧ����� ����� ��}
         procedure Init;{�����⮢�� � ᮧ����� ���� ������}
         procedure AddField(Nam:string;Typ:char;Leng,Dec:byte);{�������� ���� � ���� ������,���砫� �맢��� INIT}
         function Create:boolean;{ᮧ���� ���� ������,��᫥ ᮧ����� ��� �㤥� ���p�⮩}
         function Empty:boolean;{���⪠ ���� ������}

{p���� � ���ﬨ ��}
         function GetFieldName(N:word):string;{��p���� ��� ����}
         function GetFieldType(N:word):char;{��p���� ⨯ ����}
         function GetFieldLen(N:word):word;{��p���� p����p ����}
         function GetFieldDec(N:word):word;{��p���� ������⢮ ᨬ����� ��᫥ ����⮩}
         function FindField(Nam:string):word;{����p�頥� ����p ����,�᫨ ��� ���,� 0}

{������ � ���� �� ����p�}
         procedure WriteNStr(N:word;S:string);{������� ��p��� � ���� ���� ������}
         procedure WriteNLog(N:word;B:boolean);{������� �����᪮� ���祭�� � ���� ���� ������}
         procedure WriteNNum(N:word;V:Float);{������� �᫮��� ���祭�� � ���� ���� ������}

{������ � ���� �� �����}
         procedure WriteStr(Nam,S:string);{������� ��p��� � ���� ���� ������}
         procedure WriteLog(Nam:string;B:boolean);{������� �����᪮� ���祭�� � ���� ���� ������}
         procedure WriteNum(Nam:string;V:Float);{������� �᫮��� ���祭�� � ���� ���� ������}

{����� ���祭�� ���� �� ����p�}
         function GetStr(N:word):string;{��p���� ���祭�� ���� ��� ��p���}
         function GetNum(N:word):Float;{��p���� �᫮��� ����}
         function GetDate(N:word):string;{��p���� ���� ����}
         function GetLog(N:word):boolean;{��p���� �����᪮� ����}

{����� ���祭�� ���� �� �����}
         function Str(Nam:string):string;{��p���� �� ���� ��� ��p���}
         function Num(Nam:string):Float;{��p���� �᫮��� ����}
         function Log(Nam:string):boolean;{��p���� �����᪮� ����}
         function Date(Nam:string):string;{��p���� ���� ����}

{��p���饭��}
         procedure Go_To(R:longint);{��p��� �� ������}
         procedure Skip(dR:longint);{�⭮�⥫쭮� ��p���饭��}

{p�����}
         function LastRec:longint;{������⢮ ����ᥩ � ���� ������ ���� � 㤠�����}
         function EOF:boolean;{�뫠 �� ����⪠ �� �� ��᫥���� ������ ��}
         function BOF:boolean;{�뫠 �� ����⪠ ��p���饭�� ��� ��砫� ��}

         function RLock:boolean;{������ ⥪���� ������}
         function UnLock:boolean;{���� ����� � ⥪�饩 �����}

         function Find(Nam,Val:string):boolean;{��� � ⥪�饩 ����� �� ��᫥���� ���� � ������� ���祭���}
         function Continue:boolean;{�p�������� ���� � ⥪�饩 ����� �� ��᫥����}

         function Append:boolean;{�������� ����� ������ � ����� �� ���}

{ ����p����� ���p�樨 � ��p������ (��� �ᯮ������� ��⮬���᪨ � ��� ���� �� �� ��ᯮ�����)}

         procedure Read;{���� ⥪���� ������}
         end;

type

   Filter = function(var dBase3:dBase3):boolean;{㤮���⢮p�� �� ������ 䨫��p�}
   { �����p �� ������ �ᯮ�짮���� ��⮤� ��ꥪ� dBase3a ,� �p�⨢���
         ��砥 �� ����� �p����� � ��᪮���� p���pᨢ�� �맮��� }

   dBase3a = object(dBase3)
     Filtr : Filter;
      function Open(Mode:AccessMode):boolean;{��p��� DBF-䠩�}
     procedure SetFilter(FuncFilter:Filter);{��⠭����� 䨫��p, nil = ����}

   {�� �� ��������騥 ��⮤� ����� ��⠭���� 䨫��p�}
      function Find(Nam,Val:string):boolean;{��� � ⥪�饩 ����� �� ��᫥���� ���� � ������� ���祭���}
      function Continue:boolean;{�p�������� ���� � ⥪�饩 ����� �� ��᫥����}
     procedure GotoTop;{��p��� � ��砫� ��}
     procedure GotoBottom;{��p��� � ����� ��}
     procedure Skip(dR:longint);{�⭮�⥫쭮� ��p���饭��}
      function StatFiltr:boolean;{�� �㬠�� 䨫��p � ⥪�饩 �����}
         end;

implementation

uses Dos,SysTime;

const
   ListMode : array [AccessMode] of byte = ($00,$02,$12,$42);
     LogStr : array [boolean] of char = ('F','T');{���祭�� FALSE � TRUE}
   RepLock = 100;{������⢮ ����⮪ � ��砥 �����p���� �����}

function CMPSB(var V1,V2; Size : word): boolean;{�ࠢ������ ��� ��६����}
           inline($fc/$59/$8c/$db/$5e/$1f/$5f/7/$f3/$a6/$b0/0/$75/2/$fe/$c0/$8e/$db);

(*  ------======== ��� Turbo Pascal 5.5 ==========----------

function LockUnLock(var F ; Rec , Count , Code : word) : boolean;
var                                     {0 - Lock; 1 - UnLock}
   FileR : FileRec absolute F;
       R : registers;
       P : longint;
begin
   with FileR,R do begin
      P:=RecSize*Rec;
      cx:=P shr 16;
      dx:=P and $FFFF;
      P:=RecSize*Count;
      si:=P shr 16;
      di:=P and $FFFF;
      ax:=$5c00+Code;
      bx:=Handle;
      end;
   msdos(R);
   LockUnLock:=R.flags and Fcarry = 0;
end; *)

function LockUnLock(var F; Rec,Count:word; Code:byte):boolean; near; assembler;
asm                                            {0 - Lock; 1 - UnLock}
   les  bx,F
   mov  cx,FileRec(es:[bx]).RecSize
   mov  ax,Count
   mul  cx
   mov  si,dx
   mov  di,ax
   mov  ax,Rec
   mul  cx
   mov  cx,dx
   mov  dx,ax
   mov  bx,FileRec(es:[bx]).Handle
   mov  ah,5Ch
   mov  al,Code
   int  21h
   mov  al,true
   jnc  @Exit
   mov  al,false
@Exit:
end;

function LockRecord(var F ; Rec , Count : longint):boolean;{�����p���� ���⪠ 䠩��}
begin
   LockRecord:=LockUnLock(F,Rec,Count,0);
end;

function UnLockRecord(var F ; Rec , Count : longint):boolean;{��⨥ �����p����}
begin
   UnLockRecord:=LockUnLock(F,Rec,Count,1);
end;



function DBase3.IsOpen:boolean;{��p�� �� DBF-䠩�}
var
   F : FileRec absolute DBF;
   M : word;
begin
   case F.Mode of
      fmInput,fmOutput,fmInOut : IsOpen:=true;
      else IsOpen:=false;
      end;
end;

function DBase3.Continue:boolean;{�p�������� ���� � ⥪�饩 ����� �� ��᫥����}
label Ret;
var
   L : longint;
  dR : word;
   P : pointer;
  Ln : word;
  Fp : longint;
begin
   with Fields^[FndRec and $7FFF] do begin
      Ln:=Len;
      Fp:=Reserv2;
      P:=Reserv1;
      end;
   L:=RecNo;
   if FndRec and $8000<>0 then
      FndRec:=FndRec and $7FFF
   else
      inc(L);
   dR:=Head.RecSize;
   inc(Fp,Head.HeadSize+(L-1)*dR);
   while L<=LastRec do begin
      seek(DBF,Fp);
      BlockRead(DBF,P^,Ln);
      if CMPSB(P^,FndStr[1],Ln) then begin
         RecNo:=L;
         Continue:=true;
         goto Ret;
         end;
      inc(L);
      inc(Fp,dR);
      end;
   nGoto:=L;
   RecNo:=L-1;
   Continue:=false;
   Ret:Read;
end;

function DBase3.Find(Nam,Val:string):boolean;{��� � ⥪�饩 ����� �� ��᫥���� ���� � ������� ���祭���}
var
   I : word;
   L : byte absolute FndStr;
begin
   I:=FindField(Nam);
   if I<>0 then begin
      FndRec:=$8000 or I;
      FndStr:=Val;
      with Fields^[I] do begin
         I:=Len;
         while L<I do begin
            inc(L);
            FndStr[L]:=#32;
            end;
         if L>I then
            L:=I;
         end;
      Find:=Continue;
      end
   else
      Find:=false;
end;


procedure DBase3.WriteNum(Nam:string;V:Float);{������� �᫮��� ���祭�� � ���� ���� ������}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      WriteNNum(I,V);
end;

procedure DBase3.WriteNNum(N:word;V:Float);{������� �᫮��� ���祭�� � ���� ���� ������}
var
   S : string;
begin
   with Fields^[N] do
      system.str(V:Len:Decimal,S);
   WriteNStr(N,S);
end;

procedure DBase3.WriteLog(Nam:string;B:boolean);{������� �����᪮� ���祭�� � ���� ���� ������}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      WriteNStr(I,LogStr[B]);
end;

procedure DBase3.WriteNLog(N:word;B:boolean);{������� �����᪮� ���祭�� � ���� ���� ������}
begin
   WriteNStr(N,LogStr[B]);
end;

procedure DBase3.WriteStr(Nam,S:string);{������� ��p��� � ���� ���� ������}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      WriteNStr(I,S);
end;

procedure DBase3.WriteNStr(N:word;S:string);{������� ��p��� � ���� ���� ������}
var
   L : byte absolute S;
   I : word;
begin
   with Fields^[N] do begin
      I:=Len;
      while L<I do begin
         inc(L);
         S[L]:=#32;
         end;
      if L>I then
         L:=I;
      move(S[1],Reserv1^,I);
      seek(DBF,Head.HeadSize+(RecNo-1)*Head.RecSize+Reserv2);
      BlockWrite(DBF,S[1],I);
      end;
end;

function DBase3.Append:boolean;{�������� ����� ������ � ����� �� ���}
var
   I : word;
   L : longint;
   B : byte;
begin
   if OpenMode=Shareable then begin
      seek(DBF,4);
      I:=RepLock+1;
      repeat
         if LockRecord(DBF,4,4) then
            I:=0
         else
            dec(I);
         until I<=1;
      if I=1 then begin
         Append:=false;
         exit;
         end;
      BlockRead(DBF,Head.RecCount,4);
      inc(Head.RecCount);
      seek(DBF,4);
      BlockWrite(DBF,Head.RecCount,4);
      while not(UnLockRecord(DBF,4,4)) do begin
         end;
      end
   else
      inc(Head.RecCount);
   FillChar(CurRec^,Head.RecSize,#32);
   L:=Head.HeadSize+(Head.RecCount-1)*Head.RecSize;
   seek(DBF,L);
   B:=$1A;
   if OpenMode=Shareable then begin
      I:=Head.RecSize+1;
      repeat
        until LockRecord(DBF,L,I);
      end;
   BlockWrite(DBF,CurRec^,Head.RecSize);
   BlockWrite(DBF,B,1);
   if OpenMode=Shareable then begin
      repeat
        until UnLockRecord(DBF,L,I);
      end;
   RecNo:=Head.RecCount;
   nGoto:=RecNo;
   Append:=true;
   Chainge:=true;
end;

function DBase3.Create:boolean;{ᮧ���� ���� ������,��᫥ ᮧ����� ��� �㤥� ���p�⮩}
var
   Y,M,D,W,I : word;
begin
   rewrite(DBF,1);
   if IOResult<>0 then begin
      Create:=false;
      exit;
      end;
   SysTime.GetDate(Y,M,D,W);
   with Head do begin
      LastModefy[1]:=Y-1900;
      LastModefy[2]:=M;
      LastModefy[3]:=D;
      D:=CountField*sizeof(FieldDeskriptor);
      HeadSize:=sizeof(Head)+D+2;
      M:=1;
      for I:=1 to CountField do
        inc(M,Fields^[I].Len);
      RecSize:=M;
      end;
   BlockWrite(DBF,Head,sizeof(Head),I);
   BlockWrite(DBF,Fields^,D,Y);
   M:=$000D;
   BlockWrite(DBF,M,2,W);
   system.Close(DBF);
   Create:=(I=sizeof(Head)) and (D=Y) and (W=2);
end;



function DBase3.Empty:boolean;{���⪠ ���� ������}
var
   Y,M,D,W,I : word;
begin
   reset(DBF,1);
   if IOResult<>0 then begin
      Empty:=false;
      exit;
      end;
   SysTime.GetDate(Y,M,D,W);
   with Head do begin
      LastModefy[1]:=Y-1900;
      LastModefy[2]:=M;
      LastModefy[3]:=D;
      D:=CountField*sizeof(FieldDeskriptor);
      HeadSize:=sizeof(Head)+D+2;
      M:=1;
      for I:=1 to CountField do inc(M,Fields^[I].Len);
      RecSize:=M;
      end;
   BlockWrite(DBF,Head,sizeof(Head),I);
   BlockWrite(DBF,Fields^,D,Y);
   M:=$000D;
   BlockWrite(DBF,M,2,W);
   Truncate(DBF);
   system.Close(DBF);
   Empty:=(I=sizeof(Head)) and (D=Y) and (W=2);
end;




procedure DBase3.AddField(Nam:string;Typ:char;Leng,Dec:byte);{�������� ���� � ���� ������,���p�� �㤥� ᮧ����}
var
   I : word;
  Uf : FieldListPtr;
   L : byte absolute Nam;
begin
   inc(CountField);
   I:=(CountField)*sizeof(FieldDeskriptor);
   GetMem(Uf,I);
   system.Dec(I,sizeof(FieldDeskriptor));
   if I<>0 then
      begin
       move(Fields^,Uf^,I);
       FreeMem(Fields,I);
      end;
   Fields:=Uf;
   if L>10 then
      L:=10;
   with Uf^[CountField] do begin
      FillChar(Name,sizeof(FieldDeskriptor),#0);
      while L<>0 do begin
         Name[L]:=Nam[L];
         system.dec(L);
         end;
      Len:=Leng;
      Decimal:=Dec;
      Tip:=Typ;
      end;
end;


procedure DBase3.Init;{�����⮢�� � ᮧ����� ���� ������}
begin
   FillChar(Head.LastModefy,sizeof(Head)-1,#0);
   Head.ID:=3;
   CountField:=0;
end;


function DBase3.UnLock:boolean;{���� ����� � ⥪�饩 �����}
begin
   with Head do
      UnLock:=UnLockRecord(DBF,HeadSize+(RecNo-1)*RecSize,RecSize);
end;

function DBase3.RLock:boolean;{������ ⥪���� ������}
begin
   with Head do
      RLock:=LockRecord(DBF,HeadSize+(RecNo-1)*RecSize,RecSize);
end;

procedure DBase3.Skip(dR:longint);{�⭮�⥫쭮� ��p���饭��}
begin
   Go_To(RecNo+dR);
end;

function dBase3.BOF:boolean;{�뫠 ����⪠ ����� ��p�� ��砫�� ��}
begin
   if nGoto<=0 then
      BOF:=true
   else
      BOF:=(LastRec=0);{����� ��}
end;

function DBase3.EOF:boolean;{�� �� ��p�室 �� �p����� 䠩��}
var
   Max : longint;
begin
   Max:=LastRec;
   EOF:=(nGoto>Max) or (Max=0);
end;

function DBase3.LastRec:longint;{������⢮ ����ᥩ � ���� ������ ���� � 㤠�����}
begin
   if OpenMode=Shareable then begin
      seek(DBF,4);
      BlockRead(DBF,Head.RecCount,4);
      end;
   LastRec:=Head.RecCount;
end;

function DBase3.Log(Nam:string):boolean;{��p���� �����᪮� ����}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      Log:=GetLog(I)
   else
      Log:=false;
end;

function DBase3.Date(Nam:string):string;{��p���� ���� ����}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      Date:=GetDate(I)
   else
      Date:='';
end;

function DBase3.Str(Nam:string):string;{��p���� ᨬ���쭮� ����}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      Str:=GetStr(I)
   else
      Str:='';
end;

function DBase3.Num(Nam:string):Float;{��p���� �᫮��� ����}
var
   I : word;
begin
   I:=FindField(Nam);
   if I<>0 then
      Num:=GetNum(I)
   else
      Num:=0;
end;


function DBase3.FindField(Nam:string):word;{����p�頥� ����p ����,�᫨ ��� ���,� 0}
var
   I : word;
begin
   I:=1;
   repeat
      if Nam=GetFieldName(I) then begin
         FindField:=I;
         exit;
         end;
      inc(I);
      until I>CountField;
   FindField:=0;
end;


function DBase3.GetLog(N:word):boolean;{��p���� �����᪮� ����}
var
   S : string[1];
begin
   S:=GetStr(N);
   GetLog:=S[1] in ['Y','T'];
end;

function DBase3.GetDate(N:word):string;{��p���� ���� ����}
var
   S : string[10];
begin
   S:=GetStr(N);
   GetDate:=copy(S,7,2)+'/'+copy(S,5,2)+'/'+copy(S,1,4);
end;

function DBase3.GetNum(N:word):Float;{��p���� ᨬ���쭮� ����}
var
   I : integer;
   R : Float;
begin
   val(GetStr(N),R,I);
   GetNum:=R;
end;

function DBase3.GetStr(N:word):string;{��p���� ���祭�� ���� ��� ��p���}
var
   S : string;
   L : byte absolute S;
begin
   with Fields^[N] do begin
      if OpenMode=Shareable then begin
         seek(DBF,Head.HeadSize+(RecNo-1)*Head.RecSize+Reserv2);
         BlockRead(DBF,Reserv1^,Len);
         end;
      L:=Len;
      move(Reserv1^,S[1],L);
      end;
   GetStr:=S;
end;

function DBase3.GetFieldDec(N:word):word;{��p���� ������⢮ ᨬ����� ��᫥ ����⮩}
begin
   GetFieldDec:=Fields^[N].Decimal;
end;

function DBase3.GetFieldLen(N:word):word;{��p���� p����p ����}
begin
   GetFieldLen:=Fields^[N].Len;
end;

function DBase3.GetFieldType(N:word):char;{��p���� ⨯ ����}
begin
   GetFieldType:=Fields^[N].Tip;
end;

function DBase3.GetFieldName(N:word):string;{��p���� ���祭�� ����}
var
   S : string[10];
   L : byte absolute S;
begin
   with Fields^[N] do begin
      L:=0;
      while (Name[L+1]<>#0) and (L<10) do begin
         inc(L);
         S[L]:=Name[L];
         end;
      end;
   GetFieldName:=S;
end;

procedure DBase3.Go_To(R:longint);{��p��� �� ������}
begin
   nGoto:=R;
   if R<=0 then
      RecNo:=1
   else if R>LastRec then
      RecNo:=Head.RecCount
   else
      RecNo:=R;
   Read;
end;

procedure DBase3.Close;{���p��� 䠩�}
var
   Y,M,D,W : word;
   j : Integer;
begin
   if Chainge then begin
      seek(DBF,1);
      SysTime.GetDate(Y,M,D,W);
      Head.LastModefy[1]:=Y-1900;
      Head.LastModefy[2]:=M;
      Head.LastModefy[3]:=D;
      Y:=sizeof(Head.LastModefy);
      if OpenMode<>Shareable then
         Y:=sizeof(Head.LastModefy)+sizeof(Head.RecCount);
      BlockWrite(DBF,Head.LastModefy,Y);
      end;
   system.close(DBF);
   j:=IOResult;
   FreeMem(Fields,CountField*sizeof(FieldDeskriptor));
   FreeMem(CurRec,Head.RecSize);
end;

procedure DBase3.Read;{���� ⥪���� ������}
begin
   if Head.RecCount<>0 then begin
      seek(DBF,Head.HeadSize+(RecNo-1)*Head.RecSize);
      BlockRead(DBF,CurRec^,Head.RecSize);
      end;
end;

function DBase3.Open(Mode:AccessMode):boolean;{��p��� DBF-䠩� � �易��� � ��� DBT}
var
   I,J : word;
   Bak : byte;
begin
   Bak:=FileMode;
   I:=IOResult;
   FileMode:=ListMode[Mode];
   Reset(DBF,1);
   if IOResult=0 then begin
      BlockRead(DBF,Head,sizeof(Head),I);
      CountField:=(Head.HeadSize-sizeof(Head)) div sizeof(FieldDeskriptor);
      if (I<>sizeof(Head))or(CountField>1000)or(IOResult<>0)or((Head.ID and 7)<>3) then begin
         Open:=false;
         system.close(DBF);
         FileMode:=Bak;
         exit;
         end;
      I:=CountField*sizeof(FieldDeskriptor);
      RecNo:=1;

      GetMem(Fields,I);
      BlockRead(DBF,Fields^,I);
      GetMem(CurRec,Head.RecSize);{�᫨ ��p�� ���� '*' � ������ DELETED}
      J:=1;
      for I:=1 to CountField do with Fields^[I] do begin
         Reserv1:=addr(CurRec^[J]);{��p�� ᮤ�p������ ����}
         Reserv2:=J;{ᬥ饭�� ����}
         inc(J,Len);
         end;
      Chainge:=false;
      OpenMode:=Mode;

      Read;
      Open:=true;
      nGoto:=1;
      end
   else
      Open:=false;
   FileMode:=Bak;
end;



procedure DBase3.Assign(S:String);{�p�᢮��� 䠩�}
var
   L : byte absolute S;
   I : word;
begin
   for I:=1 to L do
      if S[I] in ['a'..'z'] then
         dec(S[I],$20);
   I:=pos('.',S);
   if I=0 then begin
      I:=L+1;
      S:=S+'.DBF';
      end;
   system.Assign(DBF,S);
end;


function dBase3a.Continue:boolean;{�p�������� ���� � ⥪�饩 ����� �� ��᫥����}
begin
   repeat
      inherited Continue;
   until StatFiltr or EOF;
end;


function dBase3a.Find(Nam,Val:string):boolean;{��� � ⥪�饩 ����� �� ��᫥���� ���� � ������� ���祭���}
begin
   if inherited Find(Nam,Val) then begin
      if StatFiltr then
         Find:=true
      else
         Find:=Continue;
      end
   else
      Find:=false;
end;


procedure dBase3a.Skip(dR:longint);{�⭮�⥫쭮� ��p���饭��}
var
   Step : longint;
    Bak : longint;
begin
   Bak:=RecNo;
   if dR>0 then
      Step:=1
   else if dR<0 then
      Step:=-1
   else
      exit;
   dR:=abs(dR);
   repeat
      inherited skip(Step);
      if StatFiltr then begin
         dec(dR);
         if dR=0 then
            exit;
         end;
      until BOF or EOF;
   RecNo:=Bak;
   Read;
end;

function dBase3a.StatFiltr:boolean; assembler;{�� �㬠�� 䨫��p � ⥪�饩 �����}
asm
   les  di,Self
   mov  ax,word ptr dBase3a(es:[di]).Filtr
   or   ax,word ptr dBase3a(es:[di]).Filtr+2
   mov  al,true
   jz   @Exit
   push es
   push di
   call dBase3a(es:[di]).Filtr
@exit:
end;

procedure dBase3a.SetFilter(FuncFilter:Filter); assembler;{��⠭����� 䨫��p, nil = ����}
asm
   push ds
   lds  di,Self
   les  ax,FuncFilter
   mov  word ptr dBase3a(ds:di).Filtr,ax
   mov  word ptr dBase3a(ds:di).Filtr+2,es
   pop  ds
end;

function dBase3a.Open(Mode:AccessMode):boolean;{��p��� DBF-䠩�}
begin
   inherited Open(Mode);
   Filtr:=nil;
end;

procedure dBase3a.GotoTop;
begin
   Go_To(1);
   if not StatFiltr then
      Skip(+1);
end;

procedure dBase3a.GotoBottom;
begin
   Go_To(MaxLongInt);
   if not StatFiltr then
      Skip(-1);
end;



end.
