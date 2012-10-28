module sworks.compo.win32.single_control;

public import std.string;
public import sworks.compo.util.readz;
public import sworks.compo.win32.util;
public import sworks.compo.win32.wndclass;
public import sworks.compo.win32.windowhandle;
public import sworks.compo.win32.msg;

class ControlMsg : Msg
{
	private WNDPROC proc;

	this( WNDPROC proc, WindowHandle h, uint uMsg, uint wp, int lp )
	{
		this.proc = proc;
		super( h, uMsg, wp, lp );
	}
	override int defProc() { return CallWindowProc( proc, hWnd, msg, wp, lp ); }
}

/**
 * コントロールのメッセージプロシジャをフック
 * 単一インスタンスのみ。
 */
template SingleControlMix( wstring CN, uint id, CASES ... )
{
	alias typeof(this) THIS;

	static public const Readz CLASS_NAME = Readz(CN);
	static public const uint ID = id;

	struct _CP
	{
		THIS instance;
		void* param;
	}

	//
	static private string ProcMixStr()
	{
		string result =
		" assert( _instance !is null || WM_CREATE == msg.msg, \"instance is null\" );
		  switch( uMsg )
		  {
		    case WM_CREATE: // CALL THIS EXPLICITLY! : MsgCracker( hWnd, WM_CREATE, &_CP );
		      enforce( _instance is null, THIS.stringof ~ \" can instatiate only once.\" );
		      handle = hWnd;
		      _instance = msg.pwp!_CP.instance;
		      assert( _instance !is null );
		      OrgProc = cast(WNDPROC) GetWindowLong( hWnd, GWL_WNDPROC );
		      SetWindowLong( hWnd, GWL_WNDPROC, cast(int)&MsgCracker );
		      msg.wp = cast(uint)( msg.pwp!_CP.param );
		      _instance.wm_create( msg );
		      return 0;
		    case WM_NCDESTROY:
		      scope(exit)
		      {
		        SetWindowLong( hWnd, GWL_WNDPROC, cast(int)OrgProc );
		        OrgProc = null;
		        handle = null;
		        _instance = null;
		      }
		      return _instance.wm_ncdestroy( msg );";

		foreach( one ; CASES)
		{
			static if     ( is( typeof(one) : uint ) )
				result ~= "case " ~ to!string(one) ~ " : ";
			else static if( is( typeof(one) : string) )
			{
				static assert( one != "wm_create" || one != "wm_ncdestroy" );
				result ~= "return _instance." ~ one ~ "(msg);";
			}
			else static assert(0, to!string(one) ~ " is not correct argument for SingleControlMix." );
		}

		foreach( one ; __traits( derivedMembers, THIS ) )
		{
			static if( one.startsWith( "wm_" ) && "wm_create"!=one && "wm_ncdestroy"!=one )
			{
				static assert( IsMsgHandler!( typeof( __traits( getMember, THIS, one ) ) ) );
				result ~= "case " ~ one.toUpper ~ " : return _instance." ~ one ~"(msg);";
			}
		}
		result ~= "default: }";
		return result;
	}

	static public WindowHandle handle;
	alias handle this;

	extern(Windows) static public int MsgCracker( in HWND hWnd, uint uMsg, uint wp, int lp )
	{
		static THIS _instance;
		static WNDPROC OrgProc = &MsgCracker;
		scope auto msg = new ControlMsg( OrgProc, WindowHandle( hWnd ), uMsg, wp, lp );

		try{ mixin(ProcMixStr( CASES ) ); }
		catch( WinException we ) .okbox( we.error );
		catch( Throwable t ) .okbox( (new WinException(t.toString)).error );
		return CallWindowProc( OrgProc, hWnd, uMsg, wp, lp );
	}

	//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
	//

	HWND create( uint style, in HWND parent, const(wchar)* title = null, uint exStyle = 0
	           , int x = CW_USEDEFAULT, int y = CW_USEDEFAULT, int w = CW_USEDEFAULT, int h = CW_USEDEFAULT
	           , void* param = null, HMODULE hInst = null )
	{
		auto cp = _CP( this, param );
		if( hInst is null ) hInst = GetModuleHandle( null );

		auto result = enforceW( CreateWindowEx( exStyle, CLASS_NAME.ptr, title, style, x, y, w, h, parent
		                                      , cast(HMENU)ID, hInst, null )
		                      , "failure in CreateWindowEx( "w ~ CLASS_NAME[] ~ " )." );

		MsgCracker( result, WM_CREATE, cast(uint)&cp, 0 );
		return result;
	}

	int wm_create( Msg msg ) { return 0; }
	int wm_ncdestroy(Msg msg) { return msg.defProc; }
	/// when wm_destroy is end, the handle is disable.

	
}

template EditBoxToolMix( alias HANDLE )
{
	static assert( is( typeof( HANDLE ) : WindowHandle ) );

	Readz selectedString() @property
	{
		uint start, end;
		HANDLE.send( EM_GETSEL, cast(uint)&start, cast(int)&end );
		if( start == end ) return null;
		auto t = HANDLE.text;
		wchar[] buf = new wchar[ end - start + 1 ];
		buf[ 0 .. $-1 ] = t[ start .. end ];
		buf[ $-1 ] = '\0';
		return Readz( assumeUnique(buf).ptr, buf.length );
	}
}



debug( single_control )
{
	import sworks.compo.win32.single_window;

	class EditBox
	{ mixin SingleControlMix!( "EDIT", 100 ) SCM;

		this( in HWND hParent)
		{
			SCM.create( WS_CHILD | WS_VISIBLE | WS_BORDER | ES_MULTILINE | ES_WANTRETURN, hParent );
			handle.move( 0, 0, 500, 100 );
		}

		int wm_char( Msg msg )
		{
			if( msg.wp == cast(uint)0x1b ) okbox( "escape!"w );
			return msg.defProc();
		}
	}

	final class TestWindow
	{ mixin SingleWindowMix!() SWM;

		EditBox edit;
		this()
		{
			auto wc = SWM.getWndClass();
			wc.regist;
			SWM.create( WS_OVERLAPPEDWINDOW | WS_VISIBLE,"test"w.ptr );

		}

		int wm_create( Msg msg )
		{
			edit = new EditBox( handle );
			edit.focus();
			return 0;
		}

		int wm_destroy( Msg msg )
		{
			scope(exit)PostQuitMessage( 0 );
			edit.Release();
			return 0;
		}
	}

	void main()
	{
		try
		{
			scope auto tw = new TestWindow();
			MSG msg;
			while( GetMessage( &msg, null, 0, 0 ) > 0 )
			{
				TranslateMessage( &msg );
				DispatchMessage( &msg );
			}
		}
		catch( WinException w ) okbox( w.error );
		catch( Throwable w ) okbox( w.toString );


	}
}