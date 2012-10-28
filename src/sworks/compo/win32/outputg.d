module sworks.compo.win32.outputg;

/+
import std.file;
import sworks.compo.win32.single_window;

final class OutputG
{ mixin SingleWindowMix!() SWM;

	/// 冗長度を示す
	enum MODE : ubyte
	{
		QUIET = 0,
		ERROR = 1, ///< release コンパイル時の初期値
		LOG = 2,
		VERBOSE = 3, ///< debug コンパイル時の初期値
	}

	static OutputG start()
	{
		auto wc = SWM.getWndClass();
		wc.regist;
		wc.create( 0, ("LogOut"w).ptr, WS_CLIPCHILDREN | WS_OVERLAPPED | WS_THICKFRAME
		                             | WS_CAPTION | WS_VISIBLE , 0, 0, 300, 300);
		return instance;
	}

	static void end()
	{
		SWM.destroy;
	}

	static public void callln( T ... )( T value )
	{
		if( instance !is null ) instance.ln( value );
	}
	static public void call( T ... )( T value )
	{
		if( instance !is null ) instance.opCall( value );
	}

	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\

	WindowHandle _edit;

	Strz _buffer;

	private MODE _mode; ///< 現在の冗長度
	public wstring indent_str = " "; ///< インデントに使う文字列
	private int current_indent = 0;
	bool previous_is_ln = true;

	public MODE mode() nothrow @property { return _mode; }
	public MODE mode(MODE m) nothrow @property { debug {} else _mode = m; return m; }
	public int indent() nothrow @property { return current_indent; }
	public void indent( int i ) nothrow @property { current_indent = 0 < i ? i : 0; }
	public void incIndent() nothrow { current_indent++; }
	public void decIndent() nothrow { current_indent = 0 < current_indent ? current_indent-1 : 0; }


	int wm_create( Msg )
	{
		_edit = createWindowHandle( 0, ("EDIT"w).ptr, (""w).ptr
		                          , WS_CHILD | WS_BORDER | ES_MULTILINE | ES_READONLY
		                          | WS_HSCROLL | WS_VSCROLL | ES_AUTOHSCROLL | ES_AUTOVSCROLL
		                          , CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT
		                          , handle );
		RECT rc; GetClientRect( handle, &rc );
		_edit.move( rc.left, rc.top, rc.right-rc.left, rc.bottom-rc.top );

		_edit.visible = true;

		_buffer = new Strz(0);
		debug _mode = MODE.VERBOSE;
		else _mode = MODE.ERROR;
		return 0;
	}

	int wm_size( Msg msg )
	{
		_edit.move( 0, 0, msg.llp, msg.hlp );
		return 0;
	}

	private void _outindent( )
	{
		if( previous_is_ln ) for( int i=0 ; i<current_indent ; ++i ) _buffer ~= indent_str;
		previous_is_ln = false;
	}

	private void _outln( T ... )( T msg )
	{
		foreach( one ; msg ) _buffer ~= one;
		buffer ~= "\r\n";
		previous_is_ln = true;
	}

	private void _out( T ... )( T msg )
	{
		foreach( one ; msg ) _buffer ~= one;
		previous_is_ln = false;
	}

	private void _draw()
	{
		if( _edit !is null ) _edit.text = _buffer.ptr;
		uint text_length = GetWindowTextLength( _edit );
		_edit.send( EM_SETSEL, text_length, text_length );
		_edit.send( EM_SCROLLCARET );
	}

	public void errorln( T ... )( lazy T msg ) { if( _mode & MODE.ERROR ){ _outln( msg ); _draw; } }
	public void error( T ... )( lazy T msg ) { if( _mode & MODE.ERROR ){ _out( msg ); _draw; } }
	
	public void logln( T ... )( lazy T msg ) { if( _mode & MODE.LOG ){ _outln( msg ); _draw; } }
	public void log( T ... )( lazy T msg ) { if( _mode & MODE.LOG ){ _out( msg ); _draw; } }
	
	public void debln( T ... )( lazy T msg ) { debug { _outln( msg ); _draw; } }
	public void deb( T ... )( lazy T msg ) { debug { _out( msg ); _draw; } }

	public void ln( T ... )( T msg ){ _outln( msg ); _draw; }
	public void opCall( T ... )( T msg ) { _out( msg ); _draw; }


	public void logout( string filename ) { std.file.write( filename, _buffer.toString ); }
}
+/