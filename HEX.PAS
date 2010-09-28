unit Hex;
(*====================================================================*\
|| MODULE NAME:  Hex                                                  ||
|| DEPENDENCIES: System                                               ||
|| LAST MOD ON:  9004.10                                              ||
|| PROGRAMMER:   Naoto Kimura                                         ||
||                                                                    ||
||     This unit is used for printing hex values of numbers.          ||
||                                                                    ||
|| MODIFICATION HISTORY:                                              ||
|| 8901.07       Naoto Kimura                                         ||
||               Original release                                     ||
|| 9004.10       Naoto Kimura                                         ||
||               Rewrote same parts as inline statements to try to    ||
||               reduce size of the unit and to speed up routines.    ||
\*====================================================================*)

{$R-}	{Range checking off}
{$S+}	{Stack checking on}
{$D-}	{Debug info off}
{$I-}	{I/O checking off}
{$N-}	{No numeric coprocessor}

interface

const
    HEXCHARS	: packed array [0..15] of char = '0123456789ABCDEF';

(*--------------------------------------------------------------------*\
| NAME: HexByte                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of an    |
| integer value.                                                       |
\*--------------------------------------------------------------------*)
function HexByte( b : byte ) : string;

(*--------------------------------------------------------------------*\
| NAME: HexShort                                                       |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| short integer value.                                                 |
\*--------------------------------------------------------------------*)
function HexShort( s : ShortInt ) : string;

(*--------------------------------------------------------------------*\
| NAME: HexWord                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| word value.                                                          |
\*--------------------------------------------------------------------*)
function HexWord( w : word ) : string;

(*--------------------------------------------------------------------*\
| NAME: HexInt                                                         |
|                                                                      |
|     This function is returns the hexadecimal representation of an    |
| integer value.                                                       |
\*--------------------------------------------------------------------*)
function HexInt( i : integer ) : string;

(*--------------------------------------------------------------------*\
| NAME: HexLong                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| long value.                                                          |
\*--------------------------------------------------------------------*)
function HexLong( l : longint ) : string;

(*--------------------------------------------------------------------*\
| NAME: HexPtr                                                         |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| pointer.                                                             |
\*--------------------------------------------------------------------*)
function HexPtr( l : pointer ) : string;

implementation

