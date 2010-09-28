Unit Oborot;

INTERFACE

Uses Dialogs, Drivers, Utils, Prise, TPDate, Glob, ServStr, Objects,
     MSGBox, DBEngine, Utils5, Utils3, Utils4, Serv, Printers;

{$I Compile.INC}
procedure CalcOborot;

IMPLEMENTATION

const BufferNewItog = 70;

Type BufNewItogType = Record
     Dat : Array [1..BufferNewItog] Of NewItogType;
     end;


const CIZena=11;

const posArt = 1;
const posMake = posArt+CArtikul;
const posOstN = posMake+CMAkeKod;
const posEOstN = posOstN+CKOl;
const posPrhC  = posEOstN+CIZena;
const posEPrhC = posPrhC+CKol;

const posNds = posEPrhC+CIZena;

const posPrhS = posNds+CLitr;
const posEPrhS = posPrhS+CKOl;
const posPrhB  = posEPrhS+CIZena;
const posEPrhB = posPrhB+CKol;
const posPrhRew = posEPrhB+CIZena;
const posEPrhRew = posPrhRew+Ckol;
const posOptC = posEPrhRew+CIZena;
const posEOptC = posOptC+CKOl;

const posEOptOpl = posEOptC+CIZena;

const posRoznC = posEOptOpl+CIZena;
const posERoznC = posRoznC+Ckol;

const posERoznOpl = posERoznC+CIZEna;

