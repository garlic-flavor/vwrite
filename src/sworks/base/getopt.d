/** std.getopt 置き替え

Authors: KUMA
License: CC0
*/
module sworks.base.getopt;
import sworks.base.mo;
debug import std.stdio: writeln;

/** コンマンドライン引数を処理する。
 */
struct Getopt
{
static:

    //--------------------------------------------------------------------
    /** 詳細な挙動を制御する為のスイッチ
     */
    enum Config : uint
    {
        caseSensitive = 0x0001,           /// 大文字、小文字を区別する。
        caseInsensitive = ~caseSensitive, ///

        bundling = 0x0002,                /// 一文字のスイッチ引数の省略表現
                                          /// を許可する。
        noBundling = ~bundling,           ///

        passThrough = 0x0004,             /// 処理しない引数は残す。
        noPassThrough = ~passThrough,     ///

        stopOnFirstNonOption = 0x0008,    /// 最初のオプションでない引数で処理を
                                          /// 終了する。
        keepEndOfOptions = 0x0010,        /// '--'を残す。

        appearanceOrder = 0x0020,         /// オプションの登場順に処理する。
        priolityOrder = ~appearanceOrder, ///

        nohelp = 0x0040,                  /// helpWanted を使わない。

        required = 0x1000,                /// 必須オプションである。
        regex = 0x2000,                   /// ユーザー指定の正規表現を使う。
        optionalValue = 0x4000,           /// オプションの引数は省略可能である。
        filePattern = 0x8000,             /// ファイル名にヒットする。
        notInSummary = 0x10000,           /// 要約には表示しない。
    }

    enum Stopper = "--";     ///
    enum ArgsStartFrom = 1;  ///
    enum Key = "key";        ///
    enum Value = "value";    ///
    enum Equal = "equal";    ///

    //--------------------------------------------------------------------
    /** 引数のパーサを格納する。

    opCallの戻り値、Result構造体の主要素として使われる。
     */
    class Option
    {
        import std.regex: Regex;

        alias HelpProc = string delegate();

        /// 引数の説明を得る。
        @property
        string help() { return _help(); }

        @property @safe @nogc pure nothrow
        {
            /// 引数の表示用名前
            string name() const { return _dispName; }
            /// 必須引数の場合にtrue
            bool required() const { return 0 < (_config & Config.required); }
            ///
            bool inSummary() const
            { return 0 == (_config & Config.notInSummary); }
        }

    protected:
        Regex!char reg;

        abstract
        bool opCall (size_t i, ref string[] args);

        @property @safe @nogc pure nothrow
        {
            //
            bool isValueOptional() const
            { return 0 < (_config & Config.optionalValue); }
            //
            bool bundling() const { return 0 < (_config & Config.bundling); }
            //
            Config config() const { return _config; }
        }

    private:
        Config _config;
        string _dispName;
        HelpProc _help;

        this (Config c, string f, string n, HelpProc h)
        {
            import std.regex: regex;

            _config = c;
            _dispName = n;
            _help = h;
            reg = regex(f, (_config & Config.caseSensitive) ? "" : "i");
        }
    }

    //--------------------------------------------------------------------
    /** opCallの戻り値として使われる。
     */
    struct Result
    {
        /// それぞれの引数パーサのヘルプメッセージを参照できる。
        Option[] options;
        bool helpWanted;  /// ヘルプメッセージが要求されている場合、true
        string helpAbout; /// ヘルプに関する追加要求があるか。
    }

