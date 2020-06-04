# Social Networking Kata
This implementation is written in bash for fun and experimentation.

The original specifications are available at [Social Networking kata](https://github.com/xpeppers/social_networking_kata_kata)


## Prerequisites
- bash > 5.0
- sqlite3
- make
- kcov for test coverage

The project has been tested only on Linux platform.

On a Debian system you can check and install all dependencies with the following command:
```
apt install bash coreutils sqlite3 make kcov
```

## Installation
It's possible to install the project in your system with the following command:
```
make install [DESTDIR=''] [prefix=$HOME/.local]
```
By specifing optionally `DESTDIR` and `prefix` you can customize the installation path. The resulting installation path is the concatenation of the two variables: `DESTDIR/prefix`.

The following command generates a compressed archive in the `dist` directory to easy the distribution:
```
make dist
```


## Run
The project needs to download some bash libraries from [bashlibs](https://github.com/rboati/bashlibs) before running.
Execute the following command to ensure that these libraries are downloaded or updated:
```
make update
```
Installation is not required to run the project. This project supports execution directly from the source directory with this command:
```
make run
```
Anyway if you install the project, you'll find the main script linked as `social_networking_kata` in the `bin` directory of your installation directory. If the `bin` directory is already in your `PATH` to run the program you just need to type:
```
social_networking_kata
```

## Running the tests
Execute the following command to run the tests:
```
make test
```
If you have `kcov` on your system you can also launch the test coverage reports in the `coverage` directory:
```
make coverage
```

## Author
Roberto Boati - [rboati](https://github.com/rboati)


## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details