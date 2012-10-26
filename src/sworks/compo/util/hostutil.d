module sworks.compo.util.hostutil;

import std.stdio, std.conv, std.exception;
import std.windows.charset;

string toMBStr( T )( in const(T)[] str16 )
{
	auto str8 = to!string( str16 );
	auto strz = toMBSz( str8, 1 );
	uint i;
	for( i = 0 ; strz[i] != '\0' ; i++ ){}
	return assumeUnique(strz[ 0 .. i ]);
}

debug(hostutil)
{
	void main()
	{
		writeln( "日本語".toMBStr );
	}
}
