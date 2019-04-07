/** VWRITE - Version WRITEr -
Version:    0.35(dmd2.085.0)
Date:       2019-Apr-01 16:42:32
Authors:    KUMA
License:    CC0
**/
module sworks.vwrite.main;

import sworks.base.output;
import sworks.base.mo;
import sworks.base.getopt;
debug import std.stdio : writeln;

enum _VERSION_ = "0.35(dmd2.085.0)";

enum header = "Version Writer ver " ~ _VERSION_ ~ ". written by KUMA.";

string description()
{
    return _("This program appends some informations to your D source files. And modify your coding style. Expected character coding of the source code is UTF-8(non-BOM) only.");
}

enum how_to_use =
    ">vwrite -v VERSION.OF.YOUR.PROJECT code.d code2.d ...";

enum RIGHT_NEWLINE = "\n";
enum RIGHT_INDENTATION = "    ";

enum VERSION_TAG = "version";
enum DMD_TAG = "dmd";
enum DMD_VERSION_TAG = "DMD_VERSION";
enum DATE_TAG = "date";
enum DOC_FORMAT = "%-12s%s";

template DocMatchRegex(string TAG)
{
    import std.regex : ctRegex;
    import std.string : capitalize;
    enum DocMatchRegex = ctRegex!(r"(?<=^[\s\*\+]*)" ~ TAG.capitalize ~
                                  r"\s*:[^\n]*$", "gim");
}

template DocMacroMatchRegex(string TAG)
{
    import std.regex : ctRegex;
    import std.string : capitalize;
    enum DocMacroMatchRegex = ctRegex!(r"(?<=^[\s\*\+]*)" ~ TAG.capitalize ~
                                       r"\s*=[^\n]*$", "gim");
}


template EnumMatchRegex(string NAME)
{
    import std.regex : ctRegex;
    import std.string : toUpper;
    enum EnumMatchRegex = ctRegex!(r"(?<=^\s*)enum\s+_" ~ NAME.toUpper ~
                                   r"_\b.*$", "gm");
}

