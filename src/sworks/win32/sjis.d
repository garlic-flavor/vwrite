/** SHIFT-JIS の扱いに。
 * Version:      0.27(dmd2.060)
 * Date:         2012-Oct-29 01:24:08
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.win32.sjis;

import std.ascii, std.exception, std.conv, std.utf;
private import std.c.windows.windows;
public import sworks.compo.util.strutil;

// 文字列を SHIFT-JIS文字列に.
jstring toMBS( T )( const(T)[] msg, int codePage = 0 )
	if( is( T == char ) || is( T == wchar ) || is( T == dchar ) || is( T == jchar ) )
{
	static if( is( T == jchar ) ) return msg.j;

	bool ASCIIOnly = true;
	for( size_t i = 0 ; i < msg.length && ASCIIOnly ; i++ ) ASCIIOnly = msg[i].isASCII;
	if( ASCIIOnly ) return msg.to!string.j;

	auto str16 = msg.to!wstring;
	auto result = new char[ WideCharToMultiByte( codePage, 0, str16.ptr, str16.length, null, 0
	                                           , null, null ) ];

	enforce( 0 < result.length && result.length == WideCharToMultiByte( codePage, 0, str16.ptr
	       , str16.length, result.ptr, result.length, null, null ) );
	return result.j;
}

// 文字列をSHIFT-JISのNull終端文字列に。
const(byte)* toMBSz(T)( const(T)[] msg, int codePage = 0 )
	if( is( T == char ) || is( T == wchar ) || is( T == dchar ) || is( T == jchar ) )
{
	static if( is( T == jchar ) ) return ( msg ~ [ 0 ] ).ptr.jz;

	bool ASCIIOnly = true;
	for( size_t i = 0 ; i < msg.length && ASCIIOnly ; i++ ) ASCIIOnly = msg[i].isASCII;
	if( ASCIIOnly ) return msg.toUTF8z.jz;

	auto str16 = msg.to!wstring;
	auto result = new char[ WideCharToMultiByte( codePage, 0, str16.ptr, str16.length, null, 0
	                                           , null, null ) + 1 ];

	enforce( 1 < result.length && result.length - 1 == WideCharToMultiByte( codePage, 0, str16.ptr
	       , str16.length, result.ptr, result.length - 1, null, null ) );
	return result.ptr.jz;
}

// SHIFT-JIS文字列をUTF文字列に
immutable(CHAR)[] fromMBS(CHAR)( const(jchar)[] msg, int codePage = 0 )
	if( is( T == char ) || is( T == wchar ) || is( T == dchar ) || is( T == jchar ) )
{
	static if( is( CHAR == jchar ) ) return msg;

	bool ASCIIOnly = true;
	for( size_t i = 0 ; i < msg.length && ASCIIOnly ; i++ ) ASCIIOnly = msg[i].isASCII;
	if( ASCIIOnly ) return msg.c.to!(immutable(CHAR)[]);

	auto result = new wchar[ MultiByteToWideChar( codePage, 0, msg.ptr, msg.length, null, 0 ) ];
	enforce( 0 < result.length && result.length == MultiByteToWideChar( codePage, 0, msg.ptr
	       , msg.length, result.ptr, result.length ) );
	return result.to!(immutable(CHAR)[]);
}

// Null終端SHIFT-JIS文字列をUTF文字列に。
immutable(CHAR)[] fromMBSz(CHAR)( const(jchar)* msg, int codePage = 0 )
	if( is( T == char ) || is( T == wchar ) || is( T == dchar ) || is( T == jchar ) )
{
	size_t i = 0;
	static if( is( CHAR == jchar ) )
	{
		for( ; msg[i] != 0 ; i++ ){}
		return msg[ 0 .. i ].j;
	}

	bool ASCIIOnly = true;
	for( ; msg[i] != 0 && ASCIIOnly ; i++ ) ASCIIOnly = msg[i].isASCII;
	if( ASCIIOnly ) return msg[ 0 .. i ].c.to!(immutable(CHAR)[]);

	auto result = new wchar[ MultiByteToWideChar( codePage, 0, msg, -1, null, 0 ) ];
	enforce( 0 < result.length && result.length == MultiByteToWideChar( codePage, 0, msg.ptr
	       , msg.length, result.ptr, result.length ) );
	return result.to!(immutable(CHAR)[]);
}


debug( sjis ):

import std.stdio;
void main()
{
	writeln( "日本語".toMBS.c );
}