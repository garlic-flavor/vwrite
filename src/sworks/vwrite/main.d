/**
 * Version:      0.28(dmd2.062)
 * Date:         2013-Mar-02 20:15:11
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
Version Writer v0.27(dmd2.060). written by KUMA.

** syntax
$>vwrite -version=x.x -target=foo.exe [v-style.xml] [source.d ...]

foo.exe よりも新しいファイルのみ書き替えられます。
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
	try
	{
		// ヘルプが必要かどうか。
		if( args.length <= 1 ) return Output.ln( help );
		bool needs_help = false;
		optionChar = '/';
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "help|h|?", &needs_help );
		if( needs_help ) return Output.ln( help );

		optionChar = '-';
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "help|h|?", &needs_help );
		if( needs_help ) return Output.ln( help );

		// 冗長性の決定
		bool is_verbose = false;
		getopt( args
		      , config.caseInsensitive
		      , config.passThrough
		      , "verbose|v", &is_verbose );
		if( is_verbose ) Output.mode = Output.MODE.VERBOSE;

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
		data["target"] = new MacroItem;
		data["starts_with"] = new MacroItem("/**");
		data["ends_with"] = new MacroItem("*/");
		data["max_version_lines"] = new MacroItem("20");
		data["filename"] = new MacroItem;
		data["basename"] = new MacroItem;

		// コマンドライン引数からのマクロの設定
		getopt( args
		      , config.caseInsensitive
		      , "ver|version", ( string k, string ver ){ data.fixAssign( "version", ver ); }
		      , "prj|project", ( string k, string prj ){ data.fixAssign( "project", prj ); }
		      , "target", ( string k, string tgt ){ data.fixAssign( "target", tgt ); } );

		// v-style.xml ファイルの探索
		Search search = new Search;
		search.entry(".");
		search.entry( getenv("HOME") );
		version(Windows) search.entry( std.path.dirName(args[0]) );
		version(linux) search.entry( std.path.dirName( shell("which vwrite") ) );

		auto targetLastModified = timeLastModified( data["target"], SysTime.min );
		foreach(one ; args[1..$])
		{
			if( one.endsWith( ".xml" ) ) data["v_style_file"] = one;
			else if( one.exists )
			{
				if( targetLastModified <= one.timeLastModified )
				{
					Output.logln( one, " が更新されました。" );
					data["source_files"] ~= one;
				}
			}
		}
		data.fixAssign( "v_style_file", enforce( search.abs(data["v_style_file"])
		                                       , data["v_style_file"] ~ " は見つかりませんでした。" ) );

		if( !data.have("source_files" ) )
		{
			Output.ln( "更新されたファイルはありません。" );
			return;
		}

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
				enforce(exists(filename), filename ~ " が見つかりませんでした。");

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
				Output.errorln( str );
			}
		}

		// 入力された全てのファイルに対して vwrite を実行。
		foreach( one ; data.get("source_files").toArray ) { vwrite( one ); }
	}
	catch( Throwable t )
	{
		string str = t.toString; // <---------------------------------------------- BUG
		Output.error( str );
	}
}
