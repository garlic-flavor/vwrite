module sworks.compo.win32.gdi;
pragma(lib,"gdi32.lib");

public import sworks.compo.win32.util;

template GDIMix()
{
	void context( scope void delegate( HDC ) routine ) @property
	{
		HDC hdc = enforceW( GetDC( hWnd ), "GDIHandle.context : failure in GetDC." );
		scope( exit ) ReleaseDC( hWnd, hdc );
		routine( hdc );
	}

	void begin( scope void delegate( HDC , ref PAINTSTRUCT ) routine ) @property
	{
		PAINTSTRUCT ps;
		HDC hdc = enforceW( BeginPaint( hWnd, &ps ), "GDIHandle.context : failure in BeginPaint." );
		scope( exit ) EndPaint( hWnd, &ps );
		routine( hdc, ps );
	}
}

class BitmapSet
{
	HDC hdc;
	HBITMAP hbmp;
	private HBITMAP _prevBmp;

	alias hdc this;

	this( HDC hdc, int x, int y )
	{
		this.hdc = CreateCompatibleDC( hdc );
		this.hbmp = CreateCompatibleBitmap( hdc, x, y );
		_prevBmp = SelectObject( this.hdc, hbmp );
	}

	~this()
	{
		if( null !is hdc )
		{
			SelectObject( hdc, _prevBmp );
			DeleteDC( hdc );
		}
		if( null !is hbmp )
		{
			DeleteObject( hbmp );
		}
	}


	void unSelect() { SelectObject( hdc, _prevBmp ); }

	void select() { SelectObject( hdc, hbmp ); }
}