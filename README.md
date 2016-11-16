# ICR - Interactive Crystal [![Build Status](https://travis-ci.org/greyblake/crystal-icr.svg?branch=master)](https://travis-ci.org/greyblake/crystal-icr)

Interactive console for [Crystal Programming Language](http://crystal-lang.org/).

* [Usage](#usage)
  * [Require local files](#require-local-files)
* [Installation](#installation)
  * [Arch Linux](#arch-linux)
* [How does it work?](#how-does-it-work)
* [Development](#development)
* [Contributors](#contributors)

## Usage

It's like irb, but for Crystal:

![GIF demo](https://raw.githubusercontent.com/greyblake/crystal-icr/master/demo/demo.gif)

### Require local files
You can require local files by relative path (starts with `./`):
```
require "./src/my_cool_lib"
```

Libs can also be required from the cli

```
$ icr -r colorize -r ./src/my_cool_lib
```

## Installation
Prerequisites:
* The latest version of crystal (0.18.0).
* Readline (for Debian/Ubuntu install `libreadline6-dev` package).
* LLVM development files.

Clone the repo:
```
git clone https://github.com/greyblake/crystal-icr.git
```
Switch to repo-directory:
```
cd crystal-icr
```
Build:
```
make
```
And create symlink of `./bin/icr` in to direcotory that is listed in your `$PATH`, e.g.:
```
sudo ln -s $(realpath ./bin/icr) /usr/bin/icr
```
_(it's necessary only for the first time)_

### As a shard dependency

If you would like to include icr as a dependency, you can add it to your `shard.yml`

```yml
dependencies:
  icr:
    github: greyblake/crystal-icr
    branch: master
```

Then just run `shards install` from your project!

Enjoy!


### Arch Linux

Arch Linux users can install ICR [from AUR](https://aur.archlinux.org/packages/crystal-icr/).


## How does it work?
* Every time you press `Enter` it adds new instruction, generates new crystal program and executes it.
* The output is split into 2 parts: regular program output (e.g. output from `puts 10`) and value returned by the last command
* The regular output is saved, and when you type a new instruction, new program is generated. The saved output is subtracted from the new output, and the difference is printed out. It makes an illusion that only new instructions are executed :)

## Development

To run tests:
```
make test
```

## Contributors

- [greyblake](https://github.com/greyblake) Potapov Sergey - creator, maintainer
- [BlaXpirit](https://github.com/BlaXpirit) Oleh Prypin - fixes for Crystal 0.16
- [puppetpies](https://github.com/puppetpies) Brian Hood - support of records
- [jwoertink](https://github.com/jwoertink) Jeremy Woertink - support of -r option and number of other contributions
