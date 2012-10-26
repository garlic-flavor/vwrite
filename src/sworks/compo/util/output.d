/** \file output.d コンソールへの出力を制御する。
 * Version:      0.26(dmd2.060)
 * Date:         2012-Oct-27 00:09:35
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.util.output;
private import std.stdio, std.range, std.conv, std.traits;
private import sworks.compo.util.strutil;

/// コンソールへの出力を制御する.
class Output
{
	/// 冗長度を示す
	enum MODE : ubyte
	{
		QUIET = 0,
		ERROR = 1, ///< release コンパイル時の初期値
		LOG = 2,
		VERBOSE = 3, ///< debug コンパイル時の初期値
	}

	private File file; ///< ログファイル名

	private MODE m_mode; ///< 現在の冗長度

	enum TAB_WIDTH = 4; ///< インデントの幅
	private int current_indent = 0;
	bool previous_is_ln = true;

	/**
	 * \param name ログファイル名を指定する。
	 * \details ログファイルが開かれていない場合は、出力はコンソールになる。
	 */
	this( string name = "" )
	{
		if( 0 < name.length ) file.open( name, "w" );

		debug m_mode = MODE.VERBOSE;
		else m_mode = MODE.ERROR;
	}

	~this()
	{
		file.close;
	}

	public MODE mode() nothrow @property { return m_mode; }
	public MODE mode(MODE m) nothrow @property { debug {} else m_mode = m; return m; }
	public int indent() nothrow @property { return current_indent; }
	public void indent( int i ) nothrow @property { current_indent = 0 < i ? i : 0; }
	public void incIndent() nothrow { current_indent++; }
	public void decIndent() nothrow { current_indent = 0 < current_indent ? current_indent-1 : 0; }

	private void _outindent( ref File o )
	{
		if( previous_is_ln ) o.write( take( repeat( ' ' ), current_indent * TAB_WIDTH ) );
		previous_is_ln = false;
	}

	private void _outln( ref File o )
	{
		o.writeln();
		previous_is_ln = true;
	}

	private void _out( ref File o, string msg )
	{
		o.write( msg );
		previous_is_ln = false;
	}

	private void _output( T ... )( ref File o, T msg )
	{
		if( file.isOpen )
		{
			_outindent( file );
			foreach( one ; msg ) _out( file, one.to!string );
		}
		else
		{
			_outindent( o );
			version( Windows ) foreach( one ; msg ) _out( o, toMBStr(one) );
			version( linux ) foreach( one ; msg ) _out( o, one.to!string );
		}
	}

	private void _outputln( T ... )( ref File o, T msg )
	{
		if( file.isOpen )
		{
			_outindent( file );
			foreach( one ; msg ) _out( file, one.to!string );
			_outln( file );
		}
		else
		{
			_outindent( o );
			version( Windows ) foreach( one ; msg ) _out( o, toMBStr(one) );
			version( linux ) foreach( one ; msg ) _out( o, one.to!string );
			_outln( o );
		}
	}


	/// エラー出力
	public void errorln( T ... )( lazy T msg )
	{
		if(m_mode & MODE.ERROR) _outputln( stderr, msg );
	}


	public void error( T ... )( lazy T msg )
	{
		if(m_mode & MODE.ERROR) _output( stderr, msg );
	}


	/// ログの出力。冗長度が MODE.VERBOSE の時のみ出力される。
	public void logln( T ... )( lazy T msg )
	{
		if(m_mode & MODE.LOG) _outputln( stdout, msg );
	}
	public void log( T ... )( lazy T msg )
	{
		if(m_mode & MODE.LOG) _output( stdout, msg );
	}


	/// 現在の冗長度に関係なく debug コンパイル時のみ出力される。
	public void debln( T ... )( lazy T msg )
	{
		debug { _outputln( stdout, msg ); }
	}
	public void deb( T ... )( lazy T msg )
	{
		debug { _output( stdout, msg ); }
	}

	/// 現在の冗長度に関係なく必ず出力される。
	public void opCall( T ... )( lazy T msg )
	{
		_output( stdout, msg );
	}

	public void ln( T... )( lazy T msg )
	{
		_outputln( stdout, msg );
	}

}

debug( output )
{
	void main()
	{
		string func(){ writeln("func are called." ); return "func"; }
		Output.incIndent;
		Output.ln( 10, 20, "hello", "world", func );
	}
}