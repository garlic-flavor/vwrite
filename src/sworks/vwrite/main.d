/** VWRITE - Version WRITEr -
Version:    0.33(dmd2.070.0)
Date:       2016-Feb-21 20:41:29
Authors:    KUMA
License:    CC0

Description:
This program appends some informations to your D source codes.
and modify your coding style.
Expected character coding of the source code is UTF-8(non-BOM) only.

Notice:
$(B THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO
THE RULE OF DMD!)

White_spacing_rule_of_DMD:
$(UL
$(LI `'\t'`(tab character) is not allowed.)
$(LI trailing spaces are not allowed.)
$(LI Newline sequence other than `'\n'`(unix style) is not allowed.)
)

How_to_build:
$(DL
$(DT On Windows)
$(DD Please use the make tool that is distributed with dmd.)
$(DT 32bit Windows)
$(DD $(PROMPT make -f win.mak release))
$(DT 64bit Windows)
$(DD $(PROMPT make -f win.mak release FLAG=-m64))
$(DT On linux)
$(DD $(PROMPT make -f linux64.mak release))
)

How_to_use:
$(PROMPT vwrite [OPT...] source.d[...])

$(DL $(DT Options)
$(DD $(TABLE
$(TR $(TH option)              $(SEP) $(TH description))
                    $(COL)$(SEP)$(COL)
$(TR $(TD -h --help -? /?)     $(SEP) $(TD show help messages and exit.))
$(TR $(TD --version)           $(SEP) $(TD show the version of vwrite.))
$(TR                     $(SEP))
$(TR $(TD --authors YOU)       $(SEP) $(TD set the project's author as YOU.))
$(TR $(TD --license LICENSE)   $(SEP) $(TD  put your project to under LICENSE.))
$(TR $(TD --project MYPROJECT) $(SEP) $(TD set your project's name as MYPROJECT))
$(TR $(TD --setversion XXX.x)  $(SEP) $(TD set your project's version string as XXX.x.)))))

What_will_this_program_do:

this program will do,

$(OL
$(OLI read informations about your project from command line arguments.
$(OL
    $(OLI `'--project MYPROJECT'` gives the name of the project.)
    $(OLI `'--setversion XXX.x'` gives the description of the version.)
    $(OLI `'--authors YOU'` gives names of authors.)
    $(OLI `'--license LICENSE'` gives an information about the license.)
))

$(OLI read file names from arguments. and select files that
      have `'.d'` or `'.di'` extension.)

$(OLI read each files and do replacement accroding to the manners below.
$(OL
    $(OLI replace `'\r\n'` with `'\n'`.)
    $(OLI replace `'\r'` with `'\n'`.)
    $(OLI replace `'\t'` with `'    '`(four sequential spaces).)
    $(OLI remove tailing spaces.)
    $(OLI replace `'Project:'` with `'Project: MYPROJECT'`.)
    $(OLI replace `'enum _PROJECT_ ="";'` with `'enum _PROJECT_="MYPROJECT"`.)
    $(OLI replace `'Version:'` with `'Version: XXX.x(dmdY.YYY.Y)'`.)
    $(OLI replace `'enum _VERSION_ = "";'` with
          `'enum _VERSION_="XXX.x(dmdY.YYY.Y)"`.)
    $(OLI replace `'Date:'` with `'Date: YYYY-MON-DD HH:MM:SS'`.)
    $(OLI replace `'Authors:'` with `'Authors: YOU'`.)
    $(OLI replace `'enum _AUTHORS_ = "";'` with `'enum _AUTHORS_ = "YOU";'`.)
    $(OLI replace `'License:'` with `'License: LICENSE'`.)
    $(OLI replace `'enum _LICENSE_ = "";'` with
          `'enum _LICENSE_ = "LICENSE";'`.)
    $(OLI replace `'if$(OPEN)'` with `'if $(OPEN)'`.)
    $(OLI replace `'for$(OPEN)'` with `'for $(OPEN)'`.)
    $(OLI replace `'foreach$(OPEN)'` with `'foreach $(OPEN)'`.)
    $(OLI replace `'version$(OPEN)'` with `'version $(OPEN)'`.)
    $(OLI replace `'catch$(OPEN)'` with `'catch $(OPEN)'`.)
))

$(OLI output to the file.)
$(OLI rewind the modified time of the file.)
)

Acknowledgements:
$(UL
$(LI vwrite is written by D Programming Language.
  $(LINK2 http://dlang.org/, Digital Mars D Programming Language)
))

Development_Environment:
$(UL
$(LI Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars))
$(LI Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1)
)

License_description:
$(LINK2 http://creativecommons.org/publicdomain/zero/1.0/, Creative Commons Zero License)

History:
$(UL
$(LI 2016-02-22 ver. 0.33(dmd2.070.0)
  README.md and the commandline help message are generated automatically
  by ddoc.
  add 'Dmd:', ddoc section.)

$(LI 2016-01-29 ver. 0.32(dmd2.070.0)
  The version information of dmd is added to the user specified string
  automatically.)

$(LI 2015-12-16 ver. 0.31(dmd2.069.2)
  add replacing rule for `'if $(OPEN)'`, `'for $(OPEN)'`,
  `'foreach $(OPEN)'`,
  `'version $(OPEN)'`, `'catch $(OPEN)'`.)

$(LI 2015 12/14 ver. 0.30(dmd2.069.2)
  add japanese messages.)

$(LI 2015 12/13 ver. 0.29(dmd2.069.2)
  fully brush up.
$(UL
    $(LI delete v-style.xml.)
    $(LI use command line argument for all settings.)
    $(LI delete -target.)
    $(LI add checking process of white spacing style.)
    $(LI add English README.md.)
)))

$(HL)

はじめにお読み下さい:
これは D言語で書かれたソースコードにヴァージョン情報を付加するプログラムです。
ソースコードに使える文字コードは UTF-8(non-BOM) のみです。


注意:
$(B このプログラムは対象ソースコードの改行コードとインデント文字を変更します!)

DMDルール:
$(UL
$(LI `'\t'`(タブ文字)を使わない。)
$(LI 行末の空白文字はだめ。)
$(LI 改行コードは`'\n'`のみ。)
)

ビルド方法:
$(DL
$(DT Windowsでは)
$(DD DMDに付属のmakeを使ってください。)
$(DT 32bit版では)
$(DD $(PROMPT make -f win.mak release FLAG=-version=InJapanese))
$(DT 64bit版では)
$(DD $(PROMPT make -f win.mak release FLAG="-version=InJapanese -m64"))
$(DT linuxでは)
$(DD $(PROMPT make -f linux64.mak release FLAG=-version=InJapanese))
)

使い方:
コマンドラインから使います。
$(PROMPT vwrite --setversion=x.x source.d [...])

$(DL $(DT オプション)
$(DD $(TABLE
$(TR $(TH 引数)                $(SEP)$(TH 説明))
                    $(COL)$(SEP)$(COL)
$(TR $(TD -h --help -? /?)     $(SEP)$(TD ヘルプメッセージを出力します。))
$(TR                     $(SEP))
$(TR $(TD --authors 名無し)    $(SEP)$(TD プロジェクトの著者を'名無し'とします。))
$(TR $(TD --license NYSL)      $(SEP)$(TD プロジェクトのライセンスを'NYSL'とします。))
$(TR $(TD --project MYPROJECT) $(SEP)$(TD プロジェクト名を'MYPROJECT'とします。))
$(TR $(TD --setversion XXX.x)  $(SEP)$(TD ヴァージョン文字列を指定します。))
$(TR $(TD --version)           $(SEP)$(TD vwrite のヴァージョン情報を表示します。)))))

このプログラムは何をしますか:
このプログラムは、

$(OL
$(OLI コマンドライン引数より、プロジェクトに関する以下の情報を得ます。
$(OL
    $(OLI `--project MYPROJECT` プロジェクトの名前を指定します。)
    $(OLI `--setversion XXX.x` ヴァージョン情報を指定します。)
    $(OLI `--authors YOU` 著者名を指定します。)
    $(OLI `--license LICENSE` ライセンス情報を指定します。)
))

$(OLI コマンドライン引数より拡張子が`'.d'`又は`'.di'`のファイル名のものを選びます。)

$(OLI それぞれのファイルに対して以下の置換を行います。
$(OL
    $(OLI `'\r\n'` を `'\n'` に)
    $(OLI `'\r'` を `'\n'`に)
    $(OLI `'\t'` を `'    '`(スペース4個)に)
    $(OLI 行末の空白文字の消去)
    $(OLI `'Project:'` を `'Project: MYPROJECT'`に)
    $(OLI `'enum _PROJECT_ ="";'` を `'enum _PROJECT_="MYPROJECT"`に)
    $(OLI `'Version:'` を `'Version: XXX.x'`に)
    $(OLI `'enum _VERSION_ = "";'` を `'enum _VERSION_="XXX.x(dmdY.YYY.Y)"`に)
    $(OLI `'Date:\'` を `'Date: YYYY-MON-DD HH:MM:SS'`に)
    $(OLI `'Authors:'` を `'Authors: YOU'`に)
    $(OLI `'enum _AUTHORS_ = "";'` を `'enum _AUTHORS_ = "YOU";'`に)
    $(OLI `'License:'` を `'License: LICENSE'`に)
    $(OLI `'enum _LICENSE_ = "";'` を `'enum _LICENSE_ = "LICENSE";'`に)
    $(OLI `'if$(OPEN)'` を `'if $(OPEN)'`に)
    $(OLI `'for$(OPEN)'` を `'for $(OPEN)'`に)
    $(OLI `'foreach$(OPEN)'` を `'foreach $(OPEN)'`に)
    $(OLI `'version$(OPEN)'` を `'version $(OPEN)'`に)
    $(OLI `'catch$(OPEN)'` を `'catch $(OPEN)'`に)
))

$(OLI 同じファイルに出力します。)
$(OLI ファイルの最終編集時刻を書き戻します。)
)

謝辞:
$(UL
$(LI vwrite は D言語で書かれています。
  $(LINK2 http://dlang.org/, Digital Mars D Programming Language)
))

開発環境:
$(UL
$(LI Windows Vista(x64) x dmd 2.070.0 x (Digital Marsの)make)
$(LI Ubuntu 15.10(amd64) x dmd 2.069.2 x gcc 5.2.1)
)

ライセンス:
$(LINK2 http://creativecommons.org/publicdomain/zero/1.0/, Creative Commons Zero License)

履歴:
$(UL
$(LI 2016-02-22 ver. 0.33(dmd2.070.0)
  README.md と コマンドラインヘルプメッセージはddocで生成するようになりました。
  Dmd: の見出しに対してdmdのヴァージョン情報を出力します。)

$(LI 2016-01-29 ver. 0.32(dmd2.070.0)
  dmdのヴァージョン情報は自動的に付加されるようになりました。)

$(LI 2015-12-16 ver. 0.31(dmd2.069.2)
  `'if $(OPEN)'`, `'for $(OPEN)'`, `'foreach $(OPEN)'`, `'version $(OPEN)'`,
  `'catch $(OPEN)'` に関する変換を追加。)

$(LI 2015 12/14 ver. 0.30(dmd2.069.2)
  日本語メッセージの追加。)

$(LI 2015 12/13 ver. 0.29(dmd2.069.2)
  全面刷新。
$(UL
    $(LI v-style.xml の廃止)
    $(LI 情報はコマンドライン引数で指定するように。)
    $(LI -target の廃止)
    $(LI 空白文字に関する慣習をDMD準拠に。)
    $(LI 英語版 README.md の追加。)
))

$(LI 2013 03/02 ver. 0.28(dmd2.062)
  linuxで v-style.xml を探せないバグの修正。)

$(LI 2012 10/28 ver. 0.27(dmd2.060)
  -target で指定したファイルより新しいもののみ更新するように変更しました。)

$(LI 2012 10/27 ver. 0.26(dmd2.060)
  GitHub デビュー)

$(LI 2012  2/21  ver. 0.24 for dmd2.058
  some bugs are fixed.)

$(LI 2010  3/14  ver. 0.22
  for dmd2.041. but no change occur.)

$(LI 2009 10/20  ver. 0.21
  for dmd2.035.)

$(LI 2009  9/ 1  ver. 0.1
  First released version.)
)

**/
module sworks.vwrite.main;

