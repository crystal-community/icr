# ICR - Interactive Crystal [![Build Status](https://travis-ci.org/greyblake/crystal-icr.svg?branch=master)](https://travis-ci.org/greyblake/crystal-icr)

Interactive console for [Crystal Programming Language](http://crystal-lang.org/).

* [Usage](#usage)
  * [Require local files](#require-local-files)
* [Installation](#installation)
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

## Installation
Prerequisites:
* It requires [crystal](https://github.com/manastech/crystal) to be already installed.


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

Enjoy!)


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
