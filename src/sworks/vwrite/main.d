/** verifying of D source codes.
 * Version:    0.30(dmd2.069.2)
 * Date:       2015-Dec-14 16:17:17
 * Authors:    KUMA
 * License:    CC0
 **/
module sworks.vwrite.main;

import sworks.base.output;

enum _VERSION_ = "0.30(dmd2.069.2)";
enum _AUTHORS_ = "KUMA";

enum header = "Version Writer ver " ~ _VERSION_ ~ ". written by "
            ~ _AUTHORS_ ~ ".";

version(InJapanese)
{
    enum help = header ~ r"

D言語のソースコードにヴァージョン情報を付加します。
空白文字に関する慣習をDMD準拠のものにします。

** 構文
$>vwrite OPT [source.d ...]

** Options
--help                : この説明文を表示します。
--version             : vwrite のヴァージョン情報を表示します。

--authors MY_NAME     : 処理対象プロジェクトの著者情報を設定します。
--license MY_L        : プロジェクトの権利条項を設定します。
--project MY_PROJECT  : プロジェクト名を設定します。
--setversion 00000    : プロジェクトのヴァージョン情報を設定します。

** DMD の空白文字規則では、
o タブ文字は使用できません。
o 行末に空白文字を使用できません。
o '\n'以外の改行文字を使用できません。
";
}
else
{
    enum help = header ~ q"HELP

Set version strings to your project.
And verify white space styles as of DMD style.

** syntax
$>vwrite OPT [source.d ...]

** Options
--help                : show this help messages.
--version             : show the version of vwrite.

--authors MY_NAME     : set project's authors as MY_NAME.
--license MY_L        : put your project to under MY_L.
--project MY_PROJECT  : set project name as MY_PROJECT.
--setversion XXX.x    : set your project's version as XXX.x.

** DMD white space styles.
o tab is not allowed.
o trailing spaces are not allowed.
o newline sequence other than '\n' is not allowed.
HELP";
}

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
                version(InJapanese)
                    logln(one, " はD言語のソースコードではありません。");
                else
                    logln(one, " is not a D source.");
                continue;
            }

            if (!one.exists) // 存在しないのははぶく。
            {
                version(InJapanese)
                    logln(one, " は存在しません。");
                else
                    outln(one, " is not found.");
                continue;
            }

            version(InJapanese)
                logln(one, " の処理を開始します。");
            else
                logln("start the process about ", one);
            Output.incIndent;

            SysTime aTime, mTime;
            one.getTimes(aTime, mTime);
            version(InJapanese)
            {
                logln("最終読み取り時刻 : ", aTime);
                logln("最終編集時刻     : ", mTime);
            }
            else
            {
                logln("last access time   : ", aTime);
                logln("last modified time : ", mTime);
            }

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

            version(InJapanese)
                logln("終了。");
            else
                logln("done.");
            Output.decIndent;
        }
    }
    catch (Throwable t) t.toString.errorOut;
}
