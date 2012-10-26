/** \file strutil.d for mulexp.exe
 * Version:      0.26(dmd2.060)
 * Date:         2012-Oct-27 00:09:35
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.util.strutil;

import std.conv;
import std.exception;
version( Windows ) import std.windows.charset;

/** 文字列を SHIFT-JISに.
 * \bug 戻り値を string 型にすべきではない。
 */
string toMBStr( T )( const(T) msg )
{
	version( Windows )
	{
		auto str8 = msg.to!string;
		auto strz = toMBSz( str8, 1 );
		uint i;
		for( i = 0 ; strz[i] != '\0' ; i++ ){}
		return assumeUnique(strz[ 0 .. i ]);
	}
	else return to!string( msg );
}

/// Null終端文字列から D の stringへ
wstring toUTF16( T )( T s )
{
	static if( is( T : const(char)* ) || is( T : const(wchar)* )  || is( T : const(dchar)* ) )
	{
		size_t i;
		for( i = 0 ; s[i]!='\0' ; i++ ){}
		return to!wstring( s[0..i] );
	}
	else return to!wstring(s);
}

/// ditto
string toUTF8( T )( T s )
{
	static if( is( T : const(char)* ) || is( T : const(wchar)* )  || is( T : const(dchar)* ) )
	{
		size_t i;
		for( i = 0 ; s[i]!='\0' ; i++ ){}
		return to!string( s[0..i] );
	}
	else return to!string(s);
}

T enstring( T )( T str, lazy string msg = "failure in enstring" )
{
	if( 0 < str.length ) return str;
	else throw new Exception( msg );
}


debug(strutil)
{
	import std.stdio;
	class Test{ string toString(){ return "Test class"; } }
	void main()
	{
		int i = 10;
		auto t = new Test;
		string hello = "hello world";
		wstring goodbye = "good-bye heaven";

		writeln( toUTF8( i ) );
		writeln( toUTF8( t ) );
		writeln( toUTF8( hello ) );
		writeln( toUTF8( goodbye ) );
		writeln( toUTF8( hello.ptr ) );
		writeln( toUTF8( goodbye.ptr ) );
		writeln( toUTF16( i ) );
		writeln( toUTF16( t ) );
		writeln( toUTF16( hello ) );
		writeln( toUTF16( goodbye ) );
		writeln( toUTF16( hello.ptr ) );
		writeln( toUTF16( goodbye.ptr ) );

	}
}
