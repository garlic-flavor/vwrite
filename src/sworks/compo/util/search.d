/** 入力されたディレクトリの順にファイルを検索します。
 * Version:      0.26(dmd2.060)
 * Date:         2012-Oct-27 00:09:35
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.util.search;
private import std.algorithm, std.conv, std.exception, std.file, std.path;
/// support only UTF-8

/// 拡張子のつけかえ。ext=="" の時は拡張子を取る。
string setExt( string path, string ext )
{
	if( 0 < ext.length ) return std.path.setExtension( path, ext );
	else return std.path.stripExtension( path );
}

/** path が base フォルダに含まれるか?
 * \return 含まれる場合 true
 */
bool isChildOf( string path, string base )
{
	if( 0 == path.length || 0 == base.length ) return false;
	string apath = path.absolutePath.buildNormalizedPath;
	string abase = base.absolutePath.buildNormalizedPath;
	if( abase.length <= apath.length && abase == apath[ 0 .. abase.length ]
	  && ( abase.length == apath.length || isDirSeparator( abase[ $-1 ] )
	    || isDirSeparator( apath[ abase.length ] ) ) ) return true;
	else return false;
}


/** エントリ内でファイルが見つかった場合、その絶対/相対パスを返す。
 *
 * \Attention
 *   Windowsのみ
 *   検索の順序は entry() を呼び出した順
 *   最初のヒットで検索は終了します。
 */
class Search
{
	// _path は絶対パス(ドライブ名をふくむ。)
	private string[] _path;

	public string[] pathes() nothrow @property { return _path[]; }
	public uint length() const nothrow @property { return _path.length; }

	/** サーチパスに加える。
	 * \param p カレントディレクトリから見えているパスでなければならない。
	 */
	bool entry(string path)
	{
		if( 0 == path.length ) return false;
		auto p = path.absolutePath().buildNormalizedPath;
		if( exists( p ) && isDir( p ) )
		{
			_path ~= p;
			return true;
		}
		else return false;
	}

	/** 絶対パスを探す。
	 * \param p 検索するパス
	 * \return パスが見付かった場合は、その絶対パス。見つからなかった場合は null。
	 */
	string abs( string p )
	{
		if     ( 0 == p.length ){}
		else if( p.isAbsolute )
		{
			if( p.exists ) return p.buildNormalizedPath;
		}
		else
		{
			foreach( one ; _path )
			{
				string result = buildPath( one, p );
				if( result.exists ) return result.buildNormalizedPath;
			}
		}
		return null;
	}

	/// ditto
	string rel(string p)
	{
		string abspath = abs( p );
		if( 0 == abspath.length ) return null;
		else return abspath.relativePath();
	}

	/// entry の子孫ディレクトリかどうか
	bool contain( string p )
	{
		if( 0 == p.length ) return false;
		p = p.absolutePath.buildNormalizedPath;
		foreach( one ; _path )
		{
			if( p.isChildOf( one ) ) return true;
		}
		return false;
	}


	string toString( )
	{
		return to!string(joiner( _path, dirSeparator ));
	}
}

debug(search)
{
	import std.stdio;

	void main()
	{
		Search search = new Search;
		search.entry("..");

		writeln(search);

		string abs_path = search.abs("compo\\..\\compo\\src\\sworks\\compo\\util\\search.d");
		writeln(abs_path);
		string rel_path = search.rel(abs_path);
		writeln(rel_path);
		string abs2 = "Makefile".absolutePath;
		if(abs2.isChildOf("..") ) writeln(abs2~" is a child");
		else writeln(abs2~" is not a child");
	}
}