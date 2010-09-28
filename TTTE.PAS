Uses Glob,ServSTr,Utils5;

Const
Separator=';';

VAr txt : text;
    NItg : PNewItogType;
    f : File Of NewItogType;
    NAme,S : String;
    c : Word;


Begin
Assign(txt,'report.csv');
Rewrite(txt);
    c:=IoResult;

Assign(f,'j:\newskl\arc\50602.p01');
Reset(f);
    c:=IoResult;

New(NItg,Init);

While Not(Eof(f)) Do
 Begin
  Read(f,NItg^.Dat);
  c:=IoResult;
  If c<>0 Then
   Writeln('Error');

  NAme:='???';{DosToWin(GetIdField(FFFName,NItg^.Dat.BAzKod));}

  WriteLN(txt,NItg^.Dat.BAzKod+Separator+NAme+Separator+NItg^.Dat.Ost+Separator+
  RealToStr(NItg^.Dat.OstE,CIZena,CMAntissaZ)+Separator+RealToStr(NItg^.Dat.OstEZ,CIZena,CMAntissaZ)+
  Separator+RealToStr(NItg^.Dat.OstEZ2,CIZena,CMAntissaZ)+Separator+
  NItg^.Dat.PrhC+Separator+NItg^.Dat.PrhS+Separator+NItg^.Dat.PrhB+Separator+
  RealToStr(NItg^.Dat.PrhEC,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhECZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhECZ2,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhES,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhESZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhESZ2,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhEBZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhEBZ2,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.PrhEBZ2,CIZena,CMAntissaZ)+Separator+
  NItg^.Dat.MrkC+Separator+NItg^.Dat.MrkS+Separator+NItg^.Dat.MrkB+Separator+
  RealToStr(NItg^.Dat.MrkEC,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkECOpl,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkECZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkECZ2,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkES,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkESZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkESZ2,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkEB,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkEBZ,CIZena,CMAntissaZ)+Separator+
  RealToStr(NItg^.Dat.MrkEBZ2,CIZena,CMAntissaZ));

 End;




Dispose(NITg,Done);

close(txt);
Close(f);

End.
