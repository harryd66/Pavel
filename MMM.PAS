R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));

Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
     If Not(FExists(Path.ToDolg+ClientElement.Kod+'.dlg')) Then ClientElement.Employ:=False;

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'³'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Dispose(ClientList,Done);
  Exit;
 End;

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Assign(RealFile,Path.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(DE,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,DE^.Dat);
        If (DE^.Dat.Market.Active) Then
Begin
        If (DE^.Dat.Dolg>0.009) And Not(DE^.Dat.Full) Then
         Begin
          Str((DE^.Dat.Dolg):CIZena:CMantissa,w);

      If StrToInt(De^.DAt.Market.AgentKod)=0 Then
        Str(StrToReal(w)+StrToREal(AllDolg):CIZena:CMantissa,AllDolg)
      Else
        Str(StrToReal(w)+StrToReal(AllDolgA):CIZena:CMantissa,AllDolgA)

         End;
End;{active}
       End;{While}
      Dispose(DE,Done);
   ii:=IOResult;
      Close(RealFile);
   ii:=IOResult;
     End;{II=0}

   End;
 End;
Dispose(ClientList,Done);
