/** static_window.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.single_window;
public import std.string, std.algorithm;
public import sworks.compo.win32.util;
public import sworks.compo.win32.wndclass;
public import sworks.compo.win32.windowhandle;
public import sworks.compo.win32.msg;

/**
 * メッセージクラッカを生成
 * CASES はメッセージの値および、メッセージを受け取る関数名の文字列の2つを一組とするタプル
 * 例: WM_COMMAND,"command", WM_PAINT,"draw", ...
 *
 * 関数名が、wm_command とか、 wm_paint とかの場合は自動で追加される。
 *
 */
template SingleWindowMix( A ... )
{
	alias typeof(this) THIS;

	static if( 0 < A.length && is( typeof( A[0] ) : string ) )
	{
		static const Readz CLASS_NAME = Readz( A[0] );
		alias A[ 1 .. $ ] CASES;
	}
	else
	{
		static const Readz CLASS_NAME = Readz( THIS.stringof );
		alias A CASES;
	}

	private struct _CP
	{
		THIS instance;
		void* lparam;
	}

	static private string ProcMixStr()
	{
		string result;
		result =
		" assert( _instance !is null || WM_GETMINMAXINFO == msg.msg || WM_NCCREATE == msg.msg
		        , \"instance is null\" );
		  switch( msg.msg )
		  {
		    case WM_NCCREATE:
		      assert( _instance is null, \"an instance of \" ~ THIS.stringof
		                                 ~ \" can be made only once.\" );
		      _instance = enforce( (cast(_CP*)((msg.plp!CREATESTRUCT()).lpCreateParams)).instance );
		      THIS.hWnd = hWnd;
		      msg.plp!CREATESTRUCT.lpCreateParams = (cast(_CP*)((msg.plp!CREATESTRUCT()).lpCreateParams)).lparam;
		      return _instance.wm_nccreate( msg );
		    case WM_CREATE:
		      msg.plp!CREATESTRUCT.lpCreateParams = (cast(_CP*)((msg.plp!CREATESTRUCT()).lpCreateParams)).lparam;
		      return _instance.wm_create( msg );
		    case WM_NCDESTROY:
		      scope( exit ){ THIS.hWnd = null; _instance = null; }
		      return _instance.wm_ncdestroy( msg );
		  ";

		foreach( one ; CASES)
		{
			static if     ( is( typeof(one) : uint ) )
				result ~= "case " ~ to!string(one) ~ " : ";
			else static if( is( typeof(one) : string) )
			{
				static assert( one != "wm_nccreate" || one != "wm_create" || one != "wm_ncdestroy" );
				result ~= "return _instance." ~ one ~ "( msg );";
			}
			else static assert(0, to!string(one) ~ " is not correct as a parameter for SingleWindowMix." );
		}

		foreach( one ; __traits(derivedMembers, THIS ) )
		{
			static if( one.startsWith("wm_") && "wm_nccreate" != one && "wm_ncdestroy" != one && "wm_create" != one )
			{
				static assert( IsMsgHandler!( typeof( __traits(getMember, THIS, one ) ) ) );
				result ~= "case " ~ one.toUpper ~ " : return _instance." ~ one ~"( msg );";
			}
		}

		result ~= " default: }";
		return result;
	}

	static public WindowHandle hWnd;
	alias hWnd this;

	extern(Windows) static public int MsgCracker( HWND hWnd, uint uMsg, uint wp, int lp )
	{
		scope auto msg = new Msg( hWnd, uMsg, wp, lp );
		static THIS _instance;
		try{ mixin(ProcMixStr); }
		catch( WinException we ) okbox( we.toStringW );
		catch(Throwable t) okbox( (new WinException(t.toString)).toStringW );

		return DefWindowProc( hWnd, uMsg, wp, lp );
	}


    //----------------------------------------------------------------------
	static WNDCLASSEX* ready( HMODULE hInst = null )
	{
		auto wc = new WNDCLASSEX();
		.ready( *wc, CLASS_NAME.ptr, cast(WNDPROC)&MsgCracker, hInst );
		return wc;
	}

	//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
	//

	HWND create( uint style, const(wchar)* title = null
	           , HWND parent = null, HMENU menu = null, uint exStyle = 0
	           , int x = CW_USEDEFAULT, int y = CW_USEDEFAULT, int w = CW_USEDEFAULT, int h = CW_USEDEFAULT
	           , void* param = null, HINSTANCE hInst = null )
	{
		auto cp = _CP( this, param );
		if( hInst is null ) hInst = GetModuleHandle( null );
		return enforceW( CreateWindowEx( exStyle, CLASS_NAME.ptr, title, style, x, y, w, h, parent, menu
		                               , hInst, &cp ), "fail at CreateWindowEx( "w ~ CLASS_NAME[] ~ " )."w );
	}

	/// when wm_create is called, the handle is ready.
	int wm_nccreate(Msg msg) { return msg.defProc; }
	int wm_create(Msg msg) { return msg.defProc; }
	int wm_ncdestroy(Msg msg) { return msg.defProc; }
	/// when wm_destroy is end, the handle is disable.
}

debug(single_window)
{
	import std.stdio;

	final class TestWindow
	{ mixin SingleWindowMix!() SWM;

		this()
		{
			auto wc = SWM.ready();
			(*wc).regist;

			SWM.create( WS_OVERLAPPEDWINDOW | WS_VISIBLE, "test"w.ptr);
		}


		int wm_close( Msg msg )
		{
			hWnd.okbox( "closing"w );
			DestroyWindow( msg.hWnd );
			return 0;
		}
		int wm_destroy( Msg )
		{
			scope(exit) PostQuitMessage(0);
			return 0;
		}
	}
	
	void main()
	{
		try
		{
			scope auto tw = new TestWindow();

			MSG msg;
			while( GetMessage( &msg, null, 0, 0 ) > 0 ) { /*TranslateMessage(&msg);*/ DispatchMessage(&msg); }
		}
		catch( WinException w ) okbox( w.toStringW );
		catch( Throwable t ) okbox( t.toString.toUTF16 );
	}
}