//
void main(string[] args)
{
    // import std.getopt : getopt, config, optionChar;
    import std.array : Appender, join;
    import std.process: environment;
    alias L = MoUtil.ExpandMode.Lazily;

    try
    {
        _.projectName = "vwrite";
        _.setlocale(environment.get("LANG", "en"));

        string versionString;
        Appender!(string[]) files;
        auto result = Getopt(
            args,

            "lang", "-lang **", _("Specify the language.", L),
            (string key, string lang){ _.setlocale(lang); },

            "verbose", _("Set output policy as 'VERBOSE'.", L),
            (){ Output.mode = Output.MODE.VERBOSE; },

            "quiet|q", _("Set output policy as 'quiet'.", L),
            (){ Output.mode = Output.MODE.QUIET; },

            "setversion|version|v", _("Set a version string of your project.", L),
            &versionString,

            Getopt.Config.filePattern,
            "*.di?", "*.d", _("D source files.", L),
            &files.put!string,
            );

        // 引数が足りない場合はヘルプを表示する。
        if (0 == versionString.length || 0 == files.data.length)
            result.helpWanted = true;

        // ヘルプが要求されている場合はここで終り。
        if (result.helpWanted)
            return showHelp(result.helpAbout, result.options);

        // dmd のヴァージョンの追加 X.XX -> X.XX(dmdY.YYY.Y)
        auto dmdVersion = getDmdVersion;
        versionString = [versionString, "(dmd", dmdVersion, ")"].join;

        // 正規表現の準備
        import std.regex : ctRegex, replaceAll;
        alias CRLF_MATCH = ctRegex!(r"\r\n", "gs");
        alias CR_MATCH = ctRegex!(r"\r", "gs");
        alias TAB_MATCH = ctRegex!(r"\t", "g");
        alias TRAIL_SPACES_MATCH = ctRegex!(r"[\t]+(?=\n)", "gs");

        alias VERSION_MATCH = DocMatchRegex!VERSION_TAG;
        alias VERSION_MATCH2 = EnumMatchRegex!VERSION_TAG;
        alias DMD_MATCH = DocMatchRegex!DMD_TAG;
        alias DMD_MATCH2 = EnumMatchRegex!DMD_TAG;
        alias DMD_MATCH3 = DocMacroMatchRegex!DMD_VERSION_TAG;
        alias DATE_MATCH = DocMatchRegex!DATE_TAG;
        alias DATE_MATCH2 = EnumMatchRegex!DATE_TAG;

        alias IF_STYLE_MATCH =
            ctRegex!(r"\b(if|for|foreach|version|catch|with)\(", "g");

        // 処理本体
        import std.path : extension;
        import std.datetime : SysTime, Clock, DateTime;
        import std.file : exists, getTimes, setTimes, read, write;
        import std.conv : to;
        import std.functional : reverseArgs;

        foreach (one; files.data)
        {
            if (!one.exists) // 存在しないのははぶく。
            {
                _("%s is not found.", one).outln;
                continue;
            }

            _("start a process about %s.", one).logln;
            Output.incIndent;

            SysTime aTime, mTime;
            one.getTimes(aTime, mTime);
            auto modifTime =
                DateTime(mTime.year, mTime.month, mTime.day,
                         mTime.hour, mTime.minute, mTime.second).toString;

            _("last access time: %s", aTime).logln;
            _("last modified time: %s", mTime).logln;

            // 変換本体
            one.read.to!string
                .replaceAll(CRLF_MATCH, RIGHT_NEWLINE)
                .replaceAll(CR_MATCH, RIGHT_NEWLINE)
                .replaceAll(TAB_MATCH, RIGHT_INDENTATION)
                .replaceAll(TRAIL_SPACES_MATCH, "")

                .replaceAll(VERSION_MATCH,
                            VERSION_TAG.docString(versionString))
                .replaceAll(VERSION_MATCH2,
                            VERSION_TAG.enumString(versionString))
                .replaceAll(DMD_MATCH,
                            DMD_TAG.docString(dmdVersion))
                .replaceAll(DMD_MATCH2,
                            DMD_TAG.enumString(dmdVersion))
                .replaceAll(DMD_MATCH3,
                            DMD_VERSION_TAG.docMacroString(dmdVersion))
                .replaceAll(DATE_MATCH, DATE_TAG.docString(modifTime))
                .replaceAll(DATE_MATCH2, DATE_TAG.enumString(modifTime))

                .replaceAll(IF_STYLE_MATCH, "$1 (")

                .reverseArgs!write(one);

            // 編集時間を戻す。
            one.setTimes(Clock.currTime, mTime);

            Output.decIndent;
            _("done.").logln;
        }
    }
    catch (Throwable t) t.toString.errorOut;
}

////////////////////////////////////////////////////////////////////////////////

auto docString(string tag, string name)
{
    import std.array : appender;
    import std.format : formattedWrite;
    import std.string : capitalize;
    auto buf = "".appender;
    buf.formattedWrite(DOC_FORMAT, tag.capitalize ~ ":", name);
    return buf.data;
}

auto docMacroString(string tag, string name)
{
    import std.array : join;
    return [tag, " = ", name, ].join;
}

auto enumString(string name, string val)
{
    import std.string : join, toUpper;
    return ["enum _", name.toUpper, "_ = \"", val, "\";"].join;
}

// Shellからdmdを起動して dmd のヴァージョンを調べて追加する。
auto getDmdVersion()
{
    import std.regex : ctRegex, match;
    import std.process : executeShell;

    auto result = "dmd --version".executeShell;
    if (0 != result.status) return "unknown";

    auto m = result.output.match(ctRegex!(r"v([\d\.]+)"));
    if (m.empty) return "unknown";

    auto cap = m.front;
    if (cap.length < 1) return "unknown";

    return cap[1].idup;
}


void showHelp(string about, Getopt.Option[] opts)
{
    switch (about)
    {
    case "description":
        description.outln;
        break;
    case "how_to_use":
        how_to_use.outln;
        break;
    case "options":
        Getopt.prettyDescriptor(opts).outln;
        break;
    default:
        header.outln;
        description.outln;
        outln;
        how_to_use.outln;
        outln;
        Getopt.prettyDescriptor(opts, 80).outln;
        break;
    }
}

