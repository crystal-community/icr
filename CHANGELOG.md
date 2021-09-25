#### v0.9.0 2021-09-25
* Add color highlight while you type (thanks to @sugarfi)
* Use magic comments `#exit` and `#quit` to leave ICR (thanks to @sugarfi)
* Support for latest Crystal (thanks to @mamantoha)
* Add magic comment `#help` command to get available commands. (thanks to @sugarfi)
* Better version support with Crystal (thanks to @HashNuke)

#### v0.8.0 2020-02-18
* Crystal 0.33.0 compatibility #118 (thanks to @tenebrousedge)

#### v0.7.0 2020-02-08

* Update crystal compatibility version #108 (thanks to @wontruefree)
* Crashes when path contains spaces #113
* Include readline as shard since it's no longer in the std-lib #115
* Expand tilde in config path #116 (thanks to @jgillich)

#### v0.6.0 2018-11-04
* Crystal 0.27 compatibility (#102 thanks to @blazerw)

#### v0.5.0 2018-01-01
* New `debug` command to toggle debug output interactively (#74, thanks to @russolsen)
* New `reset` command to clear commands (#75, thanks to @russolsen)
* Crystal 0.24.1 support (#72, thanks to @veelenga)
* Corrected `Icr::HOMEPAGE` (#81, thanks to @Sija)

#### v0.4.0 2017-11-14
* Add syntax highlight (MakeNowJust) #70
* README grammar fixes (Sevensidedmarble) #73
* Remove post-install scripts (faustinoaq) #69
* Change suggestion for binary location (coderhs) #68

#### v0.3.0 2017-10-21
* Add slightly better support for macros (jwoertink) #47
* Add --no-debug flag to improve speed (faustinoaq) #52
* Implementation of the paste mode (Porcupine96) #56
* Catch constant assignment and set it outside of the exec method (jwoertink) #59
* Last result local '__' (veelenga) #63
* Fixed error with unterminated char literal (jwoertink) #50
* Usage warning (veelenga) #66

#### v0.2.14 2017-01-31
* (fix) behavioral difference when reassigning variable in multi-line blocks (jwoertink)

#### v0.2.13 2016-11-25
* Update for Crystal 0.20 compatibility (jwoertink)

#### v0.2.12 2016-11-16
* Support alias (jwoertink)

#### v0.2.11 2016-11-10
* Handle multi line hash (jwoertink)

#### v0.2.10 2016-09-09
* Support of -r option (jwoertink)

#### v0.2.9 2016-09-07
* Support of records (puppetpies)
* Support of Crystal 0.19

#### v0.2.8 2016-05-23
* Support of Crystal 0.16 (BlaXpirit)

#### v0.2.7 2016-03-23
* Support of Crystal 0.14

#### v0.2.6 2016-03-22
* (fix) allow assignment with operator (issue 12)

#### v0.2.5 2016-03-21
* (fix) remove .crystal tmp dir (issue 14)
* Add LGPL license (issue  13)

#### v0.2.4 2016-02-17
* (fix) display stderr output

#### v0.2.4 2016-02-17
* (fix) display stderr output

#### v0.2.3 2016-02-07
* Remove LLVM dependency (fixes LLVM issue)

#### v0.2.2 2016-01-30
* Support of --help and --version options
* Support of debug mode (--debug option)

#### v0.2.1 2016-01-30
* Ability to require local files

#### v0.2.0 2016-01-30
* Support multiline input
* Support definition of modules, classes and methods
* Return just "OK", when file is required
* Exit with proper message, if crystal is not installed
* Proper integration tests
* Refactor

#### v0.1.2 2016-01-25
* Exit with Ctrl+D (thanks Baptiste Fontaine)
* Handle empty inputs

#### v0.1.1 2016-01-24
* Support crystal 0.11.0

#### v0.1.0 2016-01-22
* First public release
