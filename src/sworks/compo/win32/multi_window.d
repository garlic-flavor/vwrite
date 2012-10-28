/** multi_window.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.multi_window;
public import std.string, std.algorithm, std.array;
public import sworks.compo.win32.util;
public import sworks.compo.win32.wndclass;
public import sworks.compo.win32.windowhandle;
public import sworks.compo.win32.msg;
debug import std.stdio;
/*
 * 複数回インスタンス化されるWindowを作る際に利用。
 */
template MultiWindowMix( A ... )
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
		" switch( msg.msg )
		  {
		    case WM_NCCREATE:
		      inst = (cast(_CP*)(msg.plp!CREATESTRUCT.lpCreateParams)).instance;
		      assert( inst !is null );
		      inst.hWnd = hWnd;
		      msg.plp!CREATESTRUCT.lpCreateParams = (cast(_CP*)(msg.plp!CREATESTRUCT.lpCreateParams)).lparam;

		      msg.hWnd.userdata = _instance.data.length;
		      _instance.put( inst );
		      return inst.wm_nccreate(msg);
		    case WM_CREATE:
		      msg.plp!CREATESTRUCT.lpCreateParams = (cast(_CP*)(msg.plp!CREATESTRUCT.lpCreateParams)).lparam;
		      return _instance.data[ msg.hWnd.userdata ].wm_create( msg );
		    case WM_NCDESTROY:
		      pos = msg.hWnd.userdata;
		      scope(exit)
		      {
		        delete _instance.data[ pos ];
		        if( 1 < _instance.data.length )
		        {
		          _instance.data[ pos ] = _instance.data[ $-1 ];
		          _instance.data[ pos ].hWnd.userdata = pos;
		          _instance.shrinkTo( _instance.data.length - 1 );
		        }
		        else _instance.clear();
		      }
		      return _instance.data[ pos ].wm_ncdestroy( msg );
		    ";
		foreach( one ; CASES )
		{
			static if( is( typeof(one) : uint ) )
				result ~= "case " ~ to!string(one) ~ " : ";
			else static if( is( typeof(one) : string ) )
			{
				static assert( one != "wm_nccreate" || one != "wm_create" || one != "wm_ncdestroy" );
				result ~= " return _instance.data[ msg.hWnd.userdata ]." ~ one ~ "(msg);";
			}
			else static assert(0, to!string(one) ~ " is not correct argument of MultiWindowMix." );
		}
		
		foreach( one ; __traits( derivedMembers, typeof(this)) )
		{
			static if( one.startsWith( "wm_" ) && "wm_nccreate"!= one && "wm_create"!=one && "wm_ncdestroy"!=one )
			{
				static assert( IsMsgHandler!( typeof( __traits( getMember, typeof(this), one ) ) ) );
				result ~= "case " ~ one.toUpper ~ " : return _instance.data[ msg.hWnd.userdata ]." ~ one ~ "(msg);";
			}
		}
		result ~= " default: }";
		return result;
	}

	extern(Windows) static public int MsgCracker( HWND hWnd, uint uMsg, uint wp, int lp )
	{
		scope auto msg = new Msg( hWnd, uMsg, wp, lp );
		static Appender!(typeof(this)[]) _instance;
		size_t pos;
		typeof(this) inst;

		try{ mixin(ProcMixStr); }
		catch( WinException we ) okbox( we.toStringW );
		catch(Throwable t) okbox( (new WinException( t.toString )).toStringW );

		return DefWindowProc( hWnd, uMsg, wp, lp );
	}

	//------------------------------------------------------------------------------
	static public WNDCLASSEX* ready( HMODULE hInst = null )
	{
		auto wc = new WNDCLASSEX;
		(*wc).ready( CLASS_NAME.ptr, &MsgCracker, hInst );
		return wc;
	}

    //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//
    //
	public WindowHandle hWnd;
	alias hWnd this;

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

	int wm_nccreate(Msg msg) { return msg.defProc; }
	int wm_create(Msg msg) { return msg.defProc; }
	int wm_ncdestroy(Msg msg) { return msg.defProc; }
}

debug(multi_window)
{
	import sworks.compo.win32.single_window;

	final class MultiChild
	{ mixin MultiWindowMix!() MWM;

		static void ready()
		{
			auto wc = MWM.ready();
			(*wc).regist;
		}

		HBRUSH brush;
		this( HWND parent, uint color )
		{
			brush = CreateSolidBrush( color );
			MWM.create( WS_CHILD | WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS, "multi1"w.ptr, parent );
		}

		int wm_paint( Msg )
		{
			PAINTSTRUCT ps;
			auto hdc = BeginPaint( hWnd, &ps );
			HBRUSH hPrevBrush = SelectObject( hdc, brush );
			BitBlt( hdc, 0, 0, 100, 100, null, 0, 0, PATCOPY );
			SelectObject( hdc, hPrevBrush );
			EndPaint( hWnd, &ps );
			return 0;
		}

		int wm_close( Msg msg)
		{
			okbox("i'm closing"w);
			return msg.defProc;
		}

		int wm_destroy( Msg )
		{
			DeleteObject(brush);
			return 0;
		}
	}


	final class MultiTest
	{ mixin SingleWindowMix!() SWM;
		
		this()
		{
			auto wc = SWM.ready;
			(*wc).regist();
			SWM.create( WS_OVERLAPPEDWINDOW | WS_VISIBLE, "test"w.ptr );
		}
		
		MultiChild child1, child2;

		int wm_create( Msg msg )
		{
			MultiChild.ready;
			child1 = new MultiChild( msg.hWnd, 0xff0000 );
			ShowWindow( child1, SW_SHOW );

			child2 = new MultiChild( msg.hWnd, 0x00ff00 );
			ShowWindow( child2, SW_SHOW );
			return 0;
		}

		int wm_destroy( Msg )
		{
			scope(exit)PostQuitMessage(0);

			return 0;
		}
	}

	void main()
	{
		try
		{
			scope auto mt = new MultiTest();

			MSG msg;
			while( GetMessage( &msg, null, 0, 0 ) > 0 ) { DispatchMessage( &msg ); }
		}
		catch(WinException w) okbox( w.toStringW );
		catch( Throwable t ) okbox( t.toUTF16 );
	}
}