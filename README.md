# ICR - Interactive Crystal [![Build Status](https://travis-ci.org/greyblake/crystal-icr.svg?branch=master)](https://travis-ci.org/greyblake/crystal-icr)

Interactive console for [Crystal Programming Language](http://crystal-lang.org/).

## Usage
It's like irb, but for Crystal:

```
$ icr
icr(0.10.0) > a = 10
 => 10
icr(0.10.0) > b = 20
 => 20
icr(0.10.0) > a + b
 => 30
icr(0.10.0) > a + b + c
  undefined local variable or method 'c' (did you mean 'a'?)
  a + b + c
          ^
exit
```

## Installation
Prerequisites:
* It requires [crystal](https://github.com/manastech/crystal) to be already installed.


Clone the repo:
```
git clone https://github.com/greyblake/crystal-icr.git
```
Build
```
make
```
Copy `./bin/icr` in to direcotory that is listed in your `$PATH`, e.g.:
```
sudo cp ./bin/icr /usr/bin/icr
```
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