import sworks.base.output;
debug import std.stdio : writeln;

enum _VERSION_ = "0.33(dmd2.070.0)";
enum _AUTHORS_ = "KUMA";

enum header = "Version Writer ver " ~ _VERSION_ ~ ". written by " ~
              _AUTHORS_ ~ ".";

version (D_Ddoc){ enum help = ""; }
else
{
    enum string[string] helpdoc = mixin(import("help.d"));

    version (InJapanese)
    {
        enum help = header ~
            "\nD言語のソースコードにヴァージョン情報を付加します。\n"
            "空白文字に関する慣習をDMD準拠のものにします。\n" ~
            helpdoc["使い方:"] ~
            helpdoc["DMDルール:"];
    }
    else
    {
        enum help = header ~
            "\nSet version strings to your project.\n"
            "And verify white space styles as of DMD style.\n" ~
            helpdoc["How to use:"] ~
            helpdoc["White spacing rule of DMD:"];
    }
}
enum RIGHT_NEWLINE = "\n";
enum RIGHT_INDENTATION = "    ";

enum PROJECT_TAG = "project";
enum VERSION_TAG = "version";
enum DMD_TAG = "dmd";
enum DATE_TAG = "date";
enum AUTHORS_TAG = "authors";
enum LICENSE_TAG = "license";
enum DOC_FORMAT = "%-12s%s";

