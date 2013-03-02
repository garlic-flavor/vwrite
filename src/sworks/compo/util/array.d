/** \file array.d variantな要素の為の効率のよい(?)動的配列の実装
 * Version:      0.28(dmd2.062)
 * Date:         2013-Mar-02 20:15:11
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.util.array;
import std.algorithm, std.array;;

struct Array(E)
{
	public Appender!(E[]) _app;
	alias _app this;

    //----------------------------------------------------------------------
    // no copy occor
	this( E[] arr ... )
	{
		_app = Appender!(E[])( arr );
	}

    //----------------------------------------------------------------------
	size_t length() @property { return _app.data.length; }
	E* ptr() @property { return _app.data.ptr; }

	static if( is( E == class ) )
	{
		E opIndex( size_t i ) { return _app.data[ i ]; }
		void opIndexAssign( E v, size_t i ) { _app.data[ i ] = v; }
		E[] opSlice() { return _app.data[]; }
		E[] opSlice( size_t i, size_t j ) { return _app.data[ i .. j ]; }
	}
	else
	{
		const(E) opIndex( size_t i ) { return _app.data[ i ]; }
		void opIndexAssign( const E v, size_t i ) { _app.data[ i ] = v; }
		const(E)[] opSlice() { return _app.data[]; }
		const(E)[] opSlice( size_t i, size_t j ) { return _app.data[ i .. j ]; }
	}
	void opAssign( const(E)[] arr ... ){ _app = Appender!(E[])( cast(E[])arr ); }
	void opAssign( Array arr ) { _app = arr._app; }
	void opSliceAssign( E val ){ _app.data[ 0 .. $ ] = val; }
	void opSliceAssign( const(E)[] val ){ _app.data[ 0 .. $ ] = cast(E[])val; }
	void opSliceAssign( E val, size_t i, size_t j ) { _app.data[ i .. j ] = val; }
	void opSliceAssign( const(E)[] val, size_t i, size_t j ) { _app.data[ i .. j ] = cast(E[])val; }
	

    //----------------------------------------------------------------------
    // from <= to <= buffer.length
	sizediff_t replace( size_t from, size_t to, in const(E)[] a ... )
	{
		from = min( from, _app.data.length );
		to = min( to, _app.data.length );
		if( to < from ) swap( from, to );

		size_t len = to - from;

		// 長さが一緒
		if     ( a.length == len )
		{
			_app.data[ from .. from + a.length ] = cast(E[])a;
		}
		// 短かくなる
		else if( a.length < len )
		{
			size_t amount = _app.data.length - to;
			size_t oldorg = to;
			size_t neworg = from + a.length;
			for( size_t i = 0 ; i < amount ; i++ )
			{
				_app.data[ neworg + i ] = _app.data[ oldorg + i ];
			}
			_app.shrinkTo( neworg + amount );
			_app.data[ from .. from + a.length ] = cast(E[])a;
		}
		//延びる。a の尻が元の配列より出る。
		else if( _app.data.length < from + a.length )
		{
			size_t oldlength = _app.data.length;
			size_t a_copy = a.length - (from + a.length - oldlength);
			_app.put( cast(E[])a[ a_copy .. $ ] );
			_app.put( _app.data[ to .. oldlength ] );
			_app.data[ from .. oldlength ] = cast(E[])a[ 0 .. a_copy ];
		}
		// 出ない
		else
		{
			size_t app_copy = _app.data.length - (from - to + a.length);
			size_t neworg = _app.data.length;
			_app.put( _app.data[ app_copy .. $ ] );
			size_t amount = app_copy - to;
			for( size_t i = 1 ; i <= amount ; i++ )
			{
				_app.data[ neworg - i ] = _app.data[ app_copy - i ];
			}
			_app.data[ from .. from + a.length ] = cast(E[])a;
		}

		return a.length - len;
	}

}

debug(array)
{
	import std.stdio;
	void main()
	{
		auto buf = Array!(char)();

		buf.replace( 0, 0, "hello good-bye." );
		buf.put( ' ' );
		buf.replace( 6, 6, "world, " );
		writeln("1:", buf[] );

		buf.replace( 2, 4, "lll" );
		writeln( "2:", buf[] );

		buf.replace( 7, 14 );
		writeln( "3:", buf[] );

	}
}