    //====================================================================
    /**
     */
    Result opCall(T...)(ref string[] args, T opts)
    {
        import std.algorithm: startsWith;
        import std.array : Appender;
        import std.conv: to;

        Result r;
        Appender!(Option[]) options;
        auto ob = new OptionBuilder;

        if (0 == (ob.config & Config.nohelp))
        {
            ob(Config.caseInsensitive);
            ob(Config.optionalValue);
            ob(Config.notInSummary);
            ob("help|h|\\?");
            ob(_._("Show help messages."));
            options.put(
                ob((string key, string value)
                   { r.helpWanted = true; r.helpAbout = value; }));
        }

        foreach (one; opts)
        {
            if (auto o = ob(one))
                options.put(o);
        }

        if (!ob.empty)
            throw new Exception (
                _("One more target is expected for option '%s'", ob.name));

        r.options = options.data;

        size_t i = ArgsStartFrom;
        if (ob.config & Config.appearanceOrder)
        {
            auto requiredTable = new bool[r.options.length];
            foreach (j, one; r.options)
                requiredTable[j] = !one.required;

        nextargs:
            for (; i < args.length;)
            {
                if (Stopper == args[i])
                    break;

                foreach (j, one; r.options)
                {
                    if (one(i, args))
                    {
                        requiredTable[j] = true;
                        continue nextargs;
                    }
                }

                if      (args.length <= i){}
                else if (ob.stopOnFirstNonOption &&
                         0 == args[i].startsWith("/", "-"))
                    break;
                else if (!ob.passThrough)
                    throw new Exception (
                        _("An unknown option: %s", args[i]));
                else
                    ++i;
            }

            foreach (j, one; requiredTable)
            {
                if (!one)
                    throw new Exception (
                        _("Option '%s' is required.", r.options[j].name));
            }
        }
        else
        {
            foreach (one; r.options)
            {
                bool found = false;
                for (i = ArgsStartFrom; i < args.length;)
                {
                    if      (Stopper == args[i])
                        break;
                    else if (one(i, args))
                        found = true;
                    else
                        ++i;
                }
                if (!found && one.required)
                    throw new Exception (
                        _("Option '%s' is required.", one.name));
            }

            if (ArgsStartFrom < args.length
                && Stopper != args[ArgsStartFrom] && !ob.passThrough)
                throw new Exception (
                    _("An unknown option: %s", args[ArgsStartFrom]));
        }

        if (i < args.length && Stopper == args[i] && !ob.keepEndOfOptions)
            args = args[0..i] ~ args[i+1..$];

        return r;
    }

    string prettyDescriptor(Option[] opts, int w = -1)
    {
        import std.algorithm: filter, fold;
        import std.array: array;
        import sworks.base.strutil: Tabular;

        alias T2 = Tabular!2;
        alias T2C = T2.Column;
        auto t = T2(w, T2C(_("option")), T2C(_("description")));
        foreach (one; opts)
        {
            if (one.inSummary)
                t(one.name, one.help);
        }
        return t.dump;
    }

////////////////////////////////////////////////////////////////////////////////
private:

    //--------------------------------------------------------------------
    enum Mask : Config
    {
        remainder = cast(Config)(Config.required - 1),
        inverse = cast(Config)0x80000000,
    }

    //--------------------------------------------------------------------
    string toFileRegPattern(string shortPattern)
    {
        import std.path: extension;
        import std.array: replace, join;
        import std.range: drop, dropBack;

        auto ext = shortPattern.extension.drop(1);
        auto base = shortPattern.dropBack(ext.length + 1);

        return ["^(?![-/=])(?P<", Key, ">", base.replace("*", ".*"),
                "(?P<", Value, ">(?P<", Equal, ">\\.)",
                ext.replace("*", "[^\\.]+"), "))$"].join;
    }

    //--------------------------------------------------------------------
    class SwitchOption : Option
    {
        alias Proc = void delegate(string);

        //----------------------------------------------------------
        this (Config c, string f, string n, HelpProc h, Proc p)
        {
            import std.algorithm: splitter;
            import std.array: join;

            string filter;
            if      (c & Config.regex)
                filter = f;
            else if (c & Config.filePattern)
                filter = toFileRegPattern(f);
            else if (c & Config.bundling)
            {
                string[] shorts, longs;
                foreach (one; f.splitter("|"))
                {
                    if      (1 == one.length)
                        shorts ~= one;
                    else if (1 < one.length)
                        longs ~= one;
                }
                filter = ["(?<=^--|/)(?:", longs.join("|"), ")$", "|",
                          "(?<=^-(?:[^-].*)?)(?:", shorts.join("|"),
                          ")"].join;
            }
            else
                filter = ["(?<=^--|-|/)(?:", f, ")$"].join;

            super (c, filter, n, h);
            proc = p;
        }

        //----------------------------------------------------------
        override
        bool opCall (size_t i, ref string[] args)
        {
            import std.regex: match;
            import std.algorithm: startsWith;

            auto m = args[i].match (reg);
            if (m.empty)
                return false;

            if (bundling && 1 == m.hit.length)
            {
                if (1 != args[i].startsWith("-", "--"))
                    return false;

                proc (m.hit);
                if (m.pre == "-" && 0 == m.post.length)
                    args = args[0..i] ~ args[i+1..$];
                else
                    args[i] = m.pre ~ m.post;
            }
            else
            {
                proc (m.hit);
                args = args[0..i] ~ args[i+1 .. $];
            }

            return true;
        }

    private:
        Proc proc;
    }

    //--------------------------------------------------------------------
    class ArgOption : Option
    {
        alias Proc = void delegate(string, string);

