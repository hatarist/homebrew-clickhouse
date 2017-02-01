class Clickhouse < Formula
  desc "is an open-source column-oriented database management system."
  homepage "https://clickhouse.yandex/"
  url "https://github.com/yandex/ClickHouse/archive/v1.1.54144-stable.zip"
  version "1.1.54144"
  sha256 "e9f26c17f7e3a08e506ee4e97da3a097b9aedc4d14decb24345b4766021f1602"
  head "https://github.com/yandex/ClickHouse.git"

  devel do
    url "https://github.com/yandex/ClickHouse/archive/v1.1.4-testing.zip"
    version "1.1.4"
    sha256 "dbe635cb4270b39e816149117587f6bfb18e9ac4032782fadee3390ab92ff27f"
  end

  head "https://github.com/yandex/ClickHouse.git"

  depends_on "cmake" => :build
  depends_on "gcc" => :build

  ENV["HOMEBREW_CC"] = "gcc-6"
  ENV["HOMEBREW_LD"] = "gcc-6"
  ENV["HOMEBREW_CXX"] = "g++-6"

  depends_on "boost" => :build
  depends_on "icu4c" => :build
  depends_on "mysql" => :build
  depends_on "openssl" => :build
  depends_on "unixodbc" => :build
  depends_on "glib" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "homebrew/dupes/libiconv" => :build
  depends_on "homebrew/dupes/zlib" => :build
  depends_on "readline" => :recommended

  def install
    ENV["ENABLE_MONGODB"] = "0"

    mkdir "build"
    cd "build" do
      system "cmake", "..", "-DUSE_STATIC_LIBRARIES=0"
      system "make"
      bin.install "#{buildpath}/build/dbms/src/Server/clickhouse" => "clickhouse-server"
      bin.install_symlink "clickhouse-server" => "clickhouse-client"
    end

    mkdir "#{var}/clickhouse"

    inreplace "#{buildpath}/dbms/src/Server/config.xml" do |s|
      s.gsub! "/var/lib/clickhouse/", "#{var}/clickhouse/"
      s.gsub! "<!-- <max_open_files>262144</max_open_files> -->", "<max_open_files>262144</max_open_files>"
    end

    # Copy configuration files
    mkdir "#{etc}/clickhouse-client/"
    mkdir "#{etc}/clickhouse-server/"
    mkdir "#{etc}/clickhouse-server/config.d/"
    mkdir "#{etc}/clickhouse-server/users.d/"

    (etc/"clickhouse-client").install "#{buildpath}/dbms/src/Client/config.xml"
    (etc/"clickhouse-server").install "#{buildpath}/dbms/src/Server/config.xml"
    (etc/"clickhouse-server").install "#{buildpath}/dbms/src/Server/users.xml"
  end

  def caveats; <<-EOS.undent
    The configuration files are available at:
      #{etc}/clickhouse-client/
      #{etc}/clickhouse-server/
    The database itself will store data at:
      #{var}/clickhouse/

    If you're going to run the server, make sure to increase `maxfiles` limit:
      https://github.com/yandex/ClickHouse/blob/master/MacOS.md
  EOS
  end

  test do
    system "#{bin}/clickhouse-client", "--version"
  end
end