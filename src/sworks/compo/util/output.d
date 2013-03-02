/** コンソールへの出力を制御する。
 * Version:      0.28(dmd2.062)
 * Date:         2013-Mar-02 20:15:11
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.util.output;
private import std.stdio, std.range, std.conv, std.traits;
version(Windows) private import sworks.compo.win32.sjis;

/// コンソールへの出力を制御する.
struct Output
{ static:
	/// 冗長度を示す
	enum MODE : ubyte
	{
		QUIET = 0,
		ERROR = 1, // release コンパイル時の初期値
		LOG = 2,
		VERBOSE = 3, // debug コンパイル時の初期値
	}

	private File _file; // ログファイル

	debug private MODE _mode = MODE.VERBOSE; // 現在の冗長度
	else private MODE _mode = MODE.ERROR;

	enum TAB_WIDTH = 4; // インデントの幅
	private int _current_indent = 0;
	private bool _is_newline = true;

	public void open( string filename, string mode = "w" )
	{
		_file = File( filename, mode );
	}

	public void close(){ if( _file !is stdout && _file !is stderr ) _file.close; _file = stderr; }

	static this(){ _file = stdout; }
	static ~this() { close(); }

	public MODE mode() nothrow @property { return _mode; }
	public void mode(MODE m) nothrow @property { debug {} else _mode = m; }
	public int indent() nothrow @property { return _current_indent; }
	public void indent( int i ) nothrow @property { _current_indent = 0 < i ? i : 0; }
	public void incIndent() nothrow { _current_indent++; }
	public void decIndent() nothrow { _current_indent = 0 < _current_indent ? _current_indent-1 : 0; }

	private void _outindent( )
	{
		if( _is_newline ) _file.write( take( repeat( ' ' ), _current_indent * TAB_WIDTH ) );
		_is_newline = false;
	}
	private void _outln( )
	{
		_file.writeln();
		_is_newline = true;
	}

	private void _out( T ... )( T msg )
	{
		_outindent( );
		if( _file !is stdout && _file !is stderr ) foreach( one ; msg ) _file.write( one.to!string );
		else
		{
			version( Windows ) foreach( one ; msg ) _file.write( one.toMBS.c );
			else foreach( one ; msg ) _file.write( one.to!string );
		}
	}

	/// エラー出力
	public void errorln( T ... )( lazy T msg )
	{
		if(_mode & MODE.ERROR) { _out( msg ); _outln( ); }
	}

	public void error( T ... )( lazy T msg )
	{
		if(_mode & MODE.ERROR) { _out( msg ); }
	}

	/// ログの出力。冗長度が MODE.VERBOSE の時のみ出力される。
	public void logln( T ... )( lazy T msg )
	{
		if(_mode & MODE.LOG) { _out( msg ); _outln( ); }
	}
	public void log( T ... )( lazy T msg )
	{
		if(_mode & MODE.LOG) { _out( msg ); }
	}

	/// 現在の冗長度に関係なく debug コンパイル時のみ出力される。
	public void debln( T ... )( lazy T msg )
	{
		debug { _out( msg ); _outln( ); }
	}
	public void deb( T ... )( lazy T msg )
	{
		debug { _out( msg ); }
	}

	/// 現在の冗長度に関係なく必ず出力される。
	public void opCall( T ... )( lazy T msg )
	{
		_out( msg );
	}

	public void ln( T... )( lazy T msg )
	{
		_out(  msg );
		_outln();
	}

}

debug( output )
{
	void main()
	{
		string func(){ writeln("func are called." ); return "func"; }
		Output.incIndent;
		Output.ln( 10, 20, "hello", "world", func, "日本語" );
	}
}
