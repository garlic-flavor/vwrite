/** \file readz.d for mulexp.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.util.readz;

import std.conv, std.traits, std.exception;

/** 読み取り専用の Null終端文字列を扱う.
 * C言語へのアクセス用。
 */
struct TReadz(TCHAR)
{

private:
	immutable(TCHAR)[] value = "\0";

public:

     //==================================================================\\
     // ctor
	this(T)(T v)
	{
		static if     ( isPointer!T )
		{
			if( v is null ) value = "\0";
			else
			{
				size_t i;
				for( i = 0 ; v[i] != '\0' ; ++i ){}
				static if( is( T : TCHAR* ) ) value = assumeUnique( v[0 .. i+1] );
				else value = to!(immutable(TCHAR)[])(v[ 0 .. i+1 ]);
			}
		}
		else static if( is( T : TReadz ) )
		{
			value = v.value;
		}
		else static if( isSomeString!T )
		{
			auto str = to!(const(TCHAR)[])( v );
			TCHAR[] v2 = new TCHAR[ str.length + 1 ];
			v2[ 0 .. $-1 ] = str;
			v2[ $-1 ] = '\0';
			value = assumeUnique(v2);
		}
		else static assert(0);
	}

	this( T : immutable(TCHAR)* )( T ptr, size_t l )
	{
		value = ptr[ 0 .. l + 1 ];
	}

     //==================================================================\\
     // property
	immutable(TCHAR)* ptr() const nothrow @property { return value.ptr; }
	immutable(TCHAR)* ptrz() const nothrow @property { return value.ptr; }
	size_t length() const nothrow @property { return value.length - 1; }
	immutable(TCHAR)[] bare_value() const nothrow @property { return value; }

	TReadz dup() const { return TReadz( this ); } // no copy

     //==================================================================\\
     // operator overloads
	//
	TCHAR opIndex( size_t i ) const { return value[ i ]; }
	immutable(TCHAR)[] opSlice() const{ return value[ 0 .. $-1 ]; }
	immutable(TCHAR)[] opSlice( size_t i, size_t j ) const { return value[ i .. j ]; }

     //
	const(TReadz) getReader() const { return this; }

	string toString() const{ return to!string(value[ 0 .. $-1 ]); }
	wstring toStringW() const { return to!wstring( value[ 0 .. $-1 ] ); }
	dstring toStringD() const { return to!dstring( value[ 0 .. $-1 ] ); }
}
alias TReadz!wchar ReadzW;
alias TReadz!char ReadzA;

version( Unicode ) alias ReadzW Readz;
else alias ReadzA Readz;


     //==================================================================\\
     // suger
template t_ptrz(TCHAR)
{
	const(TCHAR)* t_ptrz(T)( T value ) { return tReadz!TCHAR(value).ptr; }
}

alias t_ptrz!wchar ptrzW;
alias t_ptrz!char ptrzA;

version( Unicode ) alias ptrzW ptrz;
else alias ptrzA ptrz;