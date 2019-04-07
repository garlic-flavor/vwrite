/** SHIFT-JIS の扱いに。
 * Dmd:        2.085.0
 * Date:       2019-Apr-01 01:18:26
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.win32.sjis;
public import sworks.base.strutil;

debug import std.stdio : writeln;

// 文字列を SHIFT-JIS文字列に.
jstring toMBS(U : T[], T)(U msg, int codePage = 0)
{
    import std.conv : to;
    import std.ascii : isASCII;
    import std.exception : enforce;
    import std.traits : Unqual, isSomeChar;
    import core.sys.windows.windows : WideCharToMultiByte;

    static if      (is(Unqual!T == jchar)) return msg.j;
    else static if (isSomeChar!T)
    {
        bool ASCIIOnly = true;
        for (size_t i = 0 ; i < msg.length && ASCIIOnly ; ++i)
            ASCIIOnly = msg[i].isASCII;
        if (ASCIIOnly) return msg.to!string.j;

        auto str16 = msg.to!wstring;
        auto result = new char[
            WideCharToMultiByte(codePage, 0, str16.ptr, cast(int)str16.length,
                                null, 0, null, null)];

        enforce(0 < result.length &&
                result.length == WideCharToMultiByte(
                    codePage, 0, str16.ptr, cast(int)str16.length, result.ptr,
                    cast(int)result.length, null, null));
        return result.j;

    }
    else return msg.to!string.toMBS;
}

/// ditto
jstring toMBS(T)(T msg, int codePage = 0)
{
    import std.conv : to;
    return msg.to!string.toMBS(codePage);
}


// 文字列をSHIFT-JISのNull終端文字列に。
jstringz toMBSz(U : T[], T)(U[] msg, int codePage = 0)
{
    import std.conv : to;
    import std.utf : toUTFz;
    alias toUTF8z = toUTFz!(immutable(char)*);
    import std.ascii : isASCII;
    import std.exception : enforce;
    import std.traits : Unqual, isSomeChar;
    import core.sys.windows.windows : WideCharToMultiByte;

    static if      (is(Unqual!T == jchar)) return (msg ~ '\0').jz;
    else static if (isSomeChar!T)
    {
        bool ASCIIOnly = true;
        for (size_t i = 0 ; i < msg.length && ASCIIOnly ; ++i)
            ASCIIOnly = msg[i].isASCII;
        if (ASCIIOnly) return msg.toUTF8z.jz;

        auto str16 = msg.to!wstring;
        auto result = new char[
            WideCharToMultiByte(codePage, 0, str16.ptr, cast(int)str16.length,
                                null, 0, null, null) + 1];

        enforce(1 < result.length &&
                result.length == WideCharToMultiByte(
                    codePage, 0, str16.ptr, cast(int)str16.length, result.ptr,
                    cast(int)result.length, null, null) + 1);
        return result.ptr.jz;

    }
    else msg.to!string.toMBSz;
}

/// ditto
jstring toMBSz(T)(T msg, int codePage = 0)
{
    import std.conv : to;
    return msg.to!string.toMBSz(codePage);
}

// SHIFT-JIS文字列をUTF文字列に
immutable(CHAR)[] fromMBS(CHAR)(const(jchar)[] msg, int codePage = 0)
    if (is(CHAR == char) || is(CHAR == wchar) || is(CHAR == dchar) ||
        is(CHAR == jchar))
{
    import std.conv : to;
    import std.ascii : isASCII;
    import std.exception: enforce;
    import core.sys.windows.windows : MultiByteToWideChar;

    static if (is(CHAR == jchar)) return msg;

    bool ASCIIOnly = true;
    for (size_t i = 0 ; i < msg.length && ASCIIOnly ; ++i)
        ASCIIOnly = msg[i].isASCII;
    if (ASCIIOnly) return msg.c.to!(immutable(CHAR)[]);

    auto result = new wchar[
        MultiByteToWideChar(codePage, 0, cast(const(CHAR)*)msg.ptr,
                            cast(int)msg.length, null, 0)];
    enforce(0 < result.length &&
            result.length ==MultiByteToWideChar(
                codePage, 0, cast(const(CHAR)*)msg.ptr, msg.length, result.ptr,
                result.length));
    return result.to!(immutable(CHAR)[]);
}

// Null終端SHIFT-JIS文字列をUTF文字列に。
immutable(CHAR)[] fromMBSz(CHAR)(const(jchar)* msg, int codePage = 0)
    if (is(T == char) || is(T == wchar) || is(T == dchar) || is(T == jchar))
{
    size_t i = 0;
    static if (is(CHAR == jchar))
    {
        for (; msg[i] != 0 ; ++i){}
        return msg[0 .. i].j;
    }

    bool ASCIIOnly = true;
    for (; msg[i] != 0 && ASCIIOnly ; ++i) ASCIIOnly = msg[i].isASCII;
    if (ASCIIOnly) return msg[0 .. i].c.to!(immutable(CHAR)[]);

    auto result = new wchar[
        MultiByteToWideChar(codePage, 0, msg, -1, null, 0)];
    enforce(0 < result.length &&
            result.length == MultiByteToWideChar(
                codePage, 0, msg.ptr, cast(int)msg.length, result.ptr,
                cast(int)result.length));
    return result.to!(immutable(CHAR)[]);
}


debug(sjis):

import std.stdio;
void main()
{
    writeln("日本語".toMBS.c);
}
