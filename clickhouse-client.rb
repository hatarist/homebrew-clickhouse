class ClickhouseClient < Formula
  desc "client for an open-source column-oriented database management system."
  homepage "https://clickhouse.yandex/"
  url "https://github.com/hatarist/homebrew-clickhouse/releases/download/1.1.54074/clickhouse-1.1.54074.tar.gz"
  version "1.1.54074"
  sha256 "4a348bc6bed4ae3a62d9a88ec322f1577fcdd30777798b89cc24d615f21cc0b9"

  bottle :unneeded

  def install
    bin.install "clickhouse" => "clickhouse-client"
  end
end