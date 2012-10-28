module sworks.compo.win32.rc;
import std.conv;
import sworks.compo.win32.util;
import sworks.compo.util.readz;

/******************************************************************************\
|* StringResource - 文字列リソースを扱う class を自動生成                     *|
|*   メンバは全て sworks.compo.win32.util.Readz                               *|
|*                                                                            *|
|* Params:                                                                    *|
|*   MEMBER - "TEXT_1", 1000, "TEXT_2", 1, "TEXT_2", 2, ...  みたいなの       *|
\******************************************************************************/
class StringTable( MEMBER ... )
{
	static private string MixStr()
	{
		string result;
		result ~= "static const Readz ";
		foreach( one  ; MEMBER ) static if( is(typeof(one) : string) ) result ~= one ~ ",";

		if( result[$-1] == ',' )
		{
			result = result[ 0 .. $-1 ] ~ ';';
			return result;
		}
		else return "";
	}
	mixin( MixStr );

	static this()
	{
		wchar[256] buf;
		uint red;
		foreach_reverse( i, one ; MEMBER )
		{
			static if( is( typeof( one ) : uint ) )
			{
				red = LoadString( GetModuleHandle(null), one, buf.ptr, buf.length );
			}
			else static if( is( typeof( one ) : string ) )
			{
				red = min( red, buf.length-1 );
				buf[red] = '\0';
				__traits( getMember, typeof(this), one ) = Readz( buf[ 0 .. red ].idup.ptr, red );
			}
			else throw new Exception( "Resource \"" ~ MEMBER[i-1] ~ " = "
				~ to!string(one) ~"\" is not detected." );
		}
	}
}

debug( rc )
{
	import std.stdio;
	alias StringTable!( "HELLO", 0x0002, "GOODBYE", 0x0003 ) SR;

	void main()
	{
		okbox( SR.HELLO.ptrz );
//		writeln( SR.HELLO[] );
//		writeln( SR.GOODBYE[] );
	}
}