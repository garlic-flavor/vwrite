/** dll_module.d for oddj.exe
 * Version:      0.004 dmd2.043
 * Date:         Tue May 04 2010
 * Authors:      KUMA
 * 
 * Copyright: 2009-2010, KUMA. Some rights reserved.
 */
module sworks.compo.win32.dll_module;
public import core.runtime;
public import sworks.compo.win32.util;

/**
 * DLL をロードする側で使う。
 * MEMBERS は文字列の配列で、"関数名", "関数の型", "関数の mangle 名", .....
 * の3つを一組として、DLL から取り出したい関数を並べる。
 * このクラスをインスタンス化したら、後はこのクラスのメンバ関数のようにDLLの関数にアクセスできる。
 *
 * DLL の開放には、unload() を使う。
 */
class DLLModule(MEMBERS ... ) // 例 "initialize","void function()","D4test10initializeFZv"...
{                             //     関数名,      関数の型,         mangle名
	HMODULE hmodule;

	static pure private string MemberMixStr()
	{
		string result;
		foreach_reverse( i, one ; MEMBERS )
		{
			if( i%3==1 ) result ~= one;
			else if( i%3==0 ) result ~= " " ~ one ~ ";";
		}

		result ~="private void load_all_functions(){";
		foreach( i, one ; MEMBERS )
		{
			if( i%3==0 ) result ~= one ~ " = ";
			else if( i%3==1 ) result ~= "load_func!(" ~ one ~ ")";
			else if( i%3==2 ) result ~= "(\"" ~ one ~ "\");";
		}
		result ~="}";
		return result;
	}
	mixin(MemberMixStr);

	FUNC_TYPE load_func(FUNC_TYPE)(string mangle_name)
	{
		return enforceW(cast(FUNC_TYPE)GetProcAddress(hmodule, mangle_name.toUTF8z )
			,"failed to load "~mangle_name );
	}

	// インスタンス化と同時にDLLをロード
	this(string module_name )
	{
		hmodule = enforceW( cast(HMODULE)Runtime.loadLibrary(module_name)
			, "failed to load " ~ module_name );
		load_all_functions; // 上記の mixin により生成される関数
	}

	// DLLの開放
	void unload()
	{
		if( hmodule !is null )
		{
			Runtime.unloadLibrary(hmodule);
			hmodule = null;
		}
	}
}

