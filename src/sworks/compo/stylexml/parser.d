/** -style.xml ファイルのパース
 * Version:      0.27(dmd2.060)
 * Date:         2012-Oct-29 01:24:08
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.stylexml.parser;
import std.xml, std.array, std.string, std.conv, std.exception;
import sworks.compo.util.strutil;
import sworks.compo.stylexml.macros;
import sworks.compo.stylexml.writer;

/*############################################################################*\
|*#                                Constants                                 #*|
\*############################################################################*/
alias void delegate(string) TextHandler;
alias void delegate(in Element) TagHandler;
alias void delegate(ElementParser) ParserHandler;

/*############################################################################*\
|*#                                Functions                                 #*|
\*############################################################################*/
//------------------------------------------------------------------------------
TextHandler text_tag( Writer writer ) { return (w => (string text) { w.put( text ); } )(writer); }

//
TagHandler br_tag( Writer writer ) { return ( w => ( in Element e ){ writer.putln();} )( writer ); }
//
TagHandler tab_tag( Writer writer ) { return ( w => ( in Element e ){ writer.putall('\t'); } )(writer); }
//
TagHandler ws_tag( Writer writer )
{
	return ( w => ( in Element e )
		{
			int l;
			enforce( null is collectException( l = to!int( e.tag.attr.get( "length", "1" ) ) )
			       , "the value of 'length' attribute of <ws> tag can't be parset to int by std.conv." );
			char[] cstr = new char[l];
			cstr[] = ' ';
			writer.putall( cstr );
		} )( writer );
}

//------------------------------------------------------------------------------
TagHandler get_tag( Writer writer, Macros macros )
{
	return (( w, m ) => ( in Element e )
		{
			auto e_id = enstring( e.tag.attr.get( "id", "" ), "the <get> tag has no 'id' attribute." );
			string value = m[ e_id ];
			if( 0 == value.length ) return;

			auto f = e.tag.attr.get( "from", "" );
			auto t = e.tag.attr.get( "to", "" );
			if( 0 < f.length && 0 < t.length ) value = value.replace( f, t );

			with( new DocumentParser( "<set>" ~ value ~ "</set>" ) )
			{
				onText = text_tag( w );
				onEndTag["br"] = br_tag( w );
				onEndTag["tab"] = tab_tag( w );
				onEndTag["ws"] = ws_tag( w );
				onEndTag["get"] = get_tag( w, m );
				parse();
			}
		} )( writer, macros );
}

//------------------------------------------------------------------------------
ParserHandler set_tag( Macros macros )
{
	return ( m => ( ElementParser ep )
		{
			auto ep_id = enstring( ep.tag.attr.get( "id", "" ), "the <set> tag has no 'id' attribute." );
			ep.parse();
			auto cont = ep.toString();
			int i; if( 0 <= ( i = cont.lastIndexOf("</") ) ) cont = cont[ 0 .. i ]; //< これなんとかならんのか
			m[ep_id] = cont.strip;
		} )( macros );
}

ParserHandler add_tag( Macros macros )
{
	return ( m => ( ElementParser ep )
		{
			auto ep_id = enstring( ep.tag.attr.get( "id", "" ), "the <add> tag has no 'id' attribute." );
			ep.parse;
			auto cont = ep.toString();
			int i; if( 0 <= ( i = cont.lastIndexOf("</") ) ) cont = cont[ 0 .. i ]; //< ここも
			m[ep_id] ~= cont;
		} )( macros );
}

//------------------------------------------------------------------------------
ParserHandler ifdef_tag( Macros macros )
{
	return ( m => ( ElementParser ep )
		{
			auto ep_id = enstring( ep.tag.attr.get( "id", "" ), "the <ifdef> tag has no 'id' attribute." );
			if( m.have( ep_id ) ) return; // return and parse correctly
			ep.parse(); // ignore its inner.
		} )( macros );
}

ParserHandler ifndef_tag( Macros macros )
{
	return ( m => ( ElementParser ep )
		{
			auto ep_id = enstring( ep.tag.attr.get( "id", "" ), "the <ifndef> tag has no 'id' attribute. " );
			if( !m.have( ep_id ) ) return; // return and parse correctly.
			ep.parse(); // ignore its inner.
		} )( macros );
}

//------------------------------------------------------------------------------
void headParser( Macros macros, ElementParser ep )
{
	with( ep )
	{
		onStartTag["ifdef"] = ifdef_tag( macros );
		onStartTag["ifndef"] = ifndef_tag( macros );
		onStartTag["set"] = set_tag( macros );
		onStartTag["add"] = add_tag( macros );
		parse;
	}
}

/*############################################################################*\
|*#                                 Classes                                  #*|
\*############################################################################*/

//------------------------------------------------------------------------------
class EnvironmentTag
{
private:
	string _head;
	string _body;

public:

	this( ElementParser ep )
	{
		ep.onEndTag["head"] = ( e ){ _head = "<head>" ~ e.text() ~ "</head>"; };
		ep.onEndTag["body"] = ( e ){ _body = "<body>" ~ e.text() ~ "</body>"; };
		ep.parse();
	}

	void parseHead( Macros macros )
	{
		if( 0 < _head.length ) headParser( macros, new DocumentParser( _head ) );
	}

	void parseBody( Writer writer, Macros macros )
	{
		with( new DocumentParser( enstring( _body, "body is empty" ) ) )
		{
			onStartTag[ "ifdef" ] = ifdef_tag( macros );
			onStartTag[ "ifndef" ] = ifndef_tag( macros );
			onEndTag[ "br" ] = br_tag( writer );
			onEndTag[ "ws" ] = ws_tag( writer );
			onEndTag[ "tab" ] = tab_tag( writer );
			onEndTag[ "get" ] = get_tag( writer, macros );
			onText = text_tag( writer );
			parse();
		}
	}
}

/**
 * \bug ルートタグになにが来てもok
 */
class StyleParser
{
	alias void delegate(Macros) Callback;

	protected Macros macros;

	protected EnvironmentTag[ string ] environments;
	protected EnvironmentTag active;

	/**
	 * \param macros マクロの中身を保持
	 * \param log stderr. see also sworks/util/output.d.
	 */
	this( string xml_cont, Macros macros )
	{
		this.macros = macros;
		check( xml_cont );
		auto xml = new DocumentParser( xml_cont );
		xml.onStartTag[ "head" ] = ep => headParser( macros, ep );
		xml.onStartTag[ "environment" ] = ( ep )
		{
			auto id = enstring( ep.tag.attr.get( "id", "" ), "the <emvironment> tag has no 'id' attribute." );
			if( !macros.have( "env" ) ) macros["env"] = id;
			environments[ id ] = new EnvironmentTag( ep );
		};
		xml.parse;
		active = enforce( environments.get( enstring( macros["env"]
		                                            , "macros has no 'env' value" ), null )
		                , "environments has no instance of " ~ macros["env"] ~ "." );
	}

	void parseHead() { active.parseHead(macros); }

	/// パースを実行し、その結果を返す。
	string parseBody()
	{
		auto writer = new Writer( enstring( macros[ "bracket" ], "macros has no 'bracket' value" ) );

		active.parseBody( writer, macros );
		return assumeUnique(writer[][]);
	}
}

debug(style_parser)
{
	import std.stdio;
	import std.file;
	import std.conv;
	void main(string[] args)
	{
		auto m = new Macros;
		m["bracket"] = new BracketItem();
		m["to_compile"] ~= "parser.d";
		auto parser = new StyleParser( to!string(std.file.read(args[$-1])), m );
		parser.parseHead();
//parser.parseBody();
		writeln( parser.parseBody() );
	}
}