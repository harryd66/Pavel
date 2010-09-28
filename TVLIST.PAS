unit TVLIST;
  interface
  uses Objects, App, Drivers, Views, Dialogs, msgBox;
  {==================================================================
   TVLIST

   This unit implements a set of TCollection types and TDialog types
   that facilitates the use of Lists and Listboxes.  Two abstract
   classes are defined, TLIST and TSORTEDLIST that provide for expanded
   TCollection functions. These Classes allow you to create instances
   of TCollections with members of ANY data type and still use them
   with a Listbox.  These are ABSTRACT classes, and virtual methods
   must be defined for each of your list types.  Both sequential and
   sorted lists are supported. Two classes TBOXER and TSORTEDBOXER
   are defined that provide TListBox functionality.  Finally, two
   classes TLISTDIALOG and TSORTEDLISTDIALOG provides an advanced
   Dialog for use of listboxes.  This class can enable adding to the
   lists, delete list items, editing list items, and search and
   selection from the list.  All or none of these capabilities can
   be selected. Also provided is a class LISTBOXINPUTLINE which can
   be inserted into other Dialog boxes and when selected in these
   dialog boxes will execute a TLISTDIALOG .

   Use the Compiler Defination of Define RegisterStreams to cause the
   Unit to register Plist and PSortedList in its initialization code,
   other wise registration must be done using RegisterTVList.

   Refer to TVLIST.DOC for documentation.  Refer to DEMO.PAS for examples
   of use.

   Copyright 1991 McQuay Technologies
     2329 E. Cortez Phoenix AZ 85028
     100 Sycamore Richmond TX
     Prodigy ID WPTD01E Compuserve 72307,320
     Released into the Public Domain, Give Credit were Credit Is Due
   ==================================================================}

  {==================================================================
   TList  abstract Class
   ==================================================================}
   const
     EndOfCollection = -1;    { Defines that Item was not found or
                                and Item Was not selected by TLISTDIALOG }

  type
    PList = ^TList;
    TList = object(TCollection)
      function CreateItem(Corner:Tpoint):pointer; virtual;
      procedure editItem(Corner:Tpoint;Item:pointer); virtual;
      function GetItemText(item:pointer;MaxLen:word):string; virtual;
      function AtAddNewItem(Corner:Tpoint;Index:integer):pointer;
      function MaxTextLength:word;
      end;
  {==================================================================
   TSortedList  abstract Class
   ==================================================================}
  type
    PSortedList = ^TSortedList;
    TSortedList = object(TSortedCollection)
      function CreateItem(Corner:Tpoint):pointer; virtual;
               { Override : Required
                 This function creates a Collection Object and
                 returns a pointer to it.  This could use a
                 dialog box or any other method to obtain
                 data needed to create an instance of your
                 collection object.  Must return a nil
                 pointer id no object was created. This method
                 can be left as is (no override) if Adding to a
                 list with TListDialog is not desired.}
      procedure editItem(Corner:TPoint;Item:pointer); virtual;
               { Override : Required
                 This function edits the Item.  Likely will
                 use a dialog box, but could use something
                 else. This method can be left as is (no
                 override) if Editing a list element with
                 TListDialog is not desired.}
      function GetItemText(item:pointer;MaxLen:word):string; virtual;
               { Override : Required
                 This function returns a string that represents
                 the data in your Collection Object item.  This will
                 be used by the listbox to display data in your
                 object item }
      function AtAddNewItem(Corner:TPoint):pointer;
               { Override : Never
                 adds an item to the list at the Index position using
                 Atinsert(index,CreateItem).  Use Count for index to
                 add to end, 0 to add to top.  Will return a pointer
                 to new item.  Should return a nil if not succesful.}
      function MaxTextLength:word;
               { Override : Never
                 Uses Foreach and GetItemText(,256) to determine length
                 of longest string. }
      end;
  {==================================================================
   TListBoxer  Class
   ==================================================================}
   type
   PListBoxer = ^TListBoxer;
   TListBoxer = object(TListBox)
     function GetText(Item:Integer; MaxLen:integer):string; virtual;
     procedure HandleEvent(var Event:TEvent); virtual;
     end;
  {==================================================================
   TSortedListBoxer  Class
   ==================================================================}
   type
   PSOrtedListBoxer = ^TSortedListBoxer;
   TSortedListBoxer = object(TListBoxer)
     function GetText(Item:Integer; MaxLen:integer):string; virtual;
     end;
  {==================================================================
   TList an TListDialog Support Constants and Types
   ==================================================================}
   const

   { Behavior Constants }
     sfAdd    = $1;
     sfDelete = $2;
     sfEdit   = $4;
     sfSearch = $8;
     sfPromptDelete = $10;
     SfPromptExit = $20;
     sfFullEdit = sfAdd + sfDelete + sfEdit;
     sfDoall  = $FF;

  type
    TListRec = record
      Item:pointer;
      Index:integer;
      end;

  {==================================================================
   TListDialog  Class
   ==================================================================}
  type
   PListDialog = ^TListDialog;
   TListDialog = object(TDialog)
     AB : byte;
     TLR:TListRec;
     Max:byte;
     List:pointer;
     LB:PlistBox;
     X,Y:word;
     SearchString:PString;
     constructor init(var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                      TheList : PList; BoxHeader:TTitleStr);
     procedure   BASICinit(var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                           MaxStringLen:byte); virtual;
     function  DataSize: word; virtual;
     procedure GetData(var rec); virtual;
     procedure SetData(var rec); virtual;
     procedure HandleEvent(var Event:TEvent); virtual;
     end;

  {==================================================================
   TSortedListDialog  Class
   ==================================================================}
   PSortedListDialog = ^TSortedListDialog;
   TSortedListDialog = object(TListDialog)
     constructor init(var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                      TheList : PSortedList; BoxHeader:TTitleStr);
     procedure HandleEvent(var Event:TEvent); virtual;
     end;
  {==================================================================
   TListDialogInputField  Class
   ==================================================================}
  type
  PListDialogInputField= ^TListDialogInputField;
  TListDialogInputField= object(TInputLine)
    TD:pointer;  { Pointer to Dialog }
    TL:pointer;  { Pointer to List   }
    max:byte;
    Index:word;
    Sorted:boolean;
    constructor init (Field:TPoint;ListLocation:Tpoint;ListHeight:word;
                      Title:String;Behavior:byte;AList:Pointer;
                      BoxHeader:string;SortedList:boolean);
    function  DataSize:word; virtual;
    procedure GetData(Var Rec); virtual;
    procedure SetData(Var Rec); virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
    end;
  {==================================================================
   TVList Resource Registration
   ==================================================================}
   procedure RegisterTVList;
  {==================================================================
   Utilities
   ==================================================================}
   procedure MakeTrect(Corner:Tpoint;Xsize,YSize:integer;var Bounds:Trect);
   Procedure TPointAssign(var P:TPoint; X,Y:integer);
{=============================================================}
 implementation
 const
   { Stream Registration Constants }
   RList : TStreamRec = (
     ObjType:200;
     VmtLink: ofs(TypeOf(Tlist)^);
     Load:@Tlist.load;
     Store:@TList.Store);
   RSortedList :TStreamRec = (
     ObjType:201;
     VmtLink:ofs(TypeOf(TSortedList)^);
     Load:@TSortedList.load;
     Store:@TSortedList.Store);


   { TlistDialog INternal Commands }
   const
       tldAdd    = $2001;
       tldEdit   = $2002;
       tldDelete = $2003;
       tldPicked = $2004;

   { Map for writestr under TDialog }
       SearchPaletteMap = 28;
  {==================================================================
   Utilities
   ==================================================================}
  function Lput(source:string;width:word):string;
    var
      Temp:string[80];
    begin
      if length(source)>width then
        Lput := copy(source,1,width)
      else
        begin
        fillchar(Temp[1],width-length(source),32);
        Temp[0] := char(width-length(source));
        Lput := source + Temp;
        end;
	  end;
   {-----------------------------------}
   Procedure TPointAssign(var P:TPoint; X,Y:integer);
     begin
     P.X := X;
     P.Y := Y;
     end;
   {-----------------------------------}
   procedure MakeTrect(Corner:Tpoint;Xsize,YSize:integer;var Bounds:Trect);
     var
       DX,DY:integer;
       SH:byte;
     begin
     SH := ScreenHeight-2;
     with Corner do
       begin
       DX := (X+XSize)-1;
       DY := (Y+YSize)-1;
       if DX>ScreenWidth then
         if (XSize>ScreenWidth) then
           begin
           X := 0;
           DX := ScreenWidth;
           end
         else
           begin
           X := X-(DX-ScreenWidth);
           DX := (X+Xsize)-1;
           end;
       if DY>SH then
         if (YSize>SH) then
           begin
           Y := 0;
           DY := SH;
           end
         else
           begin
           Y := Y-(DY-SH);
           DY := (Y+Ysize)-1;
           end;
      end;
     Bounds.assign(Corner.X,Corner.Y,DX,DY);
  end;
  {==================================================================
   TListBoxer  Class
   ==================================================================}
   procedure TListBoxer.HandleEvent(var Event:TEvent);
     var
       i:word;
     begin
     with Event do
       if ((What=evKeyDown) and (keycode=kbEnter)) or
          ((What=evBroadCast) and (Command=cmListItemSelected)) then
            begin
            What := evCommand;
            Command := tldPicked;
            end
       else
           TListbox.HandleEvent(Event);
     end;
   {-----------------------------------}
   function TListBoxer.GetText(Item:Integer; MaxLen:integer):string;
       var
         P:pointer;
         T:string;
     begin
     P:= List^.At(Item);
     T:= Plist(List)^.GetItemText(P,MaxLen);
     GetText := T;
     end;

  {==================================================================
   TSortedListBoxer  Class
   ==================================================================}
   {-----------------------------------}
   function TSortedListBoxer.GetText(Item:Integer; MaxLen:integer):string;
       var
         P:pointer;
         T:string;
     begin
     P:= List^.At(Item);
     T:= PSOrtedlist(List)^.GetItemText(P,MaxLen);
     GetText := T;
     end;
   {-----------------------------------}

  {==================================================================
   TList  abstract Class
   ==================================================================}
    function TList.CreateItem(Corner:TPoint):pointer;
      begin CreateItem := nil end;
    {------------------------------------}
	  procedure TList.editItem(Corner:TPoint;Item:pointer);
      begin end;
    {------------------------------------}
    function TList.GetItemText(item:pointer;MaxLen:word):string;
      begin
      Abstract;
      end;
    {------------------------------------}
    function TList.AtAddNewItem(Corner:TPoint;Index:integer):pointer;
      var P:pointer;
      begin
      P := CreateItem(Corner);
      if P<>nil then
        AtInsert(Index,P);
      AtAddNewItem := P;
      end;
    {------------------------------------}
    function TList.MaxTextLength:word;
      var
        Tmax:word;
      procedure GetMAx(P:pointer); far;
        { Simply searches list and finds longest string }
        var
          I:word;
          Temp:string;
        begin
        if P<>nil then
          begin
          Temp := GetItemText(P,$ff);
          i:=length(Temp);
          if i>TMax then TMax := i;
          end;
        end;

      begin
        TMax := 0;
        foreach(@GetMax);
        MaxTextLength := Tmax;
      end;
  {==================================================================
   TSortedList  abstract Class
   ==================================================================}
    function TSortedList.CreateItem(Corner:TPoint):pointer;
      begin  CreateItem := nil end;
    {------------------------------------}
	  procedure TSortedList.editItem(Corner:TPoint;Item:pointer);
      begin end;
    {------------------------------------}
    function TSortedList.GetItemText(item:pointer;MaxLen:word):string;
      begin
      Abstract;
      end;
    {------------------------------------}
    function TSortedList.AtAddNewItem(Corner:TPoint):pointer;
      var P:pointer;
      begin
      P := CreateItem(Corner);
      if P<>nil then
        Insert(P);
      AtAddNewItem := P;
      end;
    {------------------------------------}
    function TSortedList.MaxTextLength:word;
      var
        Tmax:word;
      procedure GetMAx(P:pointer); far;
        { Simply searches list and finds longest string }
        var
          I:word;
          Temp:string;
        begin
        if P<>nil then
          begin
          Temp := GetItemText(P,$ff);
          i:=length(Temp);
          if i>TMax then TMax := i;
          end;
        end;

      begin
        TMax := 0;
        foreach(@GetMax);
        MaxTextLength := Tmax;
      end;

  {==================================================================
   TListDialog   Class
   ==================================================================}
     const
       NoSortIndent = 5;
       SortIndent = 18;
       TopIndent = 11;
     procedure   TListDialog.BASICinit(var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                           MaxStringLen:byte);
       var
         PV:PView;
         i:word;
         R:Trect;
       begin
       { Minimum width for OK and Cancel is 10}
        if MaxStringLen<10 then MaxStringLen:= 11;

       { Now if Buttons needed make sure Dialog is wide enough for
         text and Buttons (add column width here later )}
        if (sfFullEdit and Behavior)>0 then
          i:=SortIndent else i:= NoSortIndent;
        with Bounds do
          if ((B.X - A.X)) < MaxStringLen+i then
              B.X:=A.X+MaxStringLen+i;

       { Now Check if adequate height provided for list and
         OK and Cancel Buttons, List can be minimum 4 items high. }
        i := TopIndent;
        if (sfSearch and Behavior)=0 then
          dec(i);
        with Bounds do
          if (B.Y-A.Y)<i then B.Y := A.Y+i;

       { Ok init Dialog }
        TDialog.init(Bounds,ATitle);

       { Save Max }
         Max := MaxStringLen;

       { Set Behavior }
        AB := Behavior;
       { Can not have search here }
        AB := AB and $F7;

       { Set Clear Record }
        with TLR do
         begin
         Item:=nil;
         Index:=-1;
         end;

       { Ok Setup Search String Area if selected }
        if (sfSearch and Behavior)>0 then
          begin
          X := 1;
          Y := 1;
          end
        else
         begin
         X := 0;
         Y := 0;
         end;
       { Setup Buttons }
        if (sfFullEdit and AB)>0 then
          begin
          R.assign(Max+5,2,Max+13,4);
          if (sfAdd and AB)>0 then
            insert(new(PButton, init(R,' Add ',tldAdd,bfnormal)));
          if (sfedit and AB)>0 then
            begin
            R.assign(Max+5,4,Max+14,6);
            insert(new(PButton, init(R,' Edit ',tldedit,bfnormal)));
            end;
          if (sfdelete and AB)>0 then
            begin
            R.assign(Max+5,6,Max+16,8);
            insert(new(PButton, init(R,' Delete ',tlddelete,bfnormal)));
            end;
          end;
        { add OK and Cancel }
          I := (Bounds.B.Y-Bounds.A.Y) - 3;
          R.assign(1,i,6,I+2);
          insert(new(PButton, init(R,'Ok',cmOk,bfnormal)));
          R.assign(6,i,15,i+2);
          insert(new(PButton, init(R,'Cancel',cmCancel,bfDefault)));

     end;
    {------------------------------------------------------------------}

     constructor TListDialog.init
                   (var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                    TheList : PList; BoxHeader:TTitleStr);
      var
        R:Trect;
        SB:PSCrollBar;
        i:word;
        TMax:word;
      {-------------------------------------}
        begin
       { Get Max Text Width of Tlist Items }
        Tmax := TheList^.MaxTextLength;

        BASICinit(Bounds,ATitle,Behavior,TMax);

       { Save List }
        List := TheList;

       { Ok now set up a scrollbar }
        i:=(Bounds.B.Y-Bounds.A.Y)-4;
        R.assign(Max+2,Y+2,Max+3,i);
        SB := new(PScrollBar, init(R));
        insert(SB);

       { Ok now setup ListBox }
        R.assign(1,Y+2,Max+2,i);
        LB := new(PlistBoxer, init(R,1,SB));
       { Setup Initial Data to List Box, will be chnaged by
         SetData later}
        LB^.newlist(TheList);
        LB^.FocusItem(0);
        insert(LB);
        { Add Box Header }
        if BoxHeader <> '' then
          begin
          R.assign(1,Y+1,length(BoxHeader)+2,Y+2);
          insert(new(Plabel,init(R,BoxHeader,LB)));
          end;
        end;
    {-------------------------------------------------}
     function  TListDialog.DataSize: word;
       begin
       DataSize := sizeof(TLR);
       end;
    {-------------------------------------------------}
     procedure TListDialog.GetData(var rec);
       begin
       move(TLR,rec,DataSize);
       end;
    {-------------------------------------------------}
     procedure TListDialog.SetData(var rec);
       begin
       move(rec,TLR,dataSize);
       if (TLR.index>0)and(TLR.INDEX<PLIST(List)^.count) then
         LB^.focusItem(TLR.index);
       end;
    {-------------------------------------------------}
     procedure TListDialog.HandleEvent(var Event:TEvent);
     var
       Affirmative : word;
       FocusedIndex:integer;
       FocusedItem:pointer;
       NextEvent:TEvent;
       MsgStr,ParamStr:Pstring;
       R:TRect;
      {--------------------------}
      procedure UpdateLB(Index:integer);
        begin
      { A real No No ! But it is the only way to update
        LB and keep the List from being disposed! }
        LB^.List := nil;
        LB^.newlist(List);
        LB^.focusItem(Index);
        LB^.drawview;
        end;
      {--------------------------}

     begin
      if (Event.What=evCommand) then
        case Event.Command of
         { OK It was selected we are ready to exit, Save data }
         cmOk:
           with TLR do
             begin
             Index := LB^.Focused;
             Item:=  PList(List)^.at(Index);
             end;
         { Whoops, a cancel, make sure nil is loaded }
         cmCancel,CmQuit:
           with TLR do
             begin
             Index := EndOfCollection;
             Item:=  nil;
             end;
         end;
       TDialog.HandleEvent(Event);
       if LB^.GetState(sfFocused) then
             LB^.HandleEvent(Event);
       FocusedIndex := LB^.Focused;
       with Event do
           case What of
             evCommand:
               case Command of
              { Ok it was picked }
                 tldpicked:
                   begin
                   with NextEvent do
                     { If prompt then move to OK Button }
                     if (AB and sfPromptExit)>0 then
                       begin
                       Selectnext(true);
                       Selectnext(true);
                       end
                     else
                       { Else Set CmOK }
                       begin
                       What := evCommand;
                       command := cmOk;
                       end;
                   putevent(NextEvent);
                   end;

              { Add Record }
                 tldAdd:
                   with PList(List)^ do
                     begin
                   { OK Add a new Item, check if nil afterward }
                     R.Assign(1,1,0,0);
                     MakeGlobal(R.A,R.A);
                     FocusedItem := AtAddNewItem(R.A,FocusedIndex);
                     if FocusedItem <> nil then
                       begin
                       FocusedIndeX := indexOf(FocusedItem);
                       UpdateLB(FocusedIndex);
                       end;
                     end;

               { Edit Record }
                 tldEdit:
                   begin
                   R.Assign(1,1,0,0);
                   MakeGlobal(R.A,R.A);
                   with PList(List)^ do
                     EditItem(R.A,PList(List)^.at(LB^.Focused));
                   LB^.drawview;
                   end;

               { Delete Record }
                 tldDelete:
                   { Make sure something is there}
                   if PList(list)^.count>0 then
                     begin

                     { If prompt then prompt }
                     if (AB and sfPromptDelete)>0 then
                       begin
                       with PList(List)^ do
                         ParamStr := newstr(GetItemText(AT(FocusedIndex),Max));
                         MsgStr := newStr('Delete: %s');
                       Affirmative :=
                         MessageBox(MsgSTr^,@ParamStr,
                                    MFConfirmation+MfYesButton+MfNoButton);
                       disposestr(Paramstr);
                       disposestr(MsgStr);
                       end
                     else
                       Affirmative := cmYes;

                     { If ok to delete then do so }
                     if Affirmative= cmYes then
                        begin

                        { Delete the focused item}
                        PList(List)^.Delete(
                           PList(List)^.AT(FocusedIndex));

                        { Now pack the list }
                        PList(list)^.pack;

                        { Update LISTBOX  }
                        if FocusedIndex>=PList(list)^.count then
                            UpdateLB(FocusedIndex-1)
                          else
                            UpdateLB(focusedIndex);
                        end;
                   end;
               end;
           end;
        end;
  {==================================================================
   TSortedListBoxDialog  Class
   ==================================================================}
     constructor TSortedListDialog.init
                   (var Bounds:Trect; ATitle:TTitleStr;Behavior:byte;
                    TheList : PSortedList; BoxHeader:TTitleStr);
      var
        R:Trect;
        SB:PSCrollBar;
        i:word;
        TMax:word;
        Fill:String[80];
      {-------------------------------------}
      procedure GetMAx(P:pointer); far;
        var
          I:word;
          Temp:string;
        begin
        Temp := TheList^.GetItemText(P,$ff);
        i:=length(Temp);
        if i>TMax then TMax := i;
        end;
      {-------------------------------------}
        begin
       { Get Max Text Width of Tlist Items }
        Tmax := 0;
        Thelist^.foreach(@GetMax);

        BASICinit(Bounds,ATitle,Behavior,TMax);

       { Save List }
        List := TheList;

       { Save Max String Legnth }
        Max := TMax;

       { Ok now set up a scrollbar }
        i:=(Bounds.B.Y-Bounds.A.Y)-4;
        R.assign(Max+2,Y+2,Max+3,i);
        SB := new(PScrollBar, init(R));
        insert(SB);

       { Ok now setup ListBox }
        R.assign(1,Y+2,Max+2,i);
        LB := new(PSortedlistBoxer, init(R,1,SB));
       { Setup Initial Data to List Box, will be chnaged by
         SetData later}
        LB^.newlist(TheList);
        LB^.FocusItem(0);
        insert(LB);
        { Add Box Header }
        if BoxHeader <> '' then
          begin
          R.assign(1,Y+1,length(BoxHeader)+2,Y+2);
          insert(new(Plabel,init(R,BoxHeader,LB)));
          end;

      { Clear Search Field }
        FillChar(Fill[1],Max,32);
        Fill[0] := Char(max);
        SearchString := newstr(Fill);
        SearchString^ := '';

      { Set behavior or search }
        AB := AB or Behavior;
      end;
    {-------------------------------------------------}
     procedure TSortedListDialog.HandleEvent(var Event:TEvent);
     var
       OldValue: Integer;
       Affirmative : word;
       FocusedIndex:integer;
       FocusedItem:pointer;
       NextEvent:TEvent;
       MsgStr,ParamStr:Pstring;
       R:Trect;
      {--------------------------}
       procedure KeySearch(KeyStr:PString);
        var
          i:integer;
        begin
        PSortedList(List)^.search(KeyStr,i);
        LB^.focusItem(i);
        {++}
        If X>0 then
          writestr(X,Y,Lput(SearchString^,Max),SearchPaletteMap);
        ClearEvent(Event);
       end;
      {--------------------------}
      procedure UpdateLB(Index:integer);
        begin
      { A real No No ! But it is the only way to update
        LB and keep the List from being disposed! }
        LB^.List := nil;
        LB^.newlist(List);
        LB^.focusItem(Index);
        LB^.drawview;
        end;
      {--------------------------}

     begin
      if (Event.What=evCommand) then
        case Event.Command of
         { OK It was selected we are ready to exit, Save data }
         cmOk:
           with TLR do
             begin
             Index := LB^.Focused;
             Item:=  PSortedList(List)^.at(Index);
             end;
         { Whoops, a cancel, make sure nil is loaded }
         cmCancel,CmQuit:
           with TLR do
             begin
             Index := EndOfCollection;
             Item:=  nil;
             end;
         end;
       if (Event.What<>evkeydown)or(Event.keycode<>$3920) then
         TDialog.HandleEvent(Event);
       OldValue := LB^.Focused;
       if LB^.GetState(sfFocused) and
        { Do not let List Box Use the SpaceBar to select }
        (not ((Event.What=evKeyDown)and(Event.KeyCode=$3920))) then
             LB^.HandleEvent(Event);
       if (OldValue <> LB^.Focused) then
         begin
         if X>0 then
           begin
           {++}
           SearchString^ := '';
           writestr(X,Y,Lput(SearchString^,Max),SearchPaletteMap);
           end;
         end
       else
       begin
       FocusedIndex := LB^.Focused;
       with Event do
           case What of
             evKeyDown:
              if (Event.CharCode <> #0)  then
                begin
                case KeyCode of
                   kbback:
                     if Length(SearchString^)>0 then
                       SearchString^[0] := char(length(SearchString^)-1);
                  else
                    if (length(SearchString^)<Max) and
                    (CharCode > #31)and(ScanCode<>0) then
                      SearchString^ := SearchString^+ charCode;

                  end;
                KeySearch(SearchString);
                end;
             evCommand:
               case Command of
              { Ok it was picked }
                 tldpicked:
                   begin
                   with NextEvent do
                     { If prompt then move to OK Button }
                     if (AB and sfPromptExit)>0 then
                       begin
                       Selectnext(true);
                       Selectnext(true);
                       end
                     else
                       { Else Set CmOK }
                       begin
                       What := evCommand;
                       command := cmOk;
                       end;
                   putevent(NextEvent);
                   end;

              { Add Record }
                 tldAdd:
                   with PSortedList(List)^ do
                     begin

                   { OK Add a new Item, check if nil afterward }
                     R.Assign(1,1,0,0);
                     MakeGlobal(R.A,R.A);
                     FocusedItem := AtAddNewItem(R.A);
                     if FocusedItem <> nil then
                       begin
                       FocusedIndeX := indexOf(FocusedItem);
                       UpdateLB(FocusedIndex);
                       end;
                     end;

               { Edit Record }
                 tldEdit:
                   begin
                   R.Assign(1,1,0,0);
                   MakeGlobal(R.A,R.A);
                   FocusedItem := PSortedList(List)^.at(LB^.Focused);
                   with PSortedList(List)^ do
                     EditItem(R.A,FocusedItem);
                   PSortedList(List)^.Delete(FocusedItem);
                   PSortedList(List)^.insert(FocusedItem);
                   PSortedList(list)^.pack;
                   UpdateLB(PsortedList(list)^.indexof(focusedItem));
                   end;

               { Delete Record }
                 tldDelete:
                   { Make sure something is there}
                   if PsortedList(list)^.count>0 then
                     begin

                     { If prompt then prompt }
                     if (AB and sfPromptDelete)>0 then
                       begin
                       with PSortedList(List)^ do
                         ParamStr := newstr(GetItemText(AT(FocusedIndex),Max));
                         MsgStr := newStr('Delete: %s');
                       Affirmative :=
                         MessageBox(MsgSTr^,@ParamStr,
                                    MFConfirmation+MfYesButton+MfNoButton);
                       disposestr(Paramstr);
                       disposestr(MsgStr);
                       end
                     else
                       Affirmative := cmYes;

                     { If ok to delete then do so }
                     if Affirmative= cmYes then
                        begin

                        { Delete the focused item}
                        PSortedList(List)^.Delete(
                           PSortedList(List)^.AT(FocusedIndex));

                        { Now pack the list }
                        PSortedList(list)^.pack;

                        { Update LISTBOX  }
                        if FocusedIndex>=PsortedList(list)^.count then
                            UpdateLB(FocusedIndex-1)
                          else
                            UpdateLB(focusedIndex);
                        end;
                   end;
               end;
           end;
        end;
     end;
   {======================================================
    TListDialogInputField
    ======================================================}
    constructor TListDialogInputField.init
                     (Field:TPoint;ListLocation:Tpoint;ListHeight:word;
                      Title:string;Behavior:byte;AList:Pointer;
                      BoxHeader:string;SortedList:boolean);
      var
        R:Trect;
        Tmax:byte;
        Corner:TPoint;
      begin
        {Finds Max Size }
        if SortedList then
          TMax := PSortedlist(Alist)^.MaxTextLength
        else
          TMax := Plist(Alist)^.MaxTextLength;

        { Locate and initialize field }
        R.assign(Field.X,Field.Y,Field.X+TMax+3,Field.Y+1);
        TInputLine.init(R,TMax+2);

        {initialize Slots }
        Sorted := SortedList;
        TL := Alist;
        Max := Tmax;

        { determine R based on bounds of owner of TInputLine }
        MakeGlobal(Field,Field);
        Field.X := Field.X + ListLocation.X;
        Field.Y := Field.Y + ListLocation.Y;
        MakeTrect(Field,Max+13,ListHeight-1,R);

       { Initialize ListDialog }
        if Sorted then
          begin
          TD := new(PSortedListDialog,Init(R,Title,Behavior,AList,BoxHeader));
          with PSortedList(Alist)^ do
            Data^ := GetItemText(AT(0),max);
          end
        else
          begin
          TD := new(PListDialog,Init(R,Title,Behavior,AList,BoxHeader));
          with PList(Alist)^ do
            Data^ := GetItemText(AT(0),max);
          end;
      end;

  {-----------------------------------------------------}
    procedure TListDialogInputField.HandleEvent(Var Event:TEvent);
   {------------------------}
      procedure OpenListDialog;
       var
         TCData : TlistRec;
         Result:word;
       begin
         TCData.index := index;
         if Sorted then
           begin
           TCData.item := PSortedList(TL)^.at(index);
           PSortedListDialog(TD)^.setdata(TCData);
           result := Desktop^.ExecView(PSortedListDialog(TD));
           end
         else
           begin
           TCData.item := PList(TL)^.at(index);
           PListDialog(TD)^.setdata(TCData);
           result := Desktop^.ExecView(PListDialog(TD));
           end;
         If Result = cmOk then
           begin
           if Sorted then
             begin
             PSortedListDialog(TD)^.Getdata(TCData);
             Data^ :=PSortedList(TL)^.getitemtext(TCData.item,max);
             end
           else
             begin
             PListDialog(TD)^.Getdata(TCData);
             Data^ :=PList(TL)^.getitemtext(TCData.item,max);
             end;
           Index :=  TCData.index;
           end
         else
           CLearEvent(Event);
       end;
    {======================================}
      begin
        with Event do
          case What of
            evMousedown:
               begin
                 if double and getstate(sffocused+sfselected) then
                   OpenListDialog
               end;
            evKeyDown:
              case KeyCode of
                kbins,kbRight,kbLeft,kbCtrlF2:
                  begin
                  OpenListDialog;
                  end;
                kbenter,kbdown:
                  begin
                  KeyCode := kbTab;
                  end;
                kbup:
                  begin
                  KeyCode := kbShiftTab;
                  end;
               end;
             end;
        TInputLine.HandleEvent(Event);
      end;
  {-----------------------------------------------------}
    function  TListDialogInputField.DataSize:word;
      begin DataSize := 2; end;
   {------------------------------------------------------}
    procedure TListDialogInputField.GetData(Var Rec);
      var Value:word absolute rec;
      begin Value := index; end;
   {------------------------------------------------------}
    procedure TListDialogInputField.SetData(Var Rec);
      var
        Value:word absolute Rec;
      begin
        if (Value = EndOfCollection)or(Value >= PCOllection(TL)^.Count) then
          Index := PCollection(TL)^.count -1
        else
          Index := Value;
      if sorted then
        data^ := PSortedList(TL)^.getItemText(PList(TL)^.at(index),max)
      else
        data^ := PList(TL)^.getItemText(PSortedList(TL)^.at(index),max);
      end;
  {-------------------------------------------------}
  procedure RegisterTVList;
    begin
    RegisterType(RList);
    RegisterType(RSortedList);
    end;
  {-------------------------------------------------}

  {$Ifdef RegisterStreams }
   begin
   RegisterTVList;
  {$EndIf}
end.

  { Notes:
    Need to allow control of placemnet of edit and delte Dialogs, perhaps
      with a set Location procedure.
    Need to fill in a search string when dialog is evoked, try putting
      a write in dialog.draw?
    Need to create a TDialog class that traps (space) different and
      allows cursor  keys to move among fields
  }
