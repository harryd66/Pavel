program sample;

(*
   ODBC Sample Application
   Copyright (c) 1993 by Yasser Asmi (CIS 71543,2252)

   This simple program demonstrates how ODBC can be used.  It contains a
   few procedures that you may find useful.  Once you get more familiar
   with ODBC, you may want to implement an SQL object.  That is what I am
   doing these days.

      SQL_INIT             initialize and connect
      SQL_DONE             disconnect
      SQL_ERRBOX           display error message
      SQL_COLWIDTH         calculate column width
      SQL_EXEC             execute sql query
      SQL_FETCH            fetch data

   This program gives you an SQL prompt where you can enter any
   SQL queries.  After compiling this program, run it on a DBF
   file and try:

      select * from dBFNAME
*)

{$A+,I-,R-,S-,V-,B-,G+,X+,W-}

uses
   wintypes, winprocs, win31, strings, sql, sqlext, wincrt;

var
   g_env : henv;        (* global environment handle *)
   g_dbc : hdbc;        (* global database handle *)
   g_rc : integer;      (* global return code *)

const
   sql_p_pchar = sql_char;                        (* pascal mapping *)
   sql_p_longint = sql_integer;
   sql_p_integer = sql_smallint;


(*-- SQL Helper Functions --*)

function sql_init (con_in : pchar;                (* connection string *)
                   prompt : boolean;              (* display dialog box *)
                   wnd : hwnd) : boolean;         (* parent window handle *)

(*
   con_in describes the data source and login parameters
   send con_in='' and prompt=true for ODBC dialog box
   wnd is used only when dialog box is displayed

   con_in example: 'DSN=SQLserver;UID=USER;DATABASE=TEST'

   the local variable con_out will contain the actual connection string
   after an connection has been established.  If you want, make this another
   parameter
*)

var
   con_out : array [0..255] of char;
   con_outl : integer;
   comp : word;

begin
   sqlallocenv (g_env);
   sqlallocconnect (g_env, g_dbc);

   if prompt then
      comp := sql_driver_prompt
   else
      comp := sql_driver_complete;

   g_rc := sqldriverconnect (g_dbc, wnd, con_in, strlen (con_in),
                             con_out, sizeof (con_out), con_outl,
                             comp);
   sql_init := g_rc in [sql_success, sql_success_with_info];
end;


procedure sql_done;

begin
   sqldisconnect (g_dbc);
   sqlfreeconnect (g_dbc);
   sqlfreeenv (g_env);
end;


procedure sql_errbox (stmt : hstmt);

(*
   retrieves error information associated with a stmt
   from ODBC and displays it
*)

var
   errl : integer;
   code : longint;
   state : array [0..6] of char;
   m : array [0..80] of char;
   msg : array [0..255] of char;
   p : pchar;

