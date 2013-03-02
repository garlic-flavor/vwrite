/** 追記の可不可を変更できる文字列
 * Version:      0.28(dmd2.062)
 * Date:         2013-Mar-02 20:15:11
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.stylexml.macro_item;
private import std.algorithm, std.conv, std.exception;

/// 複数の文字列を追加できる。上書き不可にもできる。
class MacroItem
{
	private string[] _value;
	public bool isMutable;
	public string separator;

	this( string v = "", string separator=" ", bool isMutable = true )
	{
		if( 0 < v.length ) _value = [ v ];
		else _value = null;

		this.isMutable = isMutable;
		this.separator = separator;
	}

	public override string toString() @property { return to!string( joiner( _value, separator) );}
	public string[] toArray() nothrow @property { return _value[]; }
	public bool isEmpty() const nothrow @property { return 0 == _value.length; }

	/// 追加
	public MacroItem opOpAssign(string OP : "~")( string v )
	{
		if( isMutable && 0 < v.length ) _value ~= v;
		return this;
	}

	/// 代入
	public MacroItem opAssign( string v )
	{
		if( !isMutable ) return this;
		if( 0 == v.length ) _value = null;
		else _value = [ v ];
		return this;
	}

	public MacroItem opAssign( string[] v )
	{
		if( isMutable ) _value = v;
		return this;
	}

	public string opCast(TYPE : string)() { return to!string(joiner(_value, separator)); }
}

/** 改行文字定義用
 * value    means
 * n        \n
 * r        \r
 * rn       \r\n
 */
class BracketItem : MacroItem
{
	this( string value = "n" ) { super(); opAssign(value); }

	@disable override public string[] toArray() nothrow @property { return _value[]; }
	@disable override public MacroItem opOpAssign(string OP : "~")( string ){ return this; }

	override public BracketItem opAssign( string v )
	{
		char[] bracket = new char[v.length];
		foreach( i, one ; v )
		{
			if     ( one == 'n' ) bracket[i] = '\n';
			else if( one == 'r' ) bracket[i] = '\r';
			else throw new Exception( one ~ " is not available. 'r' or 'n' are available.");
		}
		enforce( 0 < bracket.length, v ~ " is not an available as bracket descripter" );
		_value = [ bracket.idup ];
		return this;
	}
}
