/** verifying of D source codes.
 * Version:    0.29(dmd2.069.2)
 * Date:       2015-Dec-14 01:28:22
 * Authors:    KUMA
 * License:    CC0
 **/
module sworks.vwrite.main;

import sworks.base.output;

enum _VERSION_ = "0.29(dmd2.069.2)";
enum _AUTHORS_ = "KUMA";

enum header = "Version Writer ver " ~ _VERSION_ ~ ". written by "
            ~ _AUTHORS_ ~ ".";
enum help= header ~ q"HELP

set version string. and verify white space styles as of DMD-style.

** syntax
$>vwrite OPT [source.d ...]

** Options
--help                : show this help messages.
--version             : show the version of vwrite.
--setversion 00000    : set version as 00000.
--project MY_PROJECT  : set project name as MY_PROJECT.
--authors MY_NAME     : set project's authors as MY_NAME.
--license MY_L        : put your project to under MY_L.

** DMD white space styles.
o tab is not allowed.
o trailing spaces are not allowed.
o newline sequence other than '\n' is not allowed.
HELP";

enum RIGHT_NEWLINE = "\n";
enum RIGHT_INDENTATION = "    ";

enum PROJECT_TAG = "project";
enum VERSION_TAG = "version";
enum DATE_TAG = "date";
enum AUTHORS_TAG = "authors";
enum LICENSE_TAG = "license";
enum DOC_FORMAT = "%-12s%s";

template DocMatchRegex(string TAG)
{
    import std.regex : ctRegex;
    import std.string : capitalize;
    enum DocMatchRegex = ctRegex!(r"(?<=^[\s\*\+]*)" ~ TAG.capitalize
                                  ~ ":[^\n]*$", "gim");
}

template EnumMatchRegex(string NAME)
{
    import std.regex : ctRegex;
    import std.string : toUpper;
    enum EnumMatchRegex = ctRegex!(r"(?<=^\s*)enum\s+_" ~ NAME.toUpper
                                   ~ r"_\b.*$", "gm");
}

auto docString(string tag, string name)
{
    import std.array : appender;
    import std.format : formattedWrite;
    import std.string : capitalize;
    auto buf = "".appender;
    buf.formattedWrite(DOC_FORMAT, tag.capitalize ~ ":", name);
    return buf.data;
}

auto enumString(string name, string val)
{
    import std.string : join, toUpper;
    return ["enum _", name.toUpper, "_ = \"", val, "\";"].join;
}

//
void main(string[] args)
{

    try
    {
        import std.getopt : getopt, config, optionChar;

        // ヘルプが必要かどうか。
        if (args.length <= 1) return help.outln;

        bool needs_help = false;
        optionChar = '/';
        getopt( args
              , config.caseInsensitive
              , config.passThrough
              , "help|h|?", &needs_help );
        if (needs_help) return help.outln;

        bool show_version = false;
        optionChar = '-';
        getopt( args
              , config.caseInsensitive
              , config.passThrough
              , "help|h|?", &needs_help
              , "version", &show_version );
        if      (needs_help) return help.outln;
        else if (show_version) return header.outln;

        // 冗長性の決定
        bool is_verbose = false;
        getopt( args
              , config.caseInsensitive
              , config.passThrough
              , "verbose", &is_verbose );
        if (is_verbose) Output.mode = Output.MODE.VERBOSE;

        // プロジェクト名、ヴァージョン名、著者、ライセンスの取得
        import std.array : Appender;
        import std.format : formattedWrite;
        string projectName, versionName, licenseName, authorsName;
        getopt( args
              , config.caseInsensitive
              , "p|project", &projectName
              , "v|setversion", &versionName
              , "l|license", &licenseName
              , "a|authors", &authorsName );

        // 正規表現の準備
        import std.regex : ctRegex, replaceAll;
        alias CRLF_MATCH = ctRegex!(r"\r\n", "gs");
        alias CR_MATCH = ctRegex!(r"\r", "gs");
        alias TAB_MATCH = ctRegex!(r"\t", "g");
        alias TRAIL_SPACES_MATCH = ctRegex!(r"[ \t]+(?=\n)", "gs");

        alias PROJECT_MATCH = DocMatchRegex!PROJECT_TAG;
        alias PROJECT_MATCH2 = EnumMatchRegex!PROJECT_TAG;
        alias VERSION_MATCH = DocMatchRegex!VERSION_TAG;
        alias VERSION_MATCH2 = EnumMatchRegex!VERSION_TAG;
        alias DATE_MATCH = DocMatchRegex!DATE_TAG;
        alias AUTHORS_MATCH = DocMatchRegex!AUTHORS_TAG;
        alias AUTHORS_MATCH2 = EnumMatchRegex!AUTHORS_TAG;
        alias LICENSE_MATCH = DocMatchRegex!LICENSE_TAG;
        alias LICENSE_MATCH2 = EnumMatchRegex!LICENSE_TAG;

        // 処理本体
        import std.path : extension;
        import std.datetime : SysTime, Clock;
        import std.file : exists, getTimes, setTimes, read, write;
        import std.conv : to;
        import std.functional : binaryReverseArgs;
        foreach(one; args) // 全ての引数に対して。
        {
            auto ext = one.extension; // 拡張子でD言語のだけ選ぶ。
            if (ext != ".d" && ext != ".di")
            {
                logln(one ~ " is not a D source.");
                continue;
            }

            if (!one.exists) // 存在しないのははぶく。
            {
                outln(one, " is not found.");
                continue;
            }

            logln("start with ", one);
            Output.incIndent;

            SysTime aTime, mTime;
            one.getTimes(aTime, mTime);
            logln("last access time : ", aTime);
            logln("last modified time : ", mTime);

            // 変換本体
            one.read.to!string
                .replaceAll(CRLF_MATCH, RIGHT_NEWLINE)
                .replaceAll(CR_MATCH, RIGHT_NEWLINE)
                .replaceAll(TAB_MATCH, RIGHT_INDENTATION)
                .replaceAll(TRAIL_SPACES_MATCH, "")

                .replaceAll( PROJECT_MATCH
                           , PROJECT_TAG.docString(projectName) )
                .replaceAll( PROJECT_MATCH2
                           , PROJECT_TAG.enumString(projectName) )
                .replaceAll( VERSION_MATCH
                           , VERSION_TAG.docString(versionName) )
                .replaceAll( VERSION_MATCH2
                           , VERSION_TAG.enumString(versionName) )
                .replaceAll(DATE_MATCH, DATE_TAG.docString(mTime.toString))
                .replaceAll( AUTHORS_MATCH
                           , AUTHORS_TAG.docString(authorsName) )
                .replaceAll( AUTHORS_MATCH2
                           , AUTHORS_TAG.enumString(authorsName) )
                .replaceAll( LICENSE_MATCH
                           , LICENSE_TAG.docString(licenseName) )
                .replaceAll( LICENSE_MATCH2
                           , LICENSE_TAG.enumString(licenseName) )

                .binaryReverseArgs!write(one);

            // 編集時間を戻す。
            one.setTimes(Clock.currTime, mTime);

            logln("done.");
            Output.decIndent;
        }
    }
    catch (Throwable t) t.toString.errorOut;
}
