module sworks.compo.util.dump_members;

import std.array, std.ascii, std.conv, std.range, std.traits;

/// Dのオブジェクト -> メンバ名とその内容を表す文字列 デバグ用
string dump_members( THIS )( THIS t, uint max_indent = 12, uint max_array = 64, uint indent = 0 )
{
	enum TAB_SIZE = 4;
	auto result = appender!string();

	static if     ( is( THIS == class ) )
	{
		if( null !is t )
		{
			result.put( newline );
			result.put( take( repeat(' '), indent * TAB_SIZE ) );
			result.put( THIS.stringof );
			result.put( newline );
			result.put( take( repeat(' '), indent * TAB_SIZE ) );
			result.put( "{" );
			indent++;
			result.put( newline );
			static if( __traits( hasMember, t, "dump" ) )
			{
				result.put( t.dump( max_indent, max_array, indent ) );
			}
			else
			{
				if( indent < max_indent )
				{
					foreach( one ; __traits( derivedMembers, THIS ) )
					{
						static if( __traits( compiles, __traits( getMember, t, one ).offsetof ) )
						{
							result.put( take( repeat(' '), indent * TAB_SIZE ) );
							result.put( one );
							result.put( " = " );
							result.put( dump_members( __traits( getMember, t, one ), max_indent, max_array, indent ) );
							result.put( newline );
						}
					}
				}
				else result.put( " ... " );
			}
			indent--;
			result.put( newline );
			result.put( take( repeat( ' '), indent * TAB_SIZE ) );
			result.put( "}" );
		}
		else result.put( "null" );
	}
	else static if( is( THIS == interface ) || isCallable!THIS )
	{
		static if( __traits( hasMember, t, "dump" ) )
		{
			indent++;
			result.put( t.dump( max_indent, max_array, indent ) );
			indent--;
		}
		else
		{
			if( null !is t ) result.put( THIS.stringof );
			else result.put( "null" );
		}
	}
	else static if( is( THIS == struct ) )
	{
		result.put( newline );
		result.put( take( repeat(' '), indent * TAB_SIZE ) );
		result.put( THIS.stringof );
		result.put( newline );
		result.put( take( repeat(' '), indent * TAB_SIZE ) );
		result.put( "{" );
		result.put( newline );
		indent++;
		static if( __traits( hasMember, t, "dump" ) )
		{
			result.put( t.dump( max_indent, max_array, indent ) );
		}
		else
		{
			if( indent < max_indent )
			{
				foreach( one ; __traits( derivedMembers, THIS ) )
				{
					static if( __traits( compiles, __traits( getMember, t, one ).offsetof ) )
					{
						result.put( take( repeat(' '), indent * TAB_SIZE ) );
						result.put( one );
						result.put( " = " );
						result.put( dump_members( __traits( getMember, t, one ), max_indent, max_array, indent ) );
						result.put( newline );
					}
				}
			}
			else result.put( " ... " );
			result.put( take( repeat(' '), indent * TAB_SIZE ) );
		}
		indent--;
		result.put( newline ); result.put( take( repeat(' '), indent * TAB_SIZE ) );
		result.put( "}" );
	}
	else static if( isSomeString!THIS )
	{
		result.put( t.to!string );
	}
	else static if( is( THIS T : T[] ) )
	{
		result.put( " [ " );
		indent++;
		if( indent < max_indent )
		{
			foreach( counter, one ; t )
			{
				if( max_array < counter ) { result.put( " ... " ); break; }
				result.put( one.dump_members( max_indent, max_array, indent ) );
				result.put( " " );
			}
		}
		else result.put( " ... " );
		indent--;
		result.put( "] " );
	}
	else static if( __traits( isAssociativeArray, THIS ) )
	{
		result.put( " [ " );
		indent++;
		if( indent < max_indent )
		{
			uint counter = 0;
			foreach( key, one ; t )
			{
				if( max_array < counter ) { result.put( " ... " ); break; }
				result.put( key.dump_members( max_indent, max_array, indent ) );
				result.put( " : " );
				result.put( one.dump_members( max_indent, max_array, indent ) );
				result.put( ", " );
				counter++;
			}
		}
		else result.put( " ... " );
		indent--;
		result.put( " ] " );
	}
	else static if( is( THIS T : T* ) )
	{
		if( null !is t ) return (*t).dump_members( max_indent, max_array, indent );
		else return "null";
	}
	else result.put( t.to!string );
	return result.data;
}

debug(dump_members):
import std.stdio;

class Test
{
	int x;
	double[] d;
	string msg;
	Test t;
	Test[string] at;

	string hoge( string t ) { return "hello world"; }
}

void main()
{
	auto t = new Test;
	t.at[ "hello" ] = new Test;
	t.at[ "world" ] = new Test;
	writeln( t.dump_members );
}