begin
   msg [0] := #0;
   if sqlerror (g_env, g_dbc, stmt, state, code, msg, 240, errl) in
      [sql_success_with_info, sql_success] then
   begin
      p := strrscan (msg, ']');
      if p <> nil then
      begin
         inc (p);
         strcopy (m, p);
         p^ := #0;
         strcat (msg, state);
         wvsprintf (state, '-%d]'#13#10, code);
         strcat (msg, state);
         strcat (msg, m);
      end;
   end;
   messagebox (getfocus, msg, 'ODBC Error', mb_ok);
end;


function sql_colwidth (sqltype : integer;
                       colnamelen, precision : longint) : longint;

(*
   computes width of a column using sql type, column name
   length, and precision
*)

var
   l : word;

begin
   case sqltype of
      sql_date: l := 10;
      sql_time: l := 8;
      sql_timestamp: l := 23;
      sql_bit: l := 1;
      sql_decimal, sql_numeric: l := precision + 2;
      sql_tinyint: l := 4;
      sql_smallint: l := 6;
      sql_integer: l := 11;
      sql_bigint: l := 20;
      sql_real: l := 13;
      sql_double, sql_float: l := 22;
      sql_longvarchar, sql_longvarbinary: l := 50;          (* arbitrary *)
      sql_varbinary, sql_binary: l := precision * 2;
      else l := precision;
   end;
   if colnamelen > l then
      l := colnamelen;
   sql_colwidth := l;
end;


function sql_fetch (stmt : hstmt) : boolean;

begin
   g_rc := sqlfetch (stmt);
   sql_fetch := (g_rc = sql_success) or (g_rc = sql_success_with_info);
end;


function sql_exec (stmt : hstmt;
                   sqlstr : pchar) : boolean;

begin
   g_rc := sqlexecdirect (stmt, sqlstr, sql_nts);
   sql_exec := (g_rc = sql_success);
end;


(*-- Misc. Functions --*)

function rep (c : char;
              l : byte) : string;

var
   s : string;

begin
   fillchar (s [1], l, c);
   s [0] := char (l);
   rep := s
end;


function spc (l : byte) : string;

var
   s : string;

begin
   fillchar (s [1], l, #32);
   s [0] := char (l);
   spc := s
end;


function pad (s : string;
              l : byte) : string;

begin
   pad := copy (s + spc (l), 1, l);
end;


(*-- Test --*)

procedure odbc_test;

const
   maxcols = 32;

var
   collen : array [0..maxcols] of dword;
   outlen : array [0..maxcols] of longint;
   data : array [0..maxcols] of pchar;

   cname : array [0..32] of char;          (* column attributes *)
   cnamelen : integer;
   coltype : integer;
   cnull : integer;
   cscale : integer;

   colcount : integer;
   rowcount : longint;
   stmt : hstmt;                           (* statement handle *)
   sqlstr : array [0..150] of char;        (* SQL query *)


 procedure process_query;

 var
    i : integer;

 begin

    if not sql_exec (stmt, sqlstr) then
    begin
       sql_errbox (stmt);
       exit;
    end;

    sqlnumresultcols (stmt, colcount);

    if (colcount = 0) then                        (* not a select *)
    begin
       sqlrowcount (stmt, rowcount);
       if (rowcount > 0 ) then                    (* update, insert, or delete *)
          writeln (rowcount, ' rows affected')
       else
       begin
          writeln ('Operation successful');       (* other *)
          sqltransact (g_env, g_dbc, sql_commit);
       end;
    end
    else                                          (* select *)
    begin
       for i := 0 to colcount - 1 do              (* describe columns *)
       begin
          sqldescribecol (stmt, i + 1, cname, sizeof (cname),
                          cnamelen, coltype,
                          collen [i], cscale, cnull);
          collen [i] := sql_colwidth (coltype, cnamelen, collen [i]);

          write (pad (strpas (cname), collen [i] + 1));

          getmem (data [i], collen [i]);
          sqlbindcol (stmt, i + 1, sql_c_char, data [i], collen [i], @outlen [i]);
       end;
       writeln;
       for i := 0 to colcount - 1 do
          write (rep ('-', collen [i]), ' ');
       writeln;

       while true do
       begin
          if sql_fetch (stmt) then
          begin
             for i := 0 to colcount - 1 do
             begin
                if (outlen [i] = sql_null_data) then
                   strcopy (data [i], 'NULL');

                write (pad (strpas (data [i]), collen [i] + 1));
             end;
             writeln;
          end
          else
             break;
       end;
    end;
    writeln;

    for i := 0 to colcount - 1 do
      freemem (data [i], collen [i]);

 end;

var
   done : boolean;

begin

   if sql_init ('', true, 0) then
   begin
      repeat
         sqlstr [0] := #0;
         write ('SQL>');
         readln (sqlstr);
         writeln;
         done := strlen (sqlstr) = 0;

         if not done then
         begin
            sqlallocstmt (g_dbc, stmt);       (* alloc statement *)

            process_query;

            sqlfreestmt (stmt, sql_drop);     (* free statement *)
         end;
      until done;
   end
   else
      sql_errbox (sql_null_hstmt);

   sql_done;

end;

var
   lib : thandle;

begin
   lib := loadlibrary ('ODBC.DLL');

   strcopy (windowtitle, 'ODBC/SQL Sample');
   autotracking := false;
   initwincrt;

   odbc_test;

   freelibrary (lib);

end.


