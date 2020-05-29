# Social Networking Kata
This implementation is written in bash for fun and experimentation.

The original specifications are available at [Social Networking kata](https://github.com/xpeppers/social_networking_kata_kata)


## Prerequisites
- bash > 5.0
- sqlite3
- make

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
```
make run
```

## Running the tests
```
make test
```

## Author
Roberto Boati - [rboati](https://github.com/rboati)


## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details