        //
        this (Config c, string f, string n, HelpProc h, Proc p)
        {
            import std.array: join;

            string filter;
            if      (c & Config.regex)
                filter = f;
            else if (c & Config.filePattern)
                filter = toFileRegPattern(f);
            else
                filter = ["(?<=^--|-|/)(?P<", Key, ">", f,
                          ")(?:(?P<", Equal, ">=)?(?P<", Value,
                          ">.*))?$"].join;

            super (c, filter, n, h);
            _proc = p;
        }

        //
        override
        bool opCall (size_t i, ref string[] args)
        {
            import std.regex: match;
            import std.algorithm: startsWith;

            auto m = args[i].match (reg);
            if (m.empty)
                return false;

            auto value = m.captures[Value];
            if      (0 < value.length || 0 < m.captures[Equal].length)
                args = args[0..i] ~ args[i+1..$];
            else if (i+1 < args.length &&
                     0 == args[i+1].startsWith("/", "-"))
            {
                value = args[i+1];
                args = args[0 .. i] ~ args[i+2 .. $];
            }
            else if (0 == (config & Config.optionalValue))
                throw new Exception (
                    _("option %s needs an argument.", name));
            else
                args = args[0..i] ~ args[i+1..$];

            _proc (m.captures[Key], value);
            return true;
        }

    private:
        Proc _proc;
    }

    //--------------------------------------------------------------------
    class OptionBuilder
    {
        Config config;
        int phase;
        string filter, name;
        Option.HelpProc help;

        @safe @nogc pure nothrow
        this() { reset; }

        @property @safe @nogc pure nothrow
        {
            bool empty() const { return phase == 0; }
            //
            bool stopOnFirstNonOption() const
            { return 0 < (config & Config.stopOnFirstNonOption); }
            //
            bool passThrough() const
            { return 0 < (config & Config.passThrough); }
            //
            bool keepEndOfOptions() const
            { return 0 < (config & Config.keepEndOfOptions); }
        }

        Option opCall(T : Config)(T c)
        {
            if (c & Mask.inverse)
                config &= c;
            else
                config |= c;
            return null;
        }

        Option opCall(T : string)(T s)
        {
            import std.array: replace;
            switch (phase)
            {
            case 0:
                filter = s;
                if (config & (Config.filePattern | Config.regex))
                    name = s;
                else
                    name = "-" ~ s.replace("\\", "").replace("|", " -");
                break;
            case 1:
                help = ()=>s;
                break;
            case 2:
                if (help !is null)
                    name = help();
                help = ()=>s;
                break;
            default:
                assert (0);
            }
            ++phase;
            return null;
        }

        Option opCall(T : Option.HelpProc)(T s)
        {
            if (help !is null)
                name = help();
            help = s;
            ++phase;
            return null;
        }

        Option opCall(T : bool*)(T target)
        {
            ready;
            auto o = new SwitchOption(
                config, filter, name, help,
                (string){ (*target) = true; });
            reset;
            return o;
        }

        import std.traits: isCallable, arity, Parameters;
        Option opCall(T : U*, U)(T target)
            if (!is(U == bool) && !isCallable!T)
        {
            import std.conv: to;

            ready;
            auto o = new ArgOption(
                config, filter, name, help,
                (string, string v){ (*target) = v.to!U; });
            reset;
            return o;
        }

        Option opCall(T)(T target)
            if (isCallable!T && arity!T == 0)
        {
            ready;
            auto o = new SwitchOption(
                config, filter, name, help,
                (string key){ target(); });
            reset;
            return o;
        }

        Option opCall(T)(T target)
            if (isCallable!T && arity!T == 1 && is(Parameters!T[0] == string))
        {
            import std.functional: toDelegate;
            ready;
            auto o = new SwitchOption (
                config, filter, name, help, target.toDelegate);

            reset;
            return o;
        }

        Option opCall(T)(T target)
            if (isCallable!T && arity!T == 2 && is(Parameters!T[0] == string))
        {
            import std.conv: to;

            ready;
            auto o = new ArgOption(
                config, filter, name, help,
                (string k, string v){ target(k, v.to!(Parameters!T[1])); });
            reset;
            return o;
        }

    private:
        @safe @nogc pure nothrow
        void reset()
        {
            phase = 0;
            config &= Mask.remainder;
            filter = name = null;
            help = null;
        }

        void ready() const
        {
            if (0 == phase)
                throw new Exception (_("a selector string is needed."));
        }
    }
}


////////////////////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\\\\\\\\\\\\\\\\\\\\
debug (getopt)
{
    import std.stdio;
    import std.array: join;

    void main()
    {
        string[] args = ["test.exe", "--fuga"];
        bool done;

        alias GC = Getopt.Config;
        auto result = Getopt(
            args,

            GC.regex,
            "^-.*$",
            (string key)
            {
                key.writeln;
            },

            );
    }
}
