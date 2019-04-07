
# Version WRITEr

__Version:__ 0.35(dmd2.085.0)
__Date:__ 2019-Apr-01 23:08:47
__Authors:__ KUMA
__License:__ CC0

## Description
This program appends some informations to your D source files. And modify your coding style. Expected character coding of the source code is UTF-8(non-BOM) only.


## Acknowledgements
vwrite is written by D Programming Language.
[Digital Mars D Programming Language](http://dlang.org/)

vwrite depends on Mofile as a submodule.
[Mofile](https://github.com/FreeSlave/mofile.git)

## Notice
__THIS PROGRAM WILL CHANGE YOUR PROJECT'S WHITE SPACING RULE ACCORDING TO THE RULE OF DMD!__

## White spacing rule of DMD
- `'	'`(tab character) is not allowed.
- trailing spaces are not allowed.
- Newline sequence other than `'\n'`(unix style) is not allowed.

## How to build

### On Windows
Please use the make tool that is distributed with dmd.

### 32bit Windows

    >make -f win.mak release

### 64bit Windows

    >make -f win.mak release FLAG=-m64

### On linux

    >make -f linux64.mak release

## How to use

    >vwrite -v VERSION.OF.YOUR.PROJECT code.d code2.d ...


## Options
option                  | description
------------------------|-----------
-lang **                | Specify the language.
-verbose                | Set output policy as 'VERBOSE'.
-quiet -q               | Set output policy as 'quiet'.
-setversion -version -v | Set a version string of your project.
*.d                     | D source files.


## What will this program do
this program will do,

1. read informations about your project from command line arguments.
    1. `'--setversion XXX.x'` gives the description of the version.
1. read file names from arguments. and select files that
    1. have `'.d'` or `'.di'` extension.
1. read each files and do replacement accroding to the manners below.
    1. replace `'\r\n'` with `'\n'`.
    1. replace `'\r'` with `'\n'`.
    1. replace `'\t'` with `'    '`(four sequential spaces).
    1. remove tailing spaces.
    1. replace `Version:` with `Version: XXX.x(dmdY.YYY.Y)`.
    1. replace `enum _VERSION_ = "";` with `enum _VERSION_="XXX.x(dmdY.YYY.Y)";`.
    1. replace `Date:` with `Date: YYYY-MON-DD HH:MM:SS`.
    1. replace `if(` with `if (`.
    1. replace `for(` with `for (`.
    1. replace `foreach(` with `foreach (`.
    1. replace `version(` with `version (`.
    1. replace `catch(` with `catch (`.
1. output to the file.
1. rewind the modified time of the file.

## Development Environment
- Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars)
- Ubuntu 15.10(amd64) x dmd 2.070.0 x gcc 5.2.1

## License description
[Creative Commons Zero License](http://creativecommons.org/publicdomain/zero/1.0/)

## History
- 2019-Apr-01 16:42:32 ver. 0.35(dmd2.085.0)
    - implement i18n and japanese l10n.
- 2016-02-28 ver. 0.034(dmd2.070.0)
    - --authors, --project and --license are removed.
- 2016-02-22 ver. 0.33(dmd2.070.0)
    - README.md and the commandline help message are generated automatically by ddoc. add 'Dmd:', ddoc section.
- 2016-01-29 ver. 0.32(dmd2.070.0)
    - The version information of dmd is added to the user specified string automatically.
- 2015-12-16 ver. 0.31(dmd2.069.2)
    - add replacing rule for `'if ('`, `'for ('`, `'foreach ('`, `'version ('`, `'catch ('`.
- 2015 12/14 ver. 0.30(dmd2.069.2)
    - add japanese messages.
- 2015 12/13 ver. 0.29(dmd2.069.2)
    - fully brush up.
    - delete v-style.xml.
    - use command line argument for all settings.
    - delete -target.
    - add checking process of white spacing style.
    - add English README.md.
- 2013 03/02 ver. 0.28(dmd2.062)
    - fix a bug about searching for v-style.xml on linux.
- 2012 10/28 ver. 0.27(dmd2.060)
    - add `'-target'` to set a needle file to filter that newer than the needle will pass.
- 2012 10/27 ver. 0.26(dmd2.060)
    - debut on GitHub.
- 2012  2/21  ver. 0.24 for dmd2.058
    - some bugs are fixed.
- 2010  3/14  ver. 0.22
    - for dmd2.041. but no change occur.
- 2009 10/20  ver. 0.21
    - for dmd2.035.
- 2009  9/ 1  ver. 0.1
    - First released version.

* * *


# Version WRITEr

__Version:__ 0.35(dmd2.085.0)
__Date:__ 2019-Apr-01 23:08:47
__Authors:__ KUMA
__License:__ CC0

## 説明
このプログラムはD言語で書かれたソースコードにヴァージョン情報などを追加します。ついでにコーディングスタイルもD準拠に変更します。ソースコードに使える文字コードは、UTF-8(BOM無し)のみです。


## 謝辞
VWRITEはD言語で記述されています。
[D言語(Digital Mars)](http://dlang.org/)

VWRITEは Mofile を利用しています。
[Mofile](https://github.com/FreeSlave/mofile.git)

## 注意!!
__ソースコードのインデント文字、改行文字等のルールを変更してしまいます。ご注意ください。__

## DMD準拠のルール
- `'\t'`(タブ文字)を使わない。
- 行末に空白文字を置かない。
- UNIXスタイルの改行文字 `'\n'` を使用する。

## ビルド方法

### Windowsで
DMD同梱の make ツールを使用してください。

### 32bit Windows

    >make -f win.mak release

### 64bit Windows

    >make -f win.mak release FLAG=-m64

### On linux

    >make -f linux64.mak release

## 使い方

    >vwrite -v VERSION.OF.YOUR.PROJECT code.d code2.d ...


## オプション
オプション              | 説明
------------------------|-----------
-lang **                | 出力用の言語を設定します。
-verbose                | 出力設定を'冗長'に設定します。
-quiet -q               | 出力設定を'静か'に設定します。
-setversion -version -v | プロジェクトのヴァージョン文字列を設定します。
*.d                     | D言語のソースファイル。


## VWRITEの挙動
VWRITEは次のことを行います。

1. コマンドライン引数からプロジェクトの内容を読み取ります。
    1. コマンドライン引数 `'--setversion XXX.x'`で、ヴァージョン文字列を設定します。
1. コマンドライン引数からファイルパスを読み取ります。
    1. `'.d'`もしくは`'.di'`のファイル拡張子を持つパスに限定します。
1. ファイルを一つずつ開き、以下の手順で置換を行います。
    1. `'\r\n'`を`'\n'`に置き換えます。
    1. `'\r'`を`'\n'`に置き換えます。
    1. `'\t'`を`'    '`(4つのスペース)に置き換えます。
    1. 行末の空白文字を取り除きます。
    1. `Version:` を `Version: XXX.x(dmdY.YYY.Y)`で置き換えます。
    1. `enum _VERSION_ = "";` を `enum _VERSION_="XXX.x(dmdY.YYY.Y)";` で置き換えます。
    1. `Date:` を `Date: YYY-MON-DD HH:MM:SS` で置き換えます。
    1. `if(` を `if (`に置き換えます。
    1. `for(` を `for (`に置き換えます。
    1. `foreach(`を`foreach (`に置き換えます。
    1. `version(` を `version (`で置き換えます。
    1. `catch(`を`catch (`に置き換えます。
1. ファイルに出力します。
1. 最終更新日時を書き戻します。

## 開発環境
- Windows Vista(x64) x dmd 2.070.0 x make(of Digital Mars)
- Ubuntu 15.10(amd64) x dmd 2.070.0 x gcc 5.2.1

## ライセンス
[クリエイティブ・コモンズ・ゼロ ライセンス](http://creativecommons.org/publicdomain/zero/1.0/)

## 履歴
- 2019-Apr-01 16:42:32 ver. 0.35(dmd2.085.0)
    - i18nと日本語l10nの実装。
- 2016-02-28 ver. 0.034(dmd2.070.0)
    - `--authors`、`--project`、`--license`オプションがなくなりました。
- 2016-02-22 ver. 0.33(dmd2.070.0)
    - README.mdとヘルプメッセージの出力にDDOCを利用するようになりました。ddocに`Dmd:`セクションを追加しました。
- 2016-01-29 ver. 0.32(dmd2.070.0)
    - ユーザー指定のヴァージョン文字列に、DMDのヴァージョン文字列を自動で加えるようにしました。
- 2015-12-16 ver. 0.31(dmd2.069.2)
    - `'if ('`、`'for ('`、`'foreach ('`、`'version ('`、`'catch ('`に置換するようにしました。
- 2015 12/14 ver. 0.30(dmd2.069.2)
    - 日本語メッセージをつけました。
- 2015 12/13 ver. 0.29(dmd2.069.2)
    - 全面刷新しました。
    - v-style.xmlを使わないようにしました。
    - 全ての設定をコマンドライン引数から行うようにしました。
    - `-target`オプションを無くしました。
    - 空白文字のスタイルを置換するようにしました。
    - 英語版 README.md を書きました。
- 2013 03/02 ver. 0.28(dmd2.062)
    - linux上で、v-style.xmlを探せないバグを修正しました。
- 2012 10/28 ver. 0.27(dmd2.060)
    - `-target`オプションを追加しました。ターゲットよりも新しいファイルのみ更新されるようになりました。
- 2012 10/27 ver. 0.26(dmd2.060)
    - GitHubで公開しました。
- 2012  2/21  ver. 0.24 for dmd2.058
    - バグフィックス
- 2010  3/14  ver. 0.22
    - dmd2.041用。他は一緒。
- 2009 10/20  ver. 0.21
    - dmd2.035用
- 2009  9/ 1  ver. 0.1
    - とりあえず動いた。