template DocMatchRegex(string TAG)
{
    import std.regex : ctRegex;
    import std.string : capitalize;
    enum DocMatchRegex = ctRegex!(r"(?<=^[\s\*\+]*)" ~ TAG.capitalize ~
                                  ":[^\n]*$", "gim");
}

template EnumMatchRegex(string NAME)
{
    import std.regex : ctRegex;
    import std.string : toUpper;
    enum EnumMatchRegex = ctRegex!(r"(?<=^\s*)enum\s+_" ~ NAME.toUpper ~
                                   r"_\b.*$", "gm");
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


//
void main(string[] args)
{

    try
    {
        import std.getopt : getopt, config, optionChar;
        import std.array : join;

        // ヘルプが必要かどうか。
        if (args.length <= 1) return help.outln;

        bool needs_help = false;
        optionChar = '/';
        getopt(args,
               config.caseInsensitive,
               config.passThrough,
               "help|h|?", &needs_help);
        if (needs_help) return help.outln;

        bool show_version = false;
        optionChar = '-';
        getopt(args,
               config.caseInsensitive,
               config.passThrough,
               "help|h|?", &needs_help,
               "version", &show_version);
        if      (needs_help) return help.outln;
        else if (show_version) return header.outln;

        // 冗長性の決定
        bool is_verbose = false;
        getopt(args,
               config.caseInsensitive,
               config.passThrough,
               "verbose", &is_verbose);
        if (is_verbose) Output.mode = Output.MODE.VERBOSE;

        // プロジェクト名、ヴァージョン名、著者、ライセンスの取得
        import std.array : Appender;
        import std.format : formattedWrite;
        string projectName, versionName, licenseName, authorsName;
        getopt(args,
               config.caseInsensitive,
               "p|project", &projectName,
               "v|setversion", &versionName,
               "l|license", &licenseName,
               "a|authors", &authorsName);

        // dmd のヴァージョンの追加 X.XX -> X.XX(dmdY.YYY.Y)
        auto dmdVersion = getDmdVersion;
        versionName = [versionName, "(dmd", dmdVersion, ")"].join;

        // 正規表現の準備
        import std.regex : ctRegex, replaceAll;
        alias CRLF_MATCH = ctRegex!(r"\r\n", "gs");
        alias CR_MATCH = ctRegex!(r"\r", "gs");
        alias TAB_MATCH = ctRegex!(r"\t", "g");
        alias TRAIL_SPACES_MATCH = ctRegex!(r"[\t]+(?=\n)", "gs");

        alias PROJECT_MATCH = DocMatchRegex!PROJECT_TAG;
        alias PROJECT_MATCH2 = EnumMatchRegex!PROJECT_TAG;
        alias VERSION_MATCH = DocMatchRegex!VERSION_TAG;
        alias VERSION_MATCH2 = EnumMatchRegex!VERSION_TAG;
        alias DMD_MATCH = DocMatchRegex!DMD_TAG;
        alias DMD_MATCH2 = EnumMatchRegex!DMD_TAG;
        alias DATE_MATCH = DocMatchRegex!DATE_TAG;
        alias AUTHORS_MATCH = DocMatchRegex!AUTHORS_TAG;
        alias AUTHORS_MATCH2 = EnumMatchRegex!AUTHORS_TAG;
        alias LICENSE_MATCH = DocMatchRegex!LICENSE_TAG;
        alias LICENSE_MATCH2 = EnumMatchRegex!LICENSE_TAG;

        alias IF_STYLE_MATCH =
            ctRegex!(r"\b(if|for|foreach|version|catch|with)\(", "g");
        // alias OPEN_BRACKET_STYLE_MATCH = ctRegex!(r"(\(|\[) +", "g");
        // alias CLOSE_BRACKET_STYLE_MATCH = ctRegex!(r" +(\)|\])", "g");
        // alias COMMA_STYLE_MATCH = ctRegex!(r"\n(\s*),\s*", "gs");

        // 処理本体
        import std.path : extension;
        import std.datetime : SysTime, Clock, DateTime;
        import std.file : exists, getTimes, setTimes, read, write;
        import std.conv : to;
        import std.functional : binaryReverseArgs;

        if (0 < args.length) args = args[1..$];
        foreach (one; args) // 全ての引数に対して。
        {
            auto ext = one.extension; // 拡張子でD言語のだけ選ぶ。
            if (ext != ".d" && ext != ".di")
            {
                version (InJapanese)
                    logln(one, " はD言語のソースコードではありません。");
                else
                    logln(one, " is not a D source.");
                continue;
            }

            if (!one.exists) // 存在しないのははぶく。
            {
                version (InJapanese)
                    logln(one, " は存在しません。");
                else
                    outln(one, " is not found.");
                continue;
            }

            version (InJapanese)
                logln(one, " の処理を開始します。");
            else
                logln("start the process about ", one);
            Output.incIndent;

            SysTime aTime, mTime;
            one.getTimes(aTime, mTime);
            auto modifTime =
                DateTime(mTime.year, mTime.month, mTime.day,
                         mTime.hour, mTime.minute, mTime.second).toString;
            version (InJapanese)
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

                .replaceAll(PROJECT_MATCH,
                            PROJECT_TAG.docString(projectName))
                .replaceAll(PROJECT_MATCH2,
                            PROJECT_TAG.enumString(projectName))
                .replaceAll(VERSION_MATCH,
                            VERSION_TAG.docString(versionName))
                .replaceAll(VERSION_MATCH2,
                            VERSION_TAG.enumString(versionName))
                .replaceAll(DMD_MATCH,
                            DMD_TAG.docString(dmdVersion))
                .replaceAll(DMD_MATCH2,
                            DMD_TAG.enumString(dmdVersion))
                .replaceAll(DATE_MATCH, DATE_TAG.docString(modifTime))
                .replaceAll(AUTHORS_MATCH,
                            AUTHORS_TAG.docString(authorsName))
                .replaceAll(AUTHORS_MATCH2,
                            AUTHORS_TAG.enumString(authorsName))
                .replaceAll(LICENSE_MATCH,
                            LICENSE_TAG.docString(licenseName))
                .replaceAll(LICENSE_MATCH2,
                            LICENSE_TAG.enumString(licenseName))

                .replaceAll(IF_STYLE_MATCH, "$1 (")
                // .replaceAll(OPEN_BRACKET_STYLE_MATCH, "$1")
                // .replaceAll(CLOSE_BRACKET_STYLE_MATCH, "$1")
                // .replaceAll(COMMA_STYLE_MATCH, ",\n$1 ")

                .binaryReverseArgs!write(one);

            // 編集時間を戻す。
            one.setTimes(Clock.currTime, mTime);

            version (InJapanese)
                logln("終了。");
            else
                logln("done.");
            Output.decIndent;
        }
    }
    catch (Throwable t) t.toString.errorOut;
}
