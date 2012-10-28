/** font.d for padm.exe
 * \version      0.0005 dmd2.055
 * \date         2011-Sep-21 02:47:54
 * \author       KUMA
 * \par license:
 * CC0
 */
module sworks.compo.win32.font;
import std.exception;
import sworks.compo.win32.port;

/**
 * LOGFONT 構造体のラッパ
 */
class LogFont
{
	LOGFONT lf;
	alias lf this;

	this(wstring faceName, int width, int height, int weight)
	{
		with( lf )
		{
			lfWidth = width;
			lfHeight = height;
			lfWeight = weight;
			lfCharSet = DEFAULT_CHARSET;
			lfOutPrecision = OUT_DEFAULT_PRECIS;
			lfClipPrecision = CLIP_DEFAULT_PRECIS;
			lfQuality = DEFAULT_QUALITY;
			lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;
			lfFaceName[0..faceName.length] = faceName;
		}
	}
}

/*
 * フォントハンドルのラッパ
 * フォント作成には、上記のLogFont クラスを利用する。
 */
class Font
{
	HFONT handle;
	uint color;
	uint bkColor;
	int bkMode;

	this( LogFont lf, uint color = 0x000000, uint bkColor = 0xffffff, int bkMode = OPAQUE )
	{
		handle = enforce( CreateFontIndirect( &(lf.lf) ) );
		this.color = color;
		this.bkColor = bkColor;
		this.bkMode = bkMode;
	}

	~this() { if( null !is handle ) DeleteObject( handle ); }

	void destroy()
	{
		if( handle )
		{
			DeleteObject( handle );
			handle = null;
		}
	}

	/*
	 * 引数 func の内部では、このフォントが適用されている。
	 * フォント名、大きさ、色、背景色、背景モードが一括適用され、関数終了後に戻される。
	 */
	void apply( HDC hdc, scope void delegate() func )
	{
		auto prevFont = SelectObject( hdc, handle );
		auto prevBkMode = SetBkMode( hdc, bkMode );
		auto prevBkColor = SetBkColor( hdc, bkColor );
		auto prevColor = SetTextColor( hdc, color );
		scope( exit )
		{
			SetTextColor( hdc, prevColor );
			SetBkColor( hdc, prevBkColor );
			SetBkMode( hdc, prevBkMode );
			SelectObject( hdc, prevFont );
		}

		func();
	}
}