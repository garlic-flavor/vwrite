/**
 * Dmd:        2.085.1
 * Date:       2019-Apr-10 23:12:13
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.base.strutil;
debug import std.stdio: writeln;

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

string takeVisualWidth(ref string src, size_t width)
{
    import std.utf: stride, strideBack;

    static
    bool checkAlpha(string s, size_t i, int p = 0)
    {
        import std.ascii: isAlpha;

        if      (0 < p)
        {
            assert (i + p < s.length);
            for (int j = 0; j < p; ++j)
                i += s.stride(i);
        }
        else if (p < 0)
        {
            assert (0 <= i + p);
            for (int j = 0; p < j; --j)
                i -= s.strideBack(i);
        }

        assert(i < s.length);
        return s[i].isAlpha;
    }


    size_t w = 0;
    size_t i = 0;
    for (; i < src.length; )
    {
        auto j = src.stride(i);
        auto t = j == 1 ? 1 : 2;
        if (width < w + t)
        {
            if      (!checkAlpha(src, i) || i < 2 || !checkAlpha(src, i, -1))
                break;
            else if (!checkAlpha(src, i, -2))
            {
                --i;
                break;
            }
            else
            {
                assert (1 < i);
                auto ret = src[0..i-1] ~ '-';
                src = src[i-1 .. $];
                return ret;
            }
        }

        w += t;
        i += j;
    }

    auto ret = src[0..i];
    src = src[i..$];
    return ret;
}

size_t calcVisualWidth(string s)
{
    import std.utf: stride;
    import std.ascii: isASCII;

    size_t w = 0;
    for (size_t i = 0; i < s.length; i += s.stride(i))
        w += s[i].isASCII ? 1 : 2;
    return w;
}

struct Tabular(size_t COL) if (1 < COL)
{
    template TupleN(T, size_t U)
    {
        import std.typecons: Tuple;
        static if      (1 < U)
            alias TupleN = Tuple!(T, TupleN!(T, U-1).Types);
        else static if (1 == U)
            alias TupleN = Tuple!(T);
        else static assert (0);
    }

    struct Column
    {
        enum Justify
        {
            left = "-",
            right = "",
        }

        string title;
        string separator;
        Justify justify;

        this (string title, string separator = "|",
              Justify justify = Justify.left)
        {
            this.title = title;
            this.separator = separator;
            this.justify = justify;
            width = title.calcVisualWidth;
        }

        string fmt(string d) const
        {
            import std.array: join;
            import std.conv: to;
            auto vw = d.calcVisualWidth;
            return ["%", justify, (width - (d.length - vw)).to!string, "s ",
                    separator, " "].join;
        }

        string fmt() const { return fmt(title); }

    private:
        size_t width;
    }

    Column[COL] header;
    string[COL][] data;
    int width;

    this (int width, Column[] header...)
    {
        this.width = width;
        for (size_t i = 0; i < COL; ++i)
        {
            if (i < header.length)
                this.header[i] = header[i];
        }
    }

    void opCall(string[] data...)
    {
        string[COL] d;
        for (size_t i = 0; i < COL; ++i)
        {
            if (i < data.length)
            {
                d[i] = data[i];
                if (header[i].width < data[i].length)
                    header[i].width = data[i].length;
            }
        }
        this.data ~= d;
    }

    string dump()
    {
        import std.algorithm: each, fold;
        import std.range: Appender, iota, repeat, take, join;
        import std.format: format;
        import std.conv: to;
        import std.uni: isAlpha;

        version (linux)
        {
            // is this a bug?
            size_t leftW;
            header[0..$-1].each!(a=>leftW += a.width + 3);
        }
        else
        {
            auto leftW = header[0 .. $-1].fold!((a, b)=>a + b.width + 3)(0u);
        }
        auto rightW = (cast(int)leftW) + 10 < width ? width - leftW : 10;

        Appender!(string[]) app;

        alias OptT = TupleN!(string, COL);
        OptT opt;
        foreach (i, ref one; opt)
            one = header[i].title;

        Appender!(char[]) fmt;

        header[0..$-1].each!(a=>fmt.put(a.fmt));
        fmt.put("%s");
        app.put(fmt.data.format(opt.expand));
        fmt.clear;

        Appender!(string[]) buf;
        foreach (i, one; header)
        {
            if (i < COL-1)
            {
                buf.put('-'.repeat.take(one.width+1).to!string);
                buf.put(one.separator);
                buf.put("-");
            }
        }
        buf.put('-'.repeat.take(rightW).to!string);
        app.put(buf.data.join);

        if (0 < width)
        {
            assert (0 < rightW);

            foreach (one; data)
            {
                foreach (k, ref o; opt[0 .. COL-1])
                {
                    o = one[k];
                    fmt.put(header[k].fmt(o));
                }

                auto line = one[$-1];
                auto frag = line.takeVisualWidth(rightW);
                opt[$-1] = frag;
                fmt.put("%s");
                app.put(fmt.data.format(opt.expand));
                fmt.clear;

                for (; 0 < line.length; )
                {
                    foreach (k, ref o; opt[0 .. COL-1])
                    {
                        o = "";
                        fmt.put(header[k].fmt(""));
                    }
                    frag = line.takeVisualWidth(rightW);
                    opt[$-1] = frag;
                    fmt.put("%s");
                    app.put(fmt.data.format(opt.expand));
                    fmt.clear;
                }

            }
        }
        else
        {
            foreach (one; data)
            {
                foreach (k, ref o; opt)
                {
                    o = one[k];
                    if (k < header.length - 1)
                        fmt.put(header[k].fmt(o));
                    else
                        fmt.put("%s");
                }

                app.put(fmt.data.format(opt.expand));
                fmt.clear;
            }
        }
        return app.data.join("\n");
    }
}



///
// string tabular(string[2][] data, string title1, string title2, int w = -1,
//                string separator = "|")
// {
//     import std.range: repeat;
//     import std.array: Appender, join;
//     import std.conv: to;
//     import std.format: format;
//     import std.ascii: isAlpha;

//     size_t wL = title1.length, wR = 0;
//     foreach (one; data)
//     {
//         if (wL < one[0].length)
//             wL = one[0].length;
//     }

//     if (0 < w && wL + 3 < w)
//         wR = w - wL - 3;
//     else
//         wR = 10;

//     Appender!(string[]) app;
//     auto fmt = ["%-", wL.to!string, "s " , separator, " %s"].join;

//     app.put(fmt.format(title1, title2));
//     app.put(['-'.repeat(wL+1).to!string, separator,
//              '-'.repeat(wR+1).to!string].join);
//     if (0 < w)
//     {
//         assert (0 < wR);

//         foreach (one; data)
//         {
//             for (size_t i = 0; i < one[1].length;)
//             {
//                 string line;
//                 size_t j;
//                 if      (one[1].length <= i + wR)
//                 {
//                     j = one[1].length;
//                     line = one[1][i .. j];
//                 }
//                 else if (one[1][i+wR-1] == ' ')
//                 {
//                     j = i + wR;
//                     line = one[1][i .. j];
//                 }
//                 else if (2 <= i + wR && one[1][i+wR-2] == ' ')
//                 {
//                     j = i + wR - 1;
//                     line = one[1][i .. j];
//                 }
//                 else if (one[1][i+wR] == ' ')
//                 {
//                     j = i + wR + 1;
//                     line = one[1][i .. j - 1];
//                 }
//                 else if (one[1][i+wR-1].isAlpha && one[1][i+wR].isAlpha)
//                 {
//                     j = i + wR - 1;
//                     line = one[1][i .. j] ~ "-";
//                 }
//                 else
//                 {
//                     j = i + wR;
//                     line = one[1][i .. j];
//                 }

//                 app.put(fmt.format(i == 0 ? one[0] : "", line));
//                 i = j;
//             }
//         }
//     }
//     else
//     {
//         foreach (one; data)
//             app.put(fmt.format(one[0], one[1]));
//     }

//     return app.data.join("\n");
// }