(*--------------------------------------------------------------------*\
| NAME: HexByte                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of an    |
| integer value.                                                       |
\*--------------------------------------------------------------------*)
function HexByte( b : byte ) : string;
    begin
	inline(	$C4/$7E/$08/		{ les   di,[Result]	}
		$FC/			{ cld			}
		$B8/$02/$00/		{ mov   ax,2		}
		$AA/			{ stosb			}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$5E/<B/		{ mov   bl,[B]		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$5E/<B/		{ mov   bl,[B]		}
		$83/$E3/$0F/		{ and   bx,0fh		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB)			{ stosw			}
    end;    (* HexByte *)

(*--------------------------------------------------------------------*\
| NAME: HexShort                                                       |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| short integer value.                                                 |
\*--------------------------------------------------------------------*)
function HexShort( s : ShortInt ) : string;
    begin
	inline(	$C4/$7E/$08/		{ les   di,[Result]	}
		$FC/			{ cld			}
		$B8/$02/$00/		{ mov   ax,2		}
		$AA/			{ stosb			}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$5E/<S/		{ mov   bl,[B]		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$D0/$EB/		{ shr   bl,1		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$5E/<S/		{ mov   bl,[B]		}
		$83/$E3/$0F/		{ and   bx,0fh		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB)			{ stosw			}
    end;    (* HexShort *)

(*--------------------------------------------------------------------*\
| NAME: hexword                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| word value.                                                          |
\*--------------------------------------------------------------------*)
function HexWord( w : word ) : string;
    begin				{; get return string location}
	inline(	$C4/$7E/$08/		{ les   di,[Result]	}
					{; forward string op	}
		$FC/			{ cld			}
		$B8/$04/$00/		{ mov   ax,4		}
					{; set result string length}
		$AA/			{ stosb			}
		$8B/$56/<W/		{ mov   dx,[W]		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB);			{ stosw			}
    end;    (* HexWord *)

(*--------------------------------------------------------------------*\
| NAME: HexInt                                                         |
|                                                                      |
|     This function is returns the hexadecimal representation of an    |
| integer value.                                                       |
\*--------------------------------------------------------------------*)
function HexInt( i : integer ) : string;
    begin
	inline(	$C4/$7E/$08/		{ les   di,[Result]	}
					{; forward string op	}
		$FC/			{ cld			}
		$B8/$04/$00/		{ mov   ax,4		}
					{; set result string length}
		$AA/			{ stosb			}
		$8B/$56/<I/		{ mov   dx,[W]		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB);			{ stosw			}
    end;    (* HexInt *)

(*--------------------------------------------------------------------*\
| NAME: HexLong                                                        |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| long value.                                                          |
\*--------------------------------------------------------------------*)
function HexLong( l : longint ) : string;
    begin
	inline(	$1E/			{ push  ds		}
					{; fwd string op	}
		$FC/			{ cld			}
		$C5/$76/<L/		{ lds   si,[L]		}
					{; es:di <- &(result)	}
		$C4/$7E/$0A/		{ les   di,[Result]	}
		$B8/$08/$00/		{ mov   ax,8		}
		$AA/			{ stosb			}
				{;-------------------------------------}
				{; Hi word			       }
				{;-------------------------------------}
		$8C/$D8/		{ mov   ax,ds		}
					{; restore data seg reg	}
		$1F/			{ pop   ds		}
		$92/			{ xchg  dx,ax		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
				{;-------------------------------------}
				{; Lo word			       }
				{;-------------------------------------}
		$8B/$D6/		{ mov   dx,si		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB)			{ stosw			}
    end;    (* HexLong *)

(*--------------------------------------------------------------------*\
| NAME: HexPtr                                                         |
|                                                                      |
|     This function is returns the hexadecimal representation of a     |
| pointer.                                                             |
\*--------------------------------------------------------------------*)
function HexPtr( l : pointer ) : string;
    begin
	inline(	$1E/			{ push  ds		}
					{; fwd string op	}
		$FC/			{ cld			}
		$C5/$76/<L/		{ lds   si,[L]		}
					{; es:di <- &(result)	}
		$C4/$7E/$0A/		{ les   di,[Result]	}
		$B8/$09/$00/		{ mov   ax,8		}
		$AA/			{ stosb			}
				{;-------------------------------------}
				{; Hi word			       }
				{;-------------------------------------}
		$8C/$D8/		{ mov   ax,ds		}
					{; restore data seg reg	}
		$1F/			{ pop   ds		}
		$92/			{ xchg  dx,ax		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
				{;-------------------------------------}
				{; colon separator		       }
				{;-------------------------------------}
		$B0/$3A/		{ mov   al,':'		}
		$AA/			{ stosb			}
				{;-------------------------------------}
				{; Lo word			       }
				{;-------------------------------------}
		$8B/$D6/		{ mov   dx,si		}
		$8B/$CA/		{ mov   cx,dx		}
					{; cx <-- low nibbles	}
					{; dx <-- low nibbles	}
		$81/$E1/$0F0F/		{ and   cx,0f0fh	}
		$81/$E2/$F0F0/		{ and   dx,0f0f0h	}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$D1/$EA/		{ shr   dx,1		}
		$33/$DB/		{ xor   bx,bx		}
		$8A/$DE/		{ mov   bl,dh		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$DD/		{ mov   bl,ch		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB/			{ stosw			}
		$8A/$DA/		{ mov   bl,dl		}
		$8A/$87/HexChars/	{ mov   al,[HexChars+bx]}
		$8A/$D9/		{ mov   bl,cl		}
		$8A/$A7/HexChars/	{ mov   ah,[HexChars+bx]}
		$AB)			{ stosw			}
    end;    (* HexPtr *)

end.
