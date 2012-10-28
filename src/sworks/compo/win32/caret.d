module sworks.compo.win32.caret;

import sworks.compo.win32.util;

/*
 * WindowsAPI のキャレットの薄ラッパ
 *   -- 固定幅フォント専用
 */
class Caret
{
protected:
	HWND _hWnd;
	POINT _pos; ///< クライアントエリア内でのワールド座標
	POINT _size; ///< キャレットの形
	POINT _shift; ///< 下の方に表示したりするときに使う。

public:

	@property
	{
		POINT pos() { return _pos; }
		int x(){ return _pos.x; }
		int y(){ return _pos.y; }
		int width(){ return _size.x; }
		int height(){ return _size.y; }
		int shift_x(){ return _shift.x; }
		int shift_y(){ return _shift.y; }
	}

	this( HWND hWnd, int w, int h, int sx = 0, int sy = 0 )
	{
		_hWnd = hWnd;
		_pos.x = 0; _pos.y = 0;
		_size.x = w; _size.y = h;
		_shift.x = sx; _shift.y = sy;
	}

	~this(){ DestroyCaret(); }

	void set_value( int w, int h, int sx, int sy )
	{
		_size.x = w; _size.y = h;
		_shift.x = sx; _shift.y = sy;
		setPos();
	}

	void set_size( int w, int h )
	{
		if( _size.x != w || _size.y != h )
		{
			_size.x = w; _size.y = h;
			destroy();
			create( _pos.x, _pos.y );
		}
	}

	void set_shift( int sx, int sy ) { _shift.x = sx; _shift.y = sy; setPos;}

	void create( int x, int y )
	{
		CreateCaret( _hWnd, null, _size.x, _size.y );
		setPos( x, y );
		ShowCaret( _hWnd );
	}
	void create(){ create( _pos.x, _pos.y ); }
	void destroy(){ DestroyCaret(); }

	void setPos(){ setPos( _pos.x, _pos.y ); }
	void setPos( int x, int y )
	{
		_pos.x = x; _pos.y = y;
		SetCaretPos( _pos.x + _shift.x, _pos.y + _shift.y );
	}

	void show(){ ShowCaret( _hWnd ); }
	void hide(){ HideCaret( _hWnd ); }
}