/**
 * Version:      0.26(dmd2.060)
 * Date:         2012-Oct-27 00:09:35
 * Authors:      KUMA
 * License:      CC0
 **/
module sworks.vwrite.main;
import std.file, std.datetime, std.getopt, std.process, std.conv, std.exception, std.string, std.path;
import sworks.compo.util.search;
import sworks.compo.util.output;
import sworks.compo.stylexml.macros;
import sworks.compo.stylexml.parser;

string help= q"HELP
Version Writer v0.26(dmd2.060). written by KUMA.

** syntax
$>vwrite -version=x.x [v-style.xml] [source.d ...]
HELP";

/// 一行切り出し。
string chomp_line( ref string cont )
{
	size_t i;
	enum FLAG : uint
	{
		NONE = 0,
		RETURN = 1,
		NEWLINE = 2,
	}
	FLAG flag = FLAG.NONE;
	for( i = 0 ; i < cont.length ; ++i )
	{
		if( '\r' == cont[i] )
		{
			if( flag & FLAG.RETURN ) { i++; break; }
			else flag |= FLAG.RETURN;
		}
		else if( '\n' == cont[i] )
		{
			if( flag & FLAG.NEWLINE ) { i++; break; }
			else flag |= FLAG.NEWLINE;
		}
		else if( FLAG.NONE != flag ) break;
	}
	
	string result = cont[ 0 .. i ];
	cont = cont[ i .. $ ];
	return result;
}

//
void main(string[] args)
{
	Output output = new Output;
	try
	{
		// ヘルプが必要かどうか。
		if( args.length <= 1 ) return output.ln( help );
		bool needs_help = false;
		optionChar = '/';
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "help|h|?", &needs_help );
		if( needs_help ) return output.ln( help );

		optionChar = '-';
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "help|h|?", &needs_help );
		if( needs_help ) return output.ln( help );

		// 冗長性の決定
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "verbose|v", (){ output.mode = Output.MODE.VERBOSE; } );

		// マクロの準備
		auto data = new Macros;

		version( Windows ) data["bracket"] = new BracketItem("rn");
		version( linux ) data["bracket"] = new BracketItem( "n" );

		
		data["date"] = new MacroItem( (cast(DateTime)Clock.currTime).toSimpleString );

		data["v_style_file"] = new MacroItem("v-style.xml");
		data["source_files"] = new MacroItem;
		data["v_style"] = new MacroItem;
		data["version"] = new MacroItem;
		data["project"] = new MacroItem;
		data["starts_with"] = new MacroItem("/**");
		data["ends_with"] = new MacroItem("*/");
		data["max_version_lines"] = new MacroItem("20");
		data["filename"] = new MacroItem;
		data["basename"] = new MacroItem;

		// コマンドライン引数からのマクロの設定
		getopt( args
		      , config.caseInsensitive
		      , "ver|version", ( string k, string ver ){ data.fixAssign( "version", ver ); }
		      , "prj|project", ( string k, string prj ){ data.fixAssign( "project", prj ); } );

		// v-style.xml ファイルの探索
		Search search = new Search;
		search.entry(".");
		search.entry( getenv("HOME") );
		search.entry( std.path.dirName(args[0]) );

		foreach(one ; args[1..$])
		{
			if( one.endsWith( ".xml" ) ) data["v_style_file"] = one;
			else data["source_files"] ~= one;
		}
		data.fixAssign( "v_style_file", enforce( search.abs(data["v_style_file"])
		                                       , data["v_style_file"] ~ " is not found." ) );

		enforce( data.have("source_files"), "there are no target files in the argument." );

		// v-style.xml のヘッダを先にパース。
		auto parser = new StyleParser( to!string( read( data["v_style_file"] ) ), data );
		parser.parseHead();

		int max_version_lines = to!int( data["max_version_lines"] );
		string starts_with = data["starts_with"];
		string ends_with = data["ends_with"];
		string bracket = data["bracket"];

		/** それぞれのファイルに対して置換を実行する.
		 * \param filename 対象のファイル。
		 */
		void vwrite(string filename)
		{
			try
			{
				enforce(exists(filename), filename ~ " is not found.");

				string file_cont = stripLeft(cast(string)read(filename));
				string save_cont = file_cont;
				string header, footer;
				if( 0 < file_cont.startsWith( starts_with ) )
				{
					header = file_cont.chomp_line;

					size_t counter = 0;
					if( 0 <= header.indexOf( ends_with ) ) counter = max_version_lines;

					for( ; counter < max_version_lines ; ++counter)
					{
						footer = file_cont.chomp_line;
						if( 0 <= footer.indexOf( ends_with ) ) break;
						else footer.length = 0;
					}
					if( max_version_lines <= counter )
					{
						file_cont = save_cont;
						header.length = 0;
						footer.length = 0;
					}
				}

				if( 0 == header.length ) header = starts_with ~ bracket;
				if( 0 == footer.length ) footer = ends_with ~ bracket;

				data["filename"] = filename;
				data["basename"] = std.path.baseName(filename);

				std.file.write(filename, header ~ parser.parseBody() ~ footer ~ file_cont);
			}
			catch( Throwable t )
			{
				string str = t.toString; // <------------------------------------------ BUG
				output.errorln( str );
			}
		}

		// 入力された全てのファイルに対して vwrite を実行。
		foreach( one ; data.get("source_files").toArray ) { vwrite( one ); }
	}
	catch( Throwable t )
	{
		string str = t.toString; // <---------------------------------------------- BUG
		output.error( str );
	}
}