const posMrkS = posERoznOpl+CIZEna;
const posEMrkS = posMrkS+CKol;
const posMrkB = posEMrkS+CIZEna;
const posEMrkB = posMrkB+CKol;
const posRashRew = posEMrkB+CIZEna;
const posERashRew = posRashRew+CKol;
const posOstK = posERashRew+CIZEna;
const posEOstK = posOstK+CKol;



 procedure AddObToList(var It: PBox; e:NewItogType; p: word; z: boolean; bNds:boolean);
                            {p =0 признак начала
                             p =1 признак конца периода
                             p = 2 - текущее значение
                             z = true - ЗЦ1
                             z = false - ЗЦ2}
 var Find: boolean;
     sKOl: string[CKol];
     sZena: string[CIZena];
     sArt, sArt1: ArtikulStr;
     DnNal: string[CKOl];
     i,j: word;
     stek, sit: string;
     sNds: string[CZena];
     NDS : Real;
 Begin
     stek:='';
     find:=False;
     sArt:=e.BazKod;

     if It^.List^.Count>0 then
     for i:=0 to It^.List^.Count do
     begin
       sIt:=It^.GetText(i,It^.List^.Count);
       sArt1:=copy(sIt,1,CArtikul);
       if sArt=sArt1 then
         begin
           {Строка уже есть}
           find:=true;
           sTek:='';
           sNds:=GetIdField(FNDS,sArt);
           Delspace(sNds);
         if bNds then
         begin
           if sNds<>'' then
           NDS:=StrToReal(sNds)
           else  nds:=0;
           NDS:=NDS/(100+NDS);
         end
         else Nds:=0;
           {код}

           {поставщик}

           {ост нач}

 {2}          {приход клиента}


             skol:=copy(sIt,posPrhC+1,CKOl);
             str(StrToInt(e.PrhC)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);

             sZena:=copy(sIt,posEPrhC+1,CIZena);
             {без НДС}
             e.PrhECZ:=e.PrhECZ-e.PrhECZ*NDS;
             e.PrhECZ2:=e.PrhECZ2-e.PrhECZ2*NDS;
             if z then
              begin
               str(e.PrhECZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
              end
             else
              begin
               str(e.PrhECZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
              end;
             rFormat(sZena,CIZena);

{$IFDEF Tabak}
           {+ревизии в приход по ЗЦ*1.03}
                 {исправлено на 1.00  9.02.2005}
           if StrToInt(e.Rewkol)>0 then
           begin
             Str(StrToInt(skol)+StrToInt(e.Rewkol):CKol,sKol);
             rFormat(sKol,CKol);

             if z then Str(StrtoReal(sZena)+(e.RewZZ-e.RewZZ*NDS)*1.0:CIZena:CMantissaz,sZena)
             else Str(StrtoReal(sZena)+(e.RewZZ2-e.RewZZ2*NDS)*1.0:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
           end;
{$ENDIF}

            sTek:=sTek+sKol;
            sTek:=sTek+sZena;

         {Ставка НДС, %}
         RFormat(sNds,CLitr);
         sTek:=sTek+sNds;


 {3}          {приход склада}
             skol:=copy(sIt,posPrhS+1,CKOl);
             str(StrToInt(e.PrhS)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posEPrhS+1,CIZena);
             e.PrhESZ:=e.PrhESZ-e.PrhESZ*NDS;
             e.PrhESZ2:=e.PrhESZ2-e.PrhESZ2*NDS;
             if z then str(e.PrhESZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.PrhESZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;

  {4}         {приход бартер}
             skol:=copy(sIt,posPrhB+1,CKOl);
             str(StrToInt(e.PrhB)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posEPrhB+1,CIZena);
             e.PrhEbZ:=e.PrhEbZ-e.PrhEbZ*NDS;
             e.PrhEbZ2:=e.PrhEbZ2-e.PrhEbZ2*NDS;
             if z then str(e.PrhEBZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.PrhEBZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;

  {5}         {+ ревизии}
           if StrToInt(e.Rewkol)>0 then
           begin
             skol:=copy(sIt,posPrhRew+1,CKOl);
             str(StrToInt(e.RewKol)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posEPrhRew+1,CIZena);
             e.RewZZ := e.RewZZ - e.RewZZ*NDS;
             e.RewZZ2 := e.RewZZ2 - e.RewZZ2*NDS;
             if z then str(e.RewZZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.RewZZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end
           else
           begin
             skol:=copy(sIt,posPrhRew+1,CKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posEPrhRew+1,CIZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end;

   {6}        {отгр. опт}         {отгрузка - возврат}
             skol:=copy(sIt,posOptC+1,CKOl);
             str(StrToInt(e.MrkOptC)-StrToInt(e.ReturnOptKol)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sZena:=copy(sIt,posEOptC+1,CIZena);
             e.MrkOptCZZ:=e.MrkOptCZZ-e.MrkOptCZZ*NDS;
             e.ReturnOptZZ:=e.ReturnOptZZ-e.ReturnOptZZ*NDS;
             e.MrkOptCZZ2 := e.MrkOptCZZ2-e.MrkOptCZZ2*NDS;
             e.ReturnOptZZ2 := e.ReturnOptZZ2 - e.ReturnOptZZ2*NDS;
             if z then str(e.MrkOptCZZ-e.ReturnOptZZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.MrkOptCZZ2-e.ReturnOptZZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
{$IFDEF Tabak}
           {-ревизии в отгр.опт по ЗЦ*1.03}
           if StrToInt(e.Rewkol)<0 then
           begin
             Str(StrToInt(skol)-StrToInt(e.Rewkol):CKol,sKol);
             rFormat(sKol,CKol);

             if z then Str(StrtoReal(sZena)-(e.RewZZ-e.RewZZ*NDS)*1.03:CIZena:CMantissaz,sZena)
             else Str(StrtoReal(sZena)-(e.RewZZ2-e.RewZZ2*NDS)*1.03:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
           end;
{$ENDIF}
           sTek:=sTek+sKol;
           sTek:=sTek+sZena;

         {Опт по ценам к оплате - возврат по ценам к оплате}
         sZena:=copy(sIt,posEOptC+1,CIZena);
         e.MrkOptCOpl:=e.MrkOptCOpl-e.MrkOptCOpl*NDS;
         e.ReturnOptOpl:=e.ReturnOptOpl-e.ReturnOptOpl*NDS;
         str(e.MrkOptCOpl-e.ReturnOptOpl+StrToReal(sZena):CIZena:CMantissaZ,sZena);
         rFormat(sZena,CIZena);
         sTek:=sTek+sZena;


   {7}        {отгр. розница}   {отгрузка - возврат}
             skol:=copy(sIt,posRoznC+1,CKOl);
             str(StrToInt(e.MrkRoznC)-StrToInt(e.ReturnRoznKol)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posERoznC+1,CIZena);
             e.MrkRoznCZZ:=e.MrkRoznCZZ-e.MrkRoznCZZ*NDS;
             e.ReturnRoznZZ:=e.ReturnRoznZZ-e.ReturnRoznZZ*NDS;
             e.MrkRoznCZZ2:=e.MrkRoznCZZ2-e.MrkRoznCZZ2*NDS;
             e.ReturnRoznZZ2:=e.ReturnRoznZZ2-e.ReturnRoznZZ2*NDS;
             if z then str(e.MrkRoznCZZ-e.ReturnRoznZZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.MrkRoznCZZ2-e.ReturnRoznZZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
             e.MrkRoznCOpl:=e.MrkRoznCOpl-e.MrkRoznCOpl*NDS;
             e.ReturnRoznOpl:=e.ReturnRoznOpl-e.ReturnRoznOpl*NDS;
             str(e.MrkRoznCOpl-e.ReturnRoznOpl+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;

   {8}        {отгр. склад}
             skol:=copy(sIt,posMrkS+1,CKOl);
             str(StrToInt(e.MrkS)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             e.MrkESZ:=e.MrkESZ-e.MrkESZ*NDS;
             e.MrkESZ2:=e.MrkESZ2-e.MrkESZ2*NDS;
             sZena:=copy(sIt,posEMrkS+1,CIZena);
             if z then str(e.MrkESZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.MrkESZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
   {9}        {отгр. бартер}
             skol:=copy(sIt,posMrkB+1,CKOl);
             str(StrToInt(e.MrkB)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             e.MrkEBZ:=e.MrkEBZ-e.MrkEBZ*NDS;
             e.MrkEBZ2:=e.MrkEBZ2-e.MrkEBZ2*NDS;
             sZena:=copy(sIt,posEMrkB+1,CIZena);
             if z then str(e.MrkEBZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.MrkEBZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           if StrToInt(e.Rewkol)<0 then
           begin
  {10}           {- ревизии}
             skol:=copy(sIt,posRashRew+1,CKOl);
             str(-StrToInt(e.RewKol)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             e.RewZZ:=e.RewZZ-e.RewZZ*NDS;
             e.RewZZ2:=e.RewZZ2-e.RewZZ2*NDS;
             sZena:=copy(sIt,posERashRew+1,CIZena);
             if z then str(-e.RewZZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(-e.RewZZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end
           else
           begin
             skol:=copy(sIt,posRashRew+1,CKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posERashRew+1,CIZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end;


  {11}         {ост. кон}
           if p = 1 then
            begin
             skol:=copy(sIt,posOstK+1,CKOl);
             str(StrToInt(e.Ost)+StrToInt(sKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:=copy(sIt,posEOstK+1,CIZena);
             e.OstEZ:=e.OstEZ-e.OstEZ*NDS;
             e.OstEZ2:=e.OstEZ2-e.OstEZ2*NDS;
             if z then str(e.OstEZ+StrToReal(sZena):CIZena:CMantissaZ,sZena)
             else str(e.OstEZ2+StrToReal(sZena):CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
            end
            else
            begin
              sKOl:='0';
              rFormat(sKol,CKol);
              sTek:=sTek+sKol;
              sZena:='0.00';
              rFormat(sZena,CIZena);
              sTek:=sTek+sZena;
            end;


          case p of

          0: begin
             { + ост н}
              System.Delete(sIt,posOstN+1,posOstK-posOstN);
             end;

          1: begin
             { + 0ст к}
              System.Delete(sIt,posPrhC+1,length(sIt)-posPrhC);
             end;

          2: begin
             { - Ост н Ост к}
               System.Delete(sIt,posPrhC+1,length(sIt)-posPrhC);
             end;

           end; {case}

           sIt:=sIt+Stek;

           It^.List^.AtFree(i);
           It^.SetRange(It^.List^.Count);

           It^.List^.AtInsert(i,NewStr(sIt));
           It^.SetRange(It^.List^.Count);

           BREAK;

         end;
     end; {for j:=0 to It^.List^.Count}

       if not find then
         begin
           stek:='';
           {код}
         sNds:=GetIdField(FNDS,e.BazKod);
         Delspace(sNds);
         if bNds then
         begin
           if sNds<>'' then
           NDS:=StrToReal(sNds)
           else  nds:=0;
           NDS:=NDS/(100+NDS);
         end
         else NDS:=0;

           sTek:=sTek+e.BazKod;
           {поставщик}
           sArt1:=e.NMakeKod;
           rFormat(sArt1,CArtikul);
           sTek:=sTek+sArt1;
           {ост нач}

              sKol:='0';
              rFormat(sKol,CKol);
              sTek:=sTek+sKol;
              sZena:='0.0';
              rFormat(sZena,CIZena);
              sTek:=sTek+sZena;

   {2}        {приход клиента}
             skol:=e.PrhC;
             rFormat(sKol,CKol);

             if z then Str(e.PrhECZ-e.PrhECZ*NDS:CIZena:CMantissaz,sZena)
             else Str(e.PrhECZ2-e.PrhECZ2*NDS:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
{$IFDEF Tabak}
           {+ревизии в приход по ЗЦ*1.03}
             {*1.0  исправлено 9.02.2005}
           if StrToInt(e.Rewkol)>0 then
           begin
             Str(StrToInt(skol)+StrToInt(e.Rewkol):CKol,sKol);
             rFormat(sKol,CKol);

             if z then Str(StrtoReal(sZena)+(e.RewZZ-e.RewZZ*NDS)*1.0:CIZena:CMantissaz,sZena)
             else Str(StrtoReal(sZena)+(e.RewZZ2-e.RewZZ2*NDS)*1.0:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
           end;
{$ENDIF}
             sTek:=sTek+sKol;
             sTek:=sTek+sZena;
     {Ставка НДС, %}
     RFormat(sNds,CLitr);
     sTek:=sTek+sNds;
   {3}        {приход склада}
             skol:= e.PrhS;
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.PrhESZ-e.PrhESZ*NDS:CIZena:CMantissaz,sZena)
             else Str(e.PrhESZ2-e.PrhESZ2*NDS:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;

   {4}        {приход бартер}
             skol:=e.PrhB;
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.PrhEBZ-e.PrhEBZ*NDS:CIZena:CMantissaz,sZena)
             else Str(e.PrhEBZ2-e.PrhEBZ2*NDS:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
   {5}        {+ ревизии}
           if StrToInt(e.Rewkol)>0 then
           begin
             skol:=e.Rewkol;
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.RewZZ-e.RewZZ*NDS:CIZena:CMantissaz,sZena)
             else Str(e.RewZZ2-e.RewZZ2*NDS:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end
           else
           begin
             skol:='0';
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             sZena:='0.00';
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
           end;
   {6}        {отгр. опт}
             Str(StrToInt(e.MrkOptC)-StrToInt(e.ReturnOptKol):CKol,sKol);
             rFormat(sKol,CKol);

             if z then Str(e.MrkOptCZZ-e.MrkOptCZZ*NDS-e.ReturnOptZZ+e.ReturnOptZZ*NDS:CIZena:CMantissaZ,sZena)
             else Str(e.MrkOptCZZ2-e.MrkOptCZZ2*NDS-e.ReturnOptZZ2+e.ReturnOptZZ2*NDS:CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);


{$IFDEF Tabak}
           {-ревизии в отгр.опт по ЗЦ*1.03}
           if StrToInt(e.Rewkol)<0 then
           begin
             Str(StrToInt(skol)-StrToInt(e.Rewkol):CKol,sKol);
             rFormat(sKol,CKol);

             if z then Str(StrtoReal(sZena)-(e.RewZZ-e.RewZZ*NDS)*1.03:CIZena:CMantissaz,sZena)
             else Str(StrtoReal(sZena)-(e.RewZZ2-e.RewZZ2*NDS)*1.03:CIZena:CMantissaz,sZena);
             rFormat(sZena,CIZena);
           end;
{$ENDIF}
             sTek:=sTek+sKol;
             sTek:=sTek+sZena;


         {Цены оплаты}
         Str(e.MrkOptCOpl-e.MrkOptCOpl*NDS-e.ReturnOptOpl+e.ReturnOptOpl*NDS:CIZena:CMantissaZ,sZena);
         rFormat(sZena,CIZena);
         sTek:=sTek+sZena;

    {7}       {отгр. розница}
             Str(StrToInt(e.MrkRoznC)-StrToInt(e.ReturnRoznKol):CKol,sKOl);
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.MrkRoznCZZ-e.MrkRoznCZZ*NDS-e.ReturnRoznZZ+e.ReturnRoznZZ*NDS:CIZena:CMantissaZ,sZena)
             else Str(e.MrkRoznCZZ2-e.MrkRoznCZZ2*NDS-e.ReturnRoznZZ2+e.ReturnRoznZZ2*NDS:CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
             Str(e.MrkRoznCOpl-e.MrkRoznCOpl*NDS-e.ReturnRoznOpl+e.ReturnRoznOpl*NDS:CIZena:CMantissa,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;

    {8}       {отгр. склад}
             skol:=e.MrkS;
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.MrkESZ-e.MrkESZ*NDS:CIZena:CMantissaZ,sZena)
             else Str(e.MrkESZ2-e.MrkESZ2*NDS:CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
    {9}       {отгр. бартер}
             skol:=e.MrkB;
             rFormat(sKol,CKol);
             sTek:=sTek+sKol;
             if z then Str(e.MrkEBZ-e.MrkEBZ*NDS:CIZena:CMantissaZ,sZena)
             else Str(e.MrkEBZ2-e.MrkEBZ2*NDS:CIZena:CMantissaZ,sZena);
             rFormat(sZena,CIZena);
             sTek:=sTek+sZena;
     {10}      {- ревизии}
             if StrToInt(e.Rewkol)<0 then
             begin
               sKol:=e.RewKol;
               str(-StrToInt(sKOl):CKol,sKOl);
               rFormat(sKol,CKol);
               sTek:=sTek+sKol;
               if z then Str(-e.RewZZ+e.RewZZ*NDS:CIZena:CMantissa,sZena)
               else Str(-e.RewZZ2+e.RewZZ2*NDS:CIZena:CMantissa,sZena);
               rFormat(sZena,CIZena);
               sTek:=sTek+sZena;
             end
             else
             begin
               skol:='0';
               rFormat(sKol,CKol);
               sTek:=sTek+sKol;
               sZena:='0.00';
               rFormat(sZena,CIZena);
               sTek:=sTek+sZena;
             end;

    {11}       {ост. кон}
           if p = 1 then
            begin
              skol:=e.Ost;
              rFormat(sKol,CKol);
              sTek:=sTek+sKol;
              if z then Str(e.OstEZ-e.OstEZ*NDS:CIZena:CMantissa,sZena)
              else Str(e.OstEZ2-e.OstEZ2*NDS:CIZena:CMantissa,sZena);
              rFormat(sZena,CIZena);
              sTek:=sTek+sZena;
            end
            else
            begin
              sKOl:='0';
              rFormat(sKol,CKol);
              sTek:=sTek+sKol;
              sZena:='0';
              rFormat(sZena,CIZena);
              sTek:=sTek+sZena;
            end;

           It^.List^.Insert(NewStr(sTek));
           It^.SetRange(It^.List^.Count);
         end;

 End;





procedure CalcOborot;

label l1;

Var StartDate,Stopdate, sDate, ostDate: TDAteString;
    Start, Stop, Day, OstNach: longint;
    SklKod: string[CRazdelKod];
    pf: file;
    IORez,i, kon :word;
    NItg: PNewItogType;
    Count, c1: word;
    BufItog: BufNewItogType;
    ItogBox: PBox;
    R: TRect;
    t: Text;
    s: string;
    sKol: string[CKol];
    sZena: string[CIZena];
    sArt, sArt1, sMake: string[CArtikul];
    sMakeKOd: string[CMakeKOd];
    z: boolean;  {закупочная цена !!!!!!!!!!!!!}
    sClName: string[CClient];
    sR, sR1: string[CRazdelKOd];
    sNds: string[CZena];
    NDS : Real;
    bNds: boolean;

    p:text;

(*

procedure P_CSV;


Begin

     write(p,DosToWin(NItg^.Dat.BazKod)+';');
     write(p,DosToWin(NItg^.Dat.Ost)+';');
   {  write(p,DosToWin(NItg^.Dat.OstDiv : Array [1..CDivision] Of LongInt;}

     write(p,NItg^.Dat.OstE:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.OstEZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.OstEZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.NMakeKod)+';');

     write(p,DosToWin(NItg^.Dat.PrhC)+';');
     write(p,DosToWin(NItg^.Dat.PrhS)+';');
     write(p,DosToWin(NItg^.Dat.PrhB)+';');

     write(p,NItg^.Dat.PrhEC:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhECZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhECZ2:CIZena:CMantissaZ,';');

     write(p,NItg^.Dat.PrhES:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhESZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhESZ2:CIZena:CMantissaZ,';');

     write(p,NItg^.Dat.PrhEB:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhEBZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.PrhEBZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.MrkC)+';');
    { write(p,DosToWin(NItg^.Dat.MrkCDiv: Array [1..CDivision] Of LongInt;}

     write(p,DosToWin(NItg^.Dat.MrkS)+';');
   {  write(p,DosToWin(NItg^.Dat.MrkSDiv: Array [1..CDivision] Of LongInt;}

     write(p,DosToWin(NItg^.Dat.MrkB)+';');
   {  write(p,DosToWin(NItg^.Dat.MrkBDiv: Array [1..CDivision] Of LongInt;}

     write(p,NItg^.Dat.MrkEC:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkECOpl:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkECZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkECZ2:CIZena:CMantissaZ,';');

     write(p,NItg^.Dat.MrkES:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkESZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkESZ2:CIZena:CMantissaZ,';');

     write(p,NItg^.Dat.MrkEB:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkEBZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkEBZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.MrkOptC)+';');
     write(p,NItg^.Dat.MrkOptRZC:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkOptCOpl:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkOptCZZ:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkOptCZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.MrkRoznC)+';');
     write(p,NItg^.Dat.MrkRoznRZC:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznCOpl:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznCZZ:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznCZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.MrkOptB)+';');
     write(p,NItg^.Dat.MrkOptRZB:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.MrkOptBOpl:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkOptBZZ:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkOptBZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.MrkRoznB)+';');
     write(p,NItg^.Dat.MrkRoznRZB:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznBOpl:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznBZZ:CIZena:CMantissaZ,';');
    write(p,NItg^.Dat.MrkRoznBZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.RewKol)+';');
     write(p,NItg^.Dat.RewRZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.RewZZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.RewZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.ReturnOptKol)+';');
     write(p,NItg^.Dat.ReturnOptOpl:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.ReturnOptRZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.ReturnOptZZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.ReturnOptZZ2:CIZena:CMantissaZ,';');

     write(p,DosToWin(NItg^.Dat.ReturnRoznKol)+';');
     write(p,NItg^.Dat.ReturnRoznOpl:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.ReturnRoznRZ:CIZena:CMantissaZ,';');
     write(p,NItg^.Dat.ReturnRoznZZ:CIZena:CMantissaZ,';');
     writeln(p,NItg^.Dat.ReturnRoznZZ2:CIZena:CMantissaZ,';');


End;

*)

Begin
  z:=true; {}

  if DatePeriodDialog(StartDate,Stopdate,true) then
  begin
    if SelectImport(17)=0 then z:=true
    else z:=false;
    if SelectImport(28)=0 then bNds:=false
    else bNds:=true;
    Start:=DateStringToDate(DateMask,StartDate);
    Stop:=DateStringToDate(DateMask,StopDate);

    New(NItg,Init);
    R.Assign(0,0,0,0);
    ItogBox := New(PBox, Init(R, 1, Nil));
    ItogBox^.NewList(New(PTextCollection, Init(0,1)));


    {остатки на начало периода - в лист}
      OstNach:=Start-1;
l1:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      Str(StrToInt(Rek^.Dat.KOd):CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (Path^.Dat.ToArchiv+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,Path^.Dat.ToArchiv+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
      end
      else
      begin
          dec(OstNach);
          if ostNach>Start-4 then goto l1
          else exit;
      End;

      DInfoMsg('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' ...',False);
      while not eof(pf) do
      begin
        Count:=0;
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
          NItg^.Dat:=BufItog.Dat[c1];
         if Not(GetRazdelStatus(NItg^.Dat.BazKod)) then
          begin
           s:='';
           sart:='';
           sArt:=NItg^.Dat.BazKOd;
         sNds:=GetIdField(FNDS,sArt);
         Delspace(sNds);
         if bNds then
         begin
           if sNds<>'' then
            NDS:=StrToReal(sNds)
            else  nds:=0;
         end
         else NDS:=0;
           NDS:=NDS/(100+NDS);
           s:=s+sArt;
           sArt:=NItg^.Dat.NMakeKod;
           rformat(sArt,CArtikul);
           s:=s+sArt;
           sKOl:=NItg^.Dat.Ost;
           rformat(sKOl,CKOl);
           if z then Str(NItg^.Dat.OstEZ-NItg^.Dat.OstEZ*NDS:CIZena:CMantissaz,sZena)
           else Str(NItg^.Dat.OstEZ2-NItg^.Dat.OstEZ2*NDS:CIZena:CMantissaz,sZena);
           rFormat(sZena,CIZena);
           s:=s+sKol+sZena;
           rformat(sNds,CLitr);
           sKOl:='0';
           rformat(sKOl,CKOl);
           sZena:='0.00';
           rformat(sZena,CIZena);
           {2}
           s:=s+sKOl+sZena;
           s:=s+sNDS;
           {3}
           s:=s+sKOl+sZena;
           {4}
           s:=s+sKOl+sZena;
           {5}
           s:=s+sKOl+sZena;
           {6}
           s:=s+sKOl+sZena;
           s:=s+sZena;
           {7}
           s:=s+sKOl+sZena+sZena;
           {8}
           s:=s+sKOl+sZena;
           {9}
           s:=s+sKOl+sZena;
           {10}
           s:=s+sKOl+sZena;
           {11}
           s:=s+sKOl+sZena;

           ItogBox^.List^.Insert(NewStr(s));
           ItogBox^.SetRange(ItogBox^.List^.Count);
          end;
        end;
      end;
      close(pf);
    NoinfoMsg;

    Assign(t,Path^.Dat.ToTemp+'oborot.csv');
    IORez:=ioresult;
    Rewrite(t);
    IORez:=ioresult;
    If IORez <> 0 Then
      Begin
          MessageBox(#3^M+#3'Не могу создать файл'
          +Path^.Dat.ToTemp+'oborot.csv',Nil,mfError+mfCancelButton);
          exit;
      End;

  {  Assign(p,Path^.Dat.ToTemp+'p.csv');
    rewrite(p);}
 {   write(p,'BazKod;Ost;OstE;OstEZ;OstEZ2;NMakeKod;PrhC];PrhS;PrhB;PrhEC;PrhECZ;PrhECZ2;PrhES;PrhESZ;'
    +'PrhESZ2;PrhEB;PrhEBZ;');
    write(p,'PrhEBZ2;MrkC;MrkS;MrkB;MrkEC;MrkECOpl;MrkECZ;MrkECZ2;MrkES;MrkESZ;'+
    'MrkESZ2;MrkEB;MrkEBZ;MrkEBZ2;MrkOptC;MrkOptRZC;');
write(p,'MrkOptCOpl;MrkOptCZZ;MrkOptCZZ2;MrkRoznC;MrkRoznRZC;MrkRoznCOpl;MrkRoznCZZ;MrkRoznCZZ2;MrkOptB;MrkOptRZB;MrkOptBOpl;'+
    'MrkOptBZZ;MrkOptBZZ2;MrkRoznB;MrkRoznRZB;MrkRoznBOpl;MrkRoznBZZ;MrkRoznBZZ2;RewKol;RewRZ;RewZZ;RewZZ2;ReturnOptKol;');
writeln(p,'ReturnOptOpl;ReturnOptRZ;ReturnOptZZ;ReturnOptZZ2;ReturnRoznKol;ReturnRoznOpl;ReturnRoznRZ;ReturnRoznZZ;'+
'ReturnRoznZZ2e');}


    for Day:=Start to Stop do
    begin
      sDate:=DateToDateString(DateMask,Day);
      DInfoMsg('Просматриваю операции за '+sDate+' ...',False);
      kon:=2;
     { if Day=Start then kon:=0;}
      if Day=Stop then kon:=1;
      while pos('-',sdate)>0 do delete(sdate,pos('-',sdate),1);
      if sdate[1]='0' then delete(sdate,1,1);
      Str(StrToInt(Rek^.Dat.KOd):CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);
      Assign(pf,Path^.Dat.ToArchiv+sDate+'.p'+sklKod);
      IORez:=ioresult;
      Reset(pf,SizeOf(NewItogType));
      IORez:=ioresult;
      If IORez <> 0 Then
      Begin
         { MessageBox(#3^M+#3'Не могу открыть файл'
          +Path^.Dat.ToArchiv+sDate+'.p'+sklKod,Nil,mfError+mfCancelButton);}
          continue;
      End;

      while not eof(pf) do
      begin
        Count:=0;
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
          NItg^.Dat:=BufItog.Dat[c1];
          {P_CSV;}
          if  Not(GetRazdelStatus(NItg^.Dat.BazKod)) then
          AddObToList(ItogBox,NItg^.Dat,kon,z,bNds);
        end;
      end;

      close(pf);
      NoInfoMSG;
    end;

DInfoMsg('Формирую отчет ... ',False);

sr1:='-1';

writeln(t,DosToWin(SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+'ПРИХОД'+
SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar
+SeparatorChar+SeparatorChar+'РАСХОД'+SeparatorChar));

writeln(t,DosToWin(SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+'Ост.нач'+SeparatorChar+SeparatorChar+'Поставщик'
+SeparatorChar+SeparatorChar+SeparatorChar+SeparatorChar+'Склад'+SeparatorChar+SeparatorChar+'Бартер'+SeparatorChar
+SeparatorChar+'Ревизии'
+SeparatorChar
+SeparatorChar+' Опт'+SeparatorChar+SeparatorChar+SeparatorChar+'Розн.'+SeparatorChar+SeparatorChar+'Склад'+SeparatorChar
+SeparatorChar
+'Бартер'+SeparatorChar+SeparatorChar+'Ревизии'+SeparatorChar+SeparatorChar+'Ост. кон.'));

writeln(t,DosToWin('Наименование'+SeparatorChar+'Поставщ.'+SeparatorChar+'Код тов'+SeparatorChar+'Код пост'+SeparatorChar
+'Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Ставка НДС'+SeparatorChar+'Кол-во'
+SeparatorChar+'Сумма'
+SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'
+SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Ц.опл'+
SeparatorChar+ ' Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Ц.опл'++SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'
+SeparatorChar+'Кол-во'
+SeparatorChar+'Сумма'
 +SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'+SeparatorChar+'Кол-во'+SeparatorChar+'Сумма'));


    if ItogBox^.List^.Count>0 then
    for i:=0 to ItogBox^.List^.Count-1 do
    begin
      s:=ItogBox^.GetText(i,ItogBox^.List^.Count);
      sArt:=copy(s,1,CArtikul);
      sMake:=copy(s,posMake,CArtikul);
      sMakeKod:=copy(sMake,2,CMakeKod);

      insert(SeparatorChar,s,posEOstK+1);
      insert(SeparatorChar,s,posOstK+1);
      insert(SeparatorChar,s,posERashRew+1);
      insert(SeparatorChar,s,posRashRew+1);
      insert(SeparatorChar,s,posEMrkB+1);
      insert(SeparatorChar,s,posMrkB+1);
      insert(SeparatorChar,s,posEMrkS+1);
      insert(SeparatorChar,s,posMrkS+1);
      insert(SeparatorChar,s,posERoznOpl+1);
      insert(SeparatorChar,s,posERoznC+1);
      insert(SeparatorChar,s,posRoznC+1);
      insert(SeparatorChar,s,posEOptOpl+1);
      insert(SeparatorChar,s,posEOptC+1);
      insert(SeparatorChar,s,posOptC+1);
      insert(SeparatorChar,s,posEPrhRew+1);
      insert(SeparatorChar,s,posPrhRew+1);
      insert(SeparatorChar,s,posEPrhB+1);
      insert(SeparatorChar,s,posPrhB+1);
      insert(SeparatorChar,s,posEPrhS+1);
      insert(SeparatorChar,s,posPrhS+1);
      insert(SeparatorChar,s,posNds+1);
      insert(SeparatorChar,s,posEPrhC+1);
      insert(SeparatorChar,s,posPrhC+1);
      insert(SeparatorChar,s,posEOstN+1);
      insert(SeparatorChar,s,posOstN+1);
      insert(SeparatorChar,s,posMake);

     {Поставщик}
      sClName:=GetMakeField(FFullMake,sMakeKOd,0);
     {Раздел}
      sR:=copy(sArt,1,2);
      if sr<>sr1 then
       begin
         writeln(t);
         writeln(t,DosToWin('Раздел: '),DosToWin(GetRazdel(sr)));
         writeln(t);
         sr1:=sr;
       end;
     {Наименование}
      writeln(t,DosToWin(GetIDField(FFFName,sArt)+SeparatorChar+sClName+SeparatorChar),DosToWin(s));
    end;

    Dispose(ITogBox,Done);
    Dispose(NItg,Done);
    Close(t);
  (*  Close(p); *)

    NoInfoMSG;

    MessageBox(#3^M+#3'Результаты сохранены в файле '
          +Path^.Dat.ToTemp+'oborot.csv',Nil,mfError+mfCancelButton);
  end;
End;



BEGIN
END.