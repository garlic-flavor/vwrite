/** コンソールへの出力を制御する。
 * Dmd:        2.085.1
 * Date:       2019-Apr-11 01:14:39
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.base.output;

debug import std.stdio: writeln;

version (Windows) private import sworks.win32.sjis;

/// エラー出力
void errorOutln(T ...)(lazy T msg) { Output.errorln(msg); }

void errorOut(T ...)(lazy T msg) { Output.error(msg); }

/// ログの出力。冗長度が MODE.VERBOSE の時のみ出力される。
void logln(T ...)(lazy T msg) { Output.logln(msg); }
void log(T ...)(lazy T msg) { Output.log(msg); }

/// 現在の冗長度に関係なく debug コンパイル時のみ出力される。
void debln(T ...)(lazy T msg) { Output.debln(msg); }
void deb(T ...)(lazy T msg) {Output.deb(msg);}

/// 現在の冗長度に関係なく必ず出力される。
void output(T ...)(lazy T msg) {Output(msg);}
void outln(T...)(lazy T msg) {Output.ln(msg);}


/// コンソールへの出力を制御する.
struct Output
{ static:
    import std.stdio : stderr, stdout;

    /// 冗長度を示す
    enum MODE : ubyte
    {
        QUIET = 0,
        ERROR = 1, // release コンパイル時の初期値
        LOG = 2,
        VERBOSE = 3, // debug コンパイル時の初期値
    }

    enum TAB_WIDTH = 4; // インデントの幅

@trusted:

    void open(string filename, string mode = "w")
    {
        _file = File(filename, mode);
    }

    void close()
    { if (_file !is stdout && _file !is stderr) _file.close; _file = stderr; }

    nothrow
    static this(){ _file = stdout; }
    static ~this() { close(); }

    @property @nogc nothrow
    MODE mode() { return _mode; }
    @property @nogc nothrow
    void mode(MODE m) { debug {} else _mode = m; }
    @property @nogc nothrow
    int indent() { return cast(int)_current_indent.length; }
    @property nothrow
    void indent(int i)
    {
        import std.array;
        import std.range : repeat, take;
        _current_indent = ' '.repeat.take(i * TAB_WIDTH).array;
    }
    nothrow
    void incIndent()
    {
        import std.array;
        import std.range : repeat, take;
        _current_indent ~= ' '.repeat.take(TAB_WIDTH).array;
    }
    @nogc nothrow
    void decIndent()
    {
        if (TAB_WIDTH <= _current_indent.length)
            _current_indent = _current_indent[0..$-TAB_WIDTH];
        else
            _current_indent = null;
    }

    /// エラー出力
    void errorln(T ...)(lazy T msg)
    {
        if (_mode & MODE.ERROR) { _out(msg); _outln(); }
    }

    void error(T ...)(lazy T msg)
    {
        if (_mode & MODE.ERROR) { _out(msg); }
    }

    /// ログの出力。冗長度が MODE.VERBOSE の時のみ出力される。
    void logln(T ...)(lazy T msg)
    {
        if (_mode & MODE.LOG) { _out(msg); _outln(); }
    }
    void log(T ...)(lazy T msg)
    {
        if (_mode & MODE.LOG) { _out(msg); }
    }

    /// 現在の冗長度に関係なく debug コンパイル時のみ出力される。
    void debln(T ...)(lazy T msg)
    {
        debug { _out(msg); _outln(); }
    }
    void deb(T ...)(lazy T msg)
    {
        debug { _out(msg); }
    }

    /// 現在の冗長度に関係なく必ず出力される。
    void opCall(T ...)(lazy T msg)
    {
        _out(msg);
    }

    void ln(T...)(lazy T msg)
    {
        _out(msg);
        _outln();
    }

    size_t getTerminalWidth()
    {
        version      (Windows)
        {
            import core.sys.windows.windows;
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo (GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
            return csbi.srWindow.Right - csbi.srWindow.Left + 1;
        }
        else version (linux)
        {
            import core.sys.posix.sys.ioctl;
            import core.sys.posix.unistd;

            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return w.ws_row;
        }
        else
            static assert (0, "NO IMPLEMENTATION! SORRY!");
    }

private:
    import std.stdio : File;
    File _file; // ログファイル

    debug MODE _mode = MODE.VERBOSE; // 現在の冗長度
    else MODE _mode = MODE.ERROR;

    string _current_indent;
    bool _is_newline = true;

    void _outln()
    {
        _file.writeln;
        _is_newline = true;
    }

    void _out(T ...)(T msg)
    {
        import std.conv : to;
        import std.array : replace;

        _file.write(_current_indent);
        auto temp = "\n" ~ _current_indent;
        if (_file !is stdout && _file !is stderr)
        {
            foreach (one ; msg)
                _file.write(one.to!string.replace("\n", temp));
        }
        else
        {
            version (Windows)
            {
                foreach (one ; msg)
                    _file.write(one.toMBS.c.replace("\n", temp));
            }
            else
                foreach (one ; msg)
                    _file.write(one.to!string.replace("\n", temp));
        }
    }
}

//##############################################################################
debug(output):
import std.stdio;
void main()
{
    string func(){ writeln("func are called."); return "func"; }
    Output.incIndent;
    Output.ln(10, 20, "hello", "world", func, "日本語");
}
