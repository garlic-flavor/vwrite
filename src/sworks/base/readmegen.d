module sworks.base.readmegen;

import std.stdio: File, stdout;

struct MoWrapper
{
    static import sworks.base.mo;
    alias Proc = void delegate(File, string);

    Proc proc;
    this(Proc proc) { this.proc = proc; }

    auto _(OPT...)(string s, OPT opt)
    {
        assert (proc !is null);
        proc(f, sworks.base.mo._(s, opt));
        return this;
    }

    auto opCall(OPT...)(string s, OPT opt)
    {
        import std.format: format;

        static if (0 < OPT.length)
            s = format(s, opt);

        if (proc is null)
            f.write(sworks.base.mo._(s, opt));
        else
            proc(f, s);

        return this;
    }

    void ln() { f.writeln; }

    void basePath(string p) { sworks.base.mo._.basePath(p); }
    void projectName(string p) { sworks.base.mo._.projectName(p); }
    void restoreDefaultPath() { sworks.base.mo._.restoreDefaultPath; }
    bool setlocale(string loc) {return sworks.base.mo._.setlocale(loc);}

    void unsetlocale(){ sworks.base.mo._.unsetlocale; }

static:
    static this()
    {
        f = stdout;
    }

    void openFile(string path)
    {
        closeFile;
        f = File(path, "w");
    }

    void setFileToStd()
    {
        closeFile;
        f = stdout;
    }

    void closeFile()
    {
        if (f != stdout)
            f.close;
    }

    void write(OPT...)(OPT opts)
    {
        f.write(opts);
    }

    void writeln(OPT...)(OPT opts)
    {
        f.writeln(opts);
    }

private:
    File f;
}

///
auto h1()
{
    return MoWrapper((f, s)=>f.writeln("\n# ", s));
}

///
auto h2()
{
    return MoWrapper((f, s)=>f.writeln("\n## ", s));
}

///
auto h3()
{
    return MoWrapper((f, s)=>f.writeln("\n### ", s));
}

///
auto b()
{
    return MoWrapper((f, s)=>f.write("__", s, "__"));
}

///
auto link(lazy MoWrapper mw, string href)
{
    _.write("[");
    auto dummy = mw;
    _.write("](", href, ")");
    return dummy;
}


///
void h1(string s)
{
    _.writeln("\n# ", s);
}

///
void h2(string s)
{
    _.writeln("\n## ", s);
}

///
void h3(string s)
{
    _.writeln("\n### ", s);
}

///
void h4(string s)
{
    _.writeln("\n#### ", s);
}

///
auto b(string s)
{
    _.write("__", s, "__");
    return _;
}

///
auto list(size_t i = 0)
{
    import std.range: repeat, take;
    return MoWrapper((f, s)=>f.writeln(' '.repeat.take(4 * i), "- ", s));
}

auto elist(size_t i = 0)
{
    import std.range: repeat, take;
    return MoWrapper((f, s)=>f.writeln(' '.repeat.take(4 * i), "1. ", s));
}

///
void pre(string s)
{
    _.write("\n    ", s, "\n");
}

///
void putln(string s = "")
{
    _.writeln(s);
}

///
void put(string s = "")
{
    _.write(s);
}

///
void hl()
{
    _.writeln("* * *");
}

///
string exec(string[] args...)
{
    import std.process: execute;
    import std.array: replace;
    import sworks.win32.sjis: fromMBS, j;

    return args.execute.output.j.fromMBS!char.replace("\r\n", "\n");
}

///
auto history(string versionString)
{
    _.writeln("- ", versionString);
    return MoWrapper((f, s)=>f.writeln("    - ", s));
}


///
MoWrapper _;
