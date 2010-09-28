Unit sql;

(*
   ODBC.DLL Interface Unit, Part I

   Microsoft ODBC "SQL Core Functions"

   Translated by Yasser Asmi (CIS 71543,2252)
*)

{$A+,I-,R-,S-,V-,B-,G+,X+,W-}

interface

uses
   wintypes;

const
(* Generally useful constants *)
   SQL_NTS                =  -3;  (* NTS = Null Terminated String  *)
   SQL_SQLSTATE_SIZE      =   5;  (* size of SQLSTATE              *)
   SQL_MAX_MESSAGE_LENGTH = 512;  (* message buffer size           *)
   SQL_MAX_DSN_LENGTH     =  32;  (* maximum data source name size *)

(* Retcodes *)
   SQL_ERROR             = -1;
   SQL_INVALID_HANDLE    = -2;
   SQL_NEED_DATA         = 99;
   SQL_NO_DATA_FOUND     = 100;
   SQL_SUCCESS           = 0;
   SQL_SUCCESS_WITH_INFO = 1;

(* SQLFreeStmt defines *)
   SQL_CLOSE        = 0;
   SQL_DROP         = 1;
   SQL_UNBIND       = 2;
   SQL_RESET_PARAMS = 3;

(* SQLSetParam defines *)
   SQL_C_DEFAULT = 99;

(* SQLTransact defines *)
   SQL_COMMIT   = 0;
   SQL_ROLLBACK = 1;

(* Standard SQL datatypes, using ANSI type numbering *)
   SQL_CHAR     = 1;
   SQL_NUMERIC  = 2;
   SQL_DECIMAL  = 3;
   SQL_INTEGER  = 4;
   SQL_SMALLINT = 5;
   SQL_FLOAT    = 6;
   SQL_REAL     = 7;
   SQL_DOUBLE   = 8;
   SQL_VARCHAR  = 12;

   SQL_TYPE_MIN  = 1;
   SQL_TYPE_NULL = 0;
   SQL_TYPE_MAX  = 12;

(* C datatype to SQL datatype mapping *)
   SQL_C_CHAR   = SQL_CHAR;       (* CHAR, VARCHAR, DECIMAL, NUMERIC *)
   SQL_C_LONG   = SQL_INTEGER;    (* INTEGER          *)
   SQL_C_SHORT  = SQL_SMALLINT;   (* SMALLINT         *)
   SQL_C_FLOAT  = SQL_REAL;       (* REAL             *)
   SQL_C_DOUBLE = SQL_DOUBLE;     (* FLOAT, DOUBLE    *)

(*
   NULL status constants.  These are used in SQLColumns, SQLColAttributes,
   SQLDescribeCol, and SQLSpecialColumns to describe the nullablity of a
   column in a table.  SQL_NULLABLE_UNKNOWN can be returned only by
   SQLDescribeCol or SQLColAttributes.  It is used when the DBMS's meta-data
   does not contain this info.
*)
   SQL_NO_NULLS         = 0;
   SQL_NULLABLE         = 1;
   SQL_NULLABLE_UNKNOWN = 2;

(* Special length values *)
   SQL_NULL_DATA      = -1;
   SQL_DATA_AT_EXEC   = -2;

(* SQLColAttributes defines *)
   SQL_COLUMN_COUNT          = 0;
   SQL_COLUMN_NAME           = 1;
   SQL_COLUMN_TYPE           = 2;
   SQL_COLUMN_LENGTH         = 3;
   SQL_COLUMN_PRECISION      = 4;
   SQL_COLUMN_SCALE          = 5;
   SQL_COLUMN_DISPLAY_SIZE   = 6;
   SQL_COLUMN_NULLABLE       = 7;
   SQL_COLUMN_UNSIGNED       = 8;
   SQL_COLUMN_MONEY          = 9;
   SQL_COLUMN_UPDATABLE      = 10;
   SQL_COLUMN_AUTO_INCREMENT = 11;
   SQL_COLUMN_CASE_SENSITIVE = 12;
   SQL_COLUMN_SEARCHABLE     = 13;
   SQL_COLUMN_TYPE_NAME      = 14;

(* SQLColAttributes subdefines for SQL_COLUMN_UPDATABLE *)
   SQL_ATTR_READONLY          = 0;
   SQL_ATTR_WRITE             = 1;
   SQL_ATTR_READWRITE_UNKNOWN = 2;

(*
   SQLColAttributes subdefines for SQL_COLUMN_SEARCHABLE, also used
   by SQLGetInfo
*)
   SQL_UNSEARCHABLE    = 0;
   SQL_LIKE_ONLY       = 1;
   SQL_ALL_EXCEPT_LIKE = 2;
   SQL_SEARCHABLE      = 3;

(* SQLError defines *)
   SQL_NULL_HENV  = nil;
   SQL_NULL_HDBC  = nil;
   SQL_NULL_HSTMT = nil;

