/**
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
*/
module sworks.compo.util.strz;

import std.conv, std.traits;
private import sworks.compo.util.array;
public import sworks.compo.util.readz;

/// 書き替え可能な Null 終端文字列
class TStrz(TCHAR)
{
private:
	Array!(TCHAR) value;
	alias TReadz!(TCHAR) Readz;

public:

     //----------------------------------------------------------------------
	this( T )( T v ) { opAssign( v ); }

    //----------------------------------------------------------------------
	const(TCHAR)* ptr() @property { return value.ptr; }
	const(TCHAR)* ptrz() @property { return value.ptr; }
	const(TCHAR)[] bare_value() @property { return value[]; }

	size_t length() @property { return value.length - 1; }

	TStrz dup() { return new TStrz( value[] ); } // copy occor;

    //----------------------------------------------------------------------
	TStrz opAssign(T)( T str )
	{
		const(TCHAR)[] temp;
		static if( isPointer!(T) )
		{
			size_t i;
			for( i = 0 ; str[i] != '\0' ; ++i ){}
			temp = to!( const(TCHAR)[] )( str[ 0 .. i ] );
		}
		else static if( is( T : const(TStrz) ) || is( T : const(Readz) ) )
			temp = to!(const(TCHAR)[])( str[] );
		else temp = to!( const(TCHAR)[] )( str );

		value.clear();
		value.put( temp );
		value.put( '\0' );
		return this;
	}

    //----------------------------------------------------------------------
	TStrz opOpAssign( string OP : "~", T )( T str )
	{
		const(TCHAR)[] temp;
		static if( isPointer!(T) )
		{
			size_t i;
			for( i = 0 ; str[i] != '\0' ; ++i ){}
			temp = to!(const(TCHAR)[])( str[ 0 .. i+1 ] );
		}
		else static if( is( T : const(Readz) ) || is( T : const(TStrz) ) )
			temp = to!(const(TCHAR)[])( str[] );
		else temp = to!( const(TCHAR)[] )( str );

		value.shrinkTo( value.length - 1 );
		value.put( temp );
		value.put( '\0' );
		return this;
	}

    //----------------------------------------------------------------------
	tStrz opBinary( string OP : "~", T )( T str ) const
	{
		auto ret = this.dup;
		ret ~= str;
		return ret;
	}

	tStrz opBinaryRight(string OP : "~", T )( T str ) const
	{
		auto ret = new Strz( str );
		ret ~= this;
		return ret;
	}

    //----------------------------------------------------------------------
	TCHAR opIndex( size_t i ) { return value[ i ]; }
	TCHAR opIndexAssign( TCHAR v, size_t i )
	{
		value[ i ] = v;
		value[ value.length - 1 ] = '\0';
		return v;
 	}

    //----------------------------------------------------------------------
	const(TCHAR)[] opSlice() { return value[ 0 .. value.length-1 ]; }
	const(TCHAR)[] opSlice(size_t i, size_t j ) { return value[ i .. j ]; }
	const(TCHAR)[] opSliceAssign( TCHAR v )
	{
		value[ 0 .. value.length - 1 ] = v;
		return value[ 0 .. value.length - 1 ];
	}
	const(TCHAR)[] opSliceAssign( const(TCHAR)[] v )
	{
		value[ 0 .. value.length - 1 ] = v;
		return value[ 0 .. value.length - 1 ];
	}
	const(TCHAR)[] opSliceAssign( const(TCHAR)[] v, size_t i, size_t j )
	{
		value[ i .. j ] = v;
		value[ value.length - 1 ] = '\0';
		return value[ i .. j ];
	}


    //----------------------------------------------------------------------
	Readz getReader() { return Readz( value[ 0 .. value.length ].idup ); }
	string toString() { return to!string(value[ 0 .. value.length-1 ]); }
	wstring toStringW() { return to!wstring( value[ 0 .. value.length-1 ] ); }
	dstring toStringD() { return to!dstring( value[ 0 .. value.length-1 ] ); }
}

alias TStrz!wchar StrzW;
alias TStrz!char StrzA;

version(Unicode) alias StrzW Strz;
else alias StrzA Strz;