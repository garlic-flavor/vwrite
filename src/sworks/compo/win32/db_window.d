module sworks.compo.win32.db_window;

/*
import std.array, std.format;
import sworks.compo.win32.single_window;
import sworks.compo.win32.font;

final class DebugWindow
{
	static void start()
	{
		auto wc = SWM.getWndClass;
		wc.regist;
		auto h = wc.create( 0, "DEBUG"w.ptr, WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME );
		ShowWindow( h, SW_SHOW );
	}

	static void end()
	{
		SWM.destroy;
	}

	/////XXXXX\\\\\XXXXX/////XXXXX\\\\\XXXXX/////XXXXX\\\\\XXXXX/////XXXXX\\\\\
	static void dump( T... )( T msg )
	{
		if( _instance is null ) return;
		wstring str;
		foreach( one ; msg ){ str ~= " " ~ to!wstring( to!string( one ) ); }
		_instance.edit.text = str.toUTF16z;
	}

	static void dumpf( T... )( string fmt, T msg )
	{
		if( _instance is null ) return;
		auto str = appender!string();
		formattedWrite( str, fmt, msg );
		_instance.edit.text = toUTF16z( str.data );
	}


	//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
	WindowHandle edit;
	enum EDIT_ID = 0x0011;

	int wm_create( Msg )
	{
		edit = createWindowHandle( 0, "EDIT"w.ptr, ""w.ptr, WS_VISIBLE | WS_CHILD | WS_HSCROLL | WS_VSCROLL
		                                                  | ES_MULTILINE
		                         , CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT
		                         , cast(void*)handle, cast(HMENU) EDIT_ID );
		return 0;
	}
	
	int wm_destroy( Msg )
	{
		if( edit !is null ) edit.destroy;
		return 0;
	}

	int wm_size( Msg msg )
	{
		if( SIZE_RESTORED != msg.wp ) return 0;

		if( edit !is null) edit.move( 0, 0, msg.llp, msg.hlp );

		return 0;
	}

	mixin SingleWindowMix!() SWM;
}
*/