type
   dword = longint;
   retcode = integer;
   henv = pointer;
   hdbc = pointer;
   hstmt = pointer;
   plongint = ^longint;


function SQLAllocConnect (env : henv;
                          var dbc : hdbc) : retcode;
function SQLAllocEnv (var env : henv) : retcode;
function SQLAllocStmt (dbc : hdbc;
                       var stmt : hstmt) : retcode;
function SQLBindCol (stmt : hstmt;
                     icol : word;
                     fctype : integer;
                     rgbvalue : pointer;
                     cbvaluemax : longint;
                     pcbvalue : plongint) : retcode;
function SQLCancel (stmt : hstmt) : retcode;
function SQLColAttributes (stmt : hstmt;
                           icol : word;
                           fdesctype : word;
                           rgbdesc : pointer;
                           cbdescmax : integer;
                           var cbdesc : integer;
                           var fdesc : longint) : retcode;
function SQLConnect (dbc : hdbc;
                     szdsn : pchar;
                     cbdsn : integer;
                     szuid : pchar;
                     cbuid : integer;
                     szauthstr : pchar;
                     cbauthstr : integer) : retcode;
function SQLDescribeCol (stmt : hstmt;
                         icol : word;
                         szcolname : pchar;
                         cbcolnamemax : integer;
                         var cbcolname : integer;
                         var pfsqltype : integer;
                         var cbcoldef : dword;
                         var ibscale : integer;
                         var fnullable : integer) : retcode;
function SQLDisconnect (dbc : hdbc) : retcode;
function SQLError (env : henv;
                   dbc : hdbc;
                   stmt : hstmt;
                   szsqlstate : pchar;
                   var fnativeerror : longint;
                   szerrormsg : pchar;
                   cberrormsgmax : integer;
                   var cberrormsg : integer) : retcode;
function SQLExecDirect (stmt : hstmt;
                        szsqlstr : pchar;
                        cbsqlstr : longint) : retcode;
function SQLExecute (stmt : hstmt) : retcode;
function SQLFetch (stmt : hstmt) : retcode;
function SQLFreeConnect (dbc : hdbc) : retcode;
function SQLFreeEnv (env : henv) : retcode;
function SQLFreeStmt (stmt : hstmt;
                      foption : word) : retcode;
function SQLGetCursorName (stmt : hstmt;
                           szcursor : pchar;
                           cbcursormax : integer;
                           var cbcursor : integer) : retcode;
function SQLNumResultCols (stmt : hstmt;
                           var ccol : integer) : retcode;
function SQLPrepare (stmt : hstmt;
                     szsqlstr : pchar;
                     cbsqlstr : longint) : retcode;
function SQLRowCount (stmt : hstmt;
                      var crow : longint) : retcode;
function SQLSetCursorName (stmt : hstmt;
                           szcursor : pchar;
                           cbcursor : integer) : retcode;
function SQLSetParam (stmt : hstmt;
                      ipar : word;
                      fctype : integer;
                      fsqltype : integer;
                      cbcoldef : dword;
                      ibscale : integer;
                      rgbvalue : pointer;
                      pcbValue : plongint) : retcode;
function SQLTransact (env : henv;
                      dbc : hdbc;
                      ftype : word) : retcode;

implementation


function SQLEXECUTE;               external 'ODBC' index 12;
function SQLROWCOUNT;              external 'ODBC' index 20;
function SQLALLOCENV;              external 'ODBC' index 2;
function SQLERROR;                 external 'ODBC' index 10;
function SQLDESCRIBECOL;           external 'ODBC' index 8;
function SQLBINDCOL;               external 'ODBC' index 4;
function SQLFREEENV;               external 'ODBC' index 15;
function SQLALLOCCONNECT;          external 'ODBC' index 1;
function SQLCOLATTRIBUTES;         external 'ODBC' index 6;
function SQLCANCEL;                external 'ODBC' index 5;
function SQLPREPARE;               external 'ODBC' index 19;
function SQLALLOCSTMT;             external 'ODBC' index 3;
function SQLGETCURSORNAME;         external 'ODBC' index 17;
function SQLCONNECT;               external 'ODBC' index 7;
function SQLSETCURSORNAME;         external 'ODBC' index 21;
function SQLFREECONNECT;           external 'ODBC' index 14;
function SQLEXECDIRECT;            external 'ODBC' index 11;
function SQLFETCH;                 external 'ODBC' index 13;
function SQLDISCONNECT;            external 'ODBC' index 9;
function SQLTRANSACT;              external 'ODBC' index 23;
function SQLFREESTMT;              external 'ODBC' index 16;
function SQLSETPARAM;              external 'ODBC' index 22;
function SQLNUMRESULTCOLS;         external 'ODBC' index 18;


end.
