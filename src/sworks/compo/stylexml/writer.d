/**
 * Version:      0.27(dmd2.060)
 * Date:         2012-Oct-29 01:24:08
 * Authors:      KUMA
 * License:      CC0
*/
module sworks.compo.stylexml.writer;

import std.algorithm, std.uni, std.range, std.string;

import sworks.compo.util.array;

//------------------------------------------------------------------------------
class Writer
{
	private Array!(char) _arr;

	private bool _newline;
	public string bracket;

	this( string bracket ){ this.bracket = bracket; _newline = true; }

	void put( const(char)[] items ... )
	{
		if( _newline ) items = items.stripLeft;
		putall( items );
	}

	void putall( const(char)[] items ... )
	{
		if( 0 == items.length ) return;
		_arr.replace( _arr.length, _arr.length, items );
		_newline = false;
	}

	void putln()
	{
		if( !_newline )
		{
			auto c = countUntil!"!std.uni.isWhite(a)"( _arr.data.retro );
			_arr.replace( _arr.length - c, _arr.length, bracket );
		}
		else _arr.replace( _arr.length, _arr.length, bracket );
		_newline = true;
	}

	const(char)[] opSlice() { return _arr[]; }
}
