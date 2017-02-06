# Homebrew ClickHouse Tap

This is an unofficial Homebrew repository for the Yandex's [ClickHouse](https://clickhouse.yandex/) DBMS.

## Install

This Homebrew Formula is relatevily new and isn't tested well.  
Please consider appending the `--verbose --debug` parameters to the `brew install` command to make it easier to debug the package installation.

Add this repository:
```
brew tap hatarist/clickhouse
```

To install the latest `stable` release, run:
```
brew install clickhouse
```

Or, to install the `testing` release, run:

```
brew install clickhouse --devel
```

## Run

Make sure that you've increased the maxfiles parameter as described in [here](https://github.com/yandex/ClickHouse/blob/master/MacOS.md).  
Then:
```
brew services start clickhouse
```

