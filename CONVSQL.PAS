Uses Glob, ServStr, TPDate, Serv, Utils5;


Var r: razdelType;
    fr: file of razdelType;
    t,tt,tpost,titog, tdiv: text;
    sRazd: string[CRazdelKOd];
    sKOd: string[3];
    KOd: word;
    id: BazType;
    fid: file of BazType;
     PostFile: File of Clienttype;
     post: Clienttype;
     itog: NewItogType;
     fitog: file of NewItogType;
     sDate:DateString;
     Date:LongInt;
     IORez, nSkl, i: word;
     sSklKOd: string[2];
     sDiv: array [1..CDivision] of string;
     st: string;
     smake: string[3];
     sVid:string[1];
BEGIN
  Assign(fr,'m:\newskl\main\razdel.db');
  reset(fr);
  Assign(t,'d:\razdel.csv');
  rewrite(t);
  Assign(tt,'d:\tovar.csv');
  rewrite(tt);
  Assign(tpost,'d:\postav.csv');
  rewrite(tpost);
  Assign(titog,'d:\itog.csv');
  rewrite(titog);
  Assign(tdiv,'d:\division.csv');
  rewrite(tdiv);


{€‡„…‹›  €…‚€}
  while not eof(fr) do
  begin
    read(fr,r);
    if r.Employ then
      BEGIN
       write(t,DosToWin(r.KOd),';',DosToWin(r.Name));
       if r.EnableLitr=1 then writeln(t,';1')
       else writeln(t,';0');

       Assign(fid,'M:\Newskl\id\'+r.KOd+'.id');
       reset(fid);
       while not eof(fid) do
       Begin
        read(fid,id);
        if id.Employ then
        begin
          sKOd:=copy(id.BazKOd,3,3);
          write(tt,sKOd,';',r.KOd,';',DosToWin(id.Name)+' '+DosToWin(id.Name2));
          writeln(tt,';'+id.Litr+';'+id.InPack);
        end;
       End;
       close(fid);
      END;
  end;

{‘’‚€‚™}
Assign (PostFile,'j:\newskl\client\make.db');
IORez:=ioresult;
Reset (PostFile);
IORez:=ioresult;


While Not(Eof(PostFile)) Do
 Begin
  Read(PostFile,Post);
  If Post.Employ Then
   Begin
    Format (Post.Name,CClient);
    writeln(tpost,Post.Kod+';'+DosToWin(Post.Name)+';0');
   End;
 End;
System.Close(PostFile);

Assign (PostFile,'j:\newskl\client\barter.db');
IORez:=ioresult;
Reset (PostFile);
IORez:=ioresult;

While Not(Eof(PostFile)) Do
 Begin
  Read(PostFile,Post);
  If Post.Employ Then
   Begin
    Format (Post.Name,CClient);
    writeln(tpost,Post.Kod+';'+DosToWin(Post.Name)+';2');
   End;
 End;
System.Close(PostFile);

{’ƒ}
for nSkl:=1 to 11 do
BEGIN

 { Date:=today-7;
  sDate:=DateToDateString('DDmmyy',Date);
  DelSpace(sDate); }
 sDate:='19-03-03';
 Date:=DatestringToDate('dd-mm-yy',sDate);
 {writeln(Date);}

 sDate:=DateToDateString('DDmmyy',Date);
 sSklKOd:=IntToStr(nSkl,2);
 if sSklKod[0]=#1 then
    begin
      SSklKod[0]:=#2;
      sSklKod[2]:=sSklKod[1];
      sSklKod[1]:='0';
    end;
 DelSpace(sDate);
 Assign(fitog,'y:\arc\'+sDate+'.p'+sSklKOd);
   IORez:=IOResult;
   Reset(fitog);
   IORez:=Ioresult;
   If IORez <> 0 Then
    Begin
      {MessageBox(#3^M+#3'¥ ­ ©¤¥­ δ ©« '+PathSklads[nSkl]+Date+'.p'+sSklKOd,Nil,mfError+mfCancelButton);}
      {MMs[nSkl]:=0;}
     { writeln('y:\ARC\'+sDate+'.p'+sSklKOd);
      readln; }
      continue;
    End;


  while not eof(fitog) do
  begin
    IORez:=ioresult;
    read(fitog,itog);
    IORez:=ioresult;
    if IOREz<>0 then
      begin
       writeln('θ¨΅ª  ηβ¥­¨ο δ ©«  ¨β®£®Ά');
       exit;
      end;
    with itog do
    begin
{‹—
  ®¤ β®Ά ΰ 
  ª®¤ ΰ §¤¥« 
  ª®¤ αª« ¤ 
  Ά¨¤ ―®αβ Άι
  ª®¤ ―®αβ Άι
  „ β }
     srazd:=copy(BazKod,1,2);
     sKOd:=copy(BazKod,3,3);
     write(titog,srazd+';');
     write(titog,sKod+';');
     write(titog,sSklKOd+';');
     sDate:=DateToDatestring('dd.mm.yy',Date);
     write(titog,sDate+';');
     {‘’€‚™}
     smake:=copy(NMakeKod,2,3);
     delspace(smake);
     if smake='' then smake:='0';
     svid:=copy(NMakeKod,1,1);
     DelSpace(sVid);
     if svid='' then svid:='0';
     write(titog,sVid+';');
     write(titog,sMake+';');

   {‘’€’ ª®«-Ά®}
     write(titog,IntToStr(StrToInt(Ost),CKol)+';');


(*  {’„…‹…
	   ª«ξη + ®αβ βª¨}
     for i:=1 to CDivision do
       begin
         sDiv[i]:='';
         sDiv[i]:=sDiv[i]+srazd+';'+skod+';'+sSklKOd+';'+sDate+';'+IntToStr(i,CKOl)+';'
            +IntToStr(MRkCDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkSDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkBDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(OstDiv[i],CKol);
         writeln(tdiv,sDiv[i]);
       end;   *)

   {‘’€’ αγ¬¬ }
     st:=REalToStr(OstE,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(OstEZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(OstEZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
   {•„ ª®«-Ά®}
     write(titog,IntToStr(StrToInt(PrhC),CKol),';');
     write(titog,IntToStr(StrToInt(PrhS),CKol),';');
     write(titog,IntToStr(StrToInt(PrhB),CKol),';');
   {•„ αγ¬¬ }
     st:=REalToStr(PrhEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhECZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     st:=REalToStr(PrhESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     st:=REalToStr(PrhEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(PrhEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(PrhEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+'0;');

   {„€†€ ª®«-Ά®}
     st:=IntToStr(StrToInt(MrkC),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkS),CKol);
     Delspace(st);
     write(titog,st,';');
     st:=IntToStr(StrToInt(MrkB),CKol);
     Delspace(st);
     write(titog,st,';');
    {„€†€ αγ¬¬ }
     st:=REalToStr(MrkEC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkECOpl,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ,CIZena,CMantissaz);
     DelSpace(st);
     write(titog,st+';');
     st:=REalToStr(MrkECZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkES,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     st:=REalToStr(MrkESZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,ST+';');
     st:=REalToStr(MrkESZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     ST:=REalToStr(MrkEB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');
     ST:=REalToStr(MrkEBZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st,';');

     write(titog,IntToStr(StrToInt(MrkOptC),CKol),';');
     st:=REalToStr(MrkOptRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkOptCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznC),CKol),';');
     st:=REalToStr(MrkRoznRZC,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznCOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
    st:=REalToStr(MrkRoznCZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkOptB),CKol),';');
     st:=REalToStr(MrkOptRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkOptBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(MrkRoznB),CKol),';');
     st:=REalToStr(MrkRoznRZB,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(MrkRoznBZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(RewKol),CKol),';');
     st:=REalToStr(RewRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(RewZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnOptKol),CKol),';');
     st:=REalToStr(ReturnOptOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnOptZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');

     write(titog,IntToStr(StrToInt(ReturnRoznKol),CKol),';');
     st:=REalToStr(ReturnRoznOpl,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznRZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     st:=REalToStr(ReturnRoznZZ2,CIZena,CMantissaz);
     Delspace(st);
     write(titog,st+';');
     {’„…‹…
	   ®αβ βª¨}
     for i:=1 to CDivision do
       begin
         sDiv[i]:='';
         sDiv[i]:=sDiv[i]+IntToStr(MRkCDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkSDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(MrkBDiv[i],CKol)+';';
         sDiv[i]:=sDiv[i]+IntToStr(OstDiv[i],CKol)+';';
         write(titog,sDiv[i]);
       end;

     writeln(titog);

   end;{with itog}
  end;
  close(fitog);
END; {for nSkl:=1 to 11}


  close(tdiv);


  close(titog);
  close(tpost);
  close(t);
  close(tt);
  close(fr);

END.
