/**
 * Version:    0.31(dmd2.069.2)
 * Date:       2015-Dec-17 19:00:22.8567485
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.base.strutil;

/// SHIFT-JIS の格納に。
alias jchar = ubyte;
/// ditto
alias immutable(jchar)[] jstring;
/// ditto
alias immutable(jchar)* jstringz;
/// ditto
alias immutable(wchar)* wstringz;

/// suger
jchar j(T:char)(T c){ return cast(jchar)c; }
/// ditto
jstring j(T)(T[] str){ return cast(jstring)str; }
/// ditto
jstringz jz(T)(T* strz){ return cast(jstringz)strz; }
/// ditto
string c(T)(T[] jstr){ return cast(string)jstr; }


///
T enstring(T)(T str, lazy string msg = "failure in enstring")
{
    if (0 < str.length) return str;
    else throw new Exception(msg);
}

///
wstring fromUTF16z(const(wchar)* str)
{
    import std.conv : to;
    size_t i;
    for (i = 0 ; str[i] != '\0' ; ++i){}
    return str[0 .. i].to!wstring;
}

///
struct TStringAppender(TCHAR)
{
    private Appender!(immutable(TCHAR)[][]) _payload;

    ///
    this(immutable(TCHAR)[] buf){ _payload.put(buf); }
    ///
    this(const(TCHAR)[] buf){ _payload.put(buf.idup); }

    ///
    ref TStringAppender opCall(const(TCHAR)[] buf)
    { _payload.put(buf.idup); return this; }
    /// ditto
    ref TStringAppender opCall(immutable(TCHAR)[] buf)
    { _payload.put(buf); return this; }

    ///
    immutable(TCHAR)[] dump()
    { auto str = _payload.data.join(); _payload.clear; return str; }

    ///
    ref TStringAppender ln(){ _payload.put("\n"); return this; }
    /// ditto
    ref TStringAppender ln(immutable(TCHAR)[] buf)
    { _payload.put("\n"); _payload.put(buf); return this; }
    /// ditto
    ref TStringAppender ln(const(TCHAR)[] buf)
    { _payload.put("\n"); _payload.put(buf.idup); return this; }
    /// ditto
    ref TStringAppender ln(uint t)
    { _payload.put("\n"); _payload.put(" ".repeat.take(t*4)); return this; }

    ///
    ref TStringAppender tab(uint t)
    { _payload.put(" ".repeat.take(t*4)); return this; }

}
