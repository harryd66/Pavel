uses dos,DBIII;

var
   F : file;

function isFile(Nam : string):boolean;{есть ли файл}
begin
   assign(F,Nam);
   reset(F,1);
   isFile:=(IOResult=0);
end;


function Num2Str(B:word):string;
var
   S : string[4];
begin
   str(B:2,S);
   if S[1]=#32 then
      S[1]:='0';
   Num2Str:=S;
end;

function GetFDate:string;{дата изменения файла}
var
   tmp : longint;
    DT : DateTime;
begin
   GetFTime(F,tmp);
   UnpackTime(tmp,DT);
   with DT do
      GetFDate:=Num2Str(Year)+Num2Str(Month)+Num2Str(Day);
end;

function GetFTime:string;{вpемя изменения файла}
var
   tmp : longint;
    DT : DateTime;
begin
   dos.GetFTime(F,tmp);
   UnpackTime(tmp,DT);
   with DT do
      GetFTime:=Num2Str(Hour)+':'+Num2Str(Min)+':'+Num2Str(Sec);
end;

function GetFSize:longint;{pазмеp файла}
begin
   GetFSize:=FileSize(F);
end;


const
   FNames : array [1..6] of string[8] =
        ('dbIII','dbCreate','OpenRead','Structur','dbIIIa','Filter');

var
   Base : DBase3;
 Name,S : string;
   Stat : boolean;
      j : word;
     ls : LongInt;


begin
Ls := MemAvail;
Str(ls:12, S);
Writeln(s);

   with Base do
   begin
      Assign('Tutor'); {пpисвоить БД имя}

      Init; {подготовиться к созданию БД}

      AddField('NAME','C',12,0);
      AddField('DATE','D',8,0);
      AddField('TIME','C',8,0);
      AddField('LENGTH','N',10,0);
      AddField('STATUS','L',1,0);


      if Create then

         Open(Exclusive)

      else begin
         writeln('Не могу создать базу данных...');
         exit;
         end;

      for j:=1 to 6 do
	 begin
         Append; {добавить новую запись}

         Name:=FNames[j]+'.pas';
         WriteStr('NAME',Name);

         Stat:=True;
         WriteLog('STATUS',Stat);

         if Stat then begin {файл существует}
             WriteStr('DATE',GetFDate);
             WriteStr('TIME',GetFTime);
             WriteNum('LENGTH',GetFSize);
             system.close(F);{закpыть файл}
             end;
         end;

      Close;
      end;

   writeln;

Ls := MemAvail;
Str(ls:12, S);
Writeln(s);
Readln;
end.
