class Clickhouse < Formula
  desc "is an open-source column-oriented database management system."
  homepage "https://clickhouse.yandex/"
  url "https://github.com/yandex/ClickHouse/archive/v1.1.54198-stable.zip"
  version "1.1.54198"
  sha256 "3e576c50e6f61c0f710b4e5b1ee19535c8196a3dde44fd028c49d863b09ea41e"

  devel do
    url "https://github.com/yandex/ClickHouse/archive/v1.1.54214-testing.zip"
    version "1.1.54214"
    sha256 "0251e549a35621cfea56bf317984c8bbf917b0c0c9ff8681550643df1180a4a0"
  end

  bottle do
    root_url 'https://github.com/hatarist/homebrew-clickhouse/releases/download/bottle'
    sha256 "4a9539797fbedc28412f7bc0bdd1096e3da9eb9109448abe45319091ef99aa94" => :el_capitan
  end
  
  head "https://github.com/yandex/ClickHouse.git"

  depends_on "cmake" => :build
  depends_on "gcc" => :build

  depends_on "boost" => :build
  depends_on "icu4c" => :build
  depends_on "mysql" => :build
  depends_on "openssl" => :build
  depends_on "unixodbc" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "zlib" => :build
  depends_on "readline" => :recommended

  def install
    ENV["ENABLE_MONGODB"] = "0"
    ENV["CC"] = "#{Formula["gcc"].bin}/gcc-6"
    ENV["CXX"] = "#{Formula["gcc"].bin}/g++-6"

    cmake_args = %w[]
    cmake_args << "-DUSE_STATIC_LIBRARIES=0" if MacOS.version >= :sierra

    mkdir "build"
    cd "build" do
      system "cmake", "..", *cmake_args
      system "make"
      if MacOS.version >= :sierra
        lib.install Dir["#{buildpath}/build/dbms/*.dylib"]
        lib.install Dir["#{buildpath}/build/contrib/libzlib-ng/*.dylib"]
      end
      bin.install "#{buildpath}/build/dbms/src/Server/clickhouse"
      bin.install_symlink "clickhouse" => "clickhouse-server"
      bin.install_symlink "clickhouse" => "clickhouse-client"
    end

    mkdir "#{var}/clickhouse"

    inreplace "#{buildpath}/dbms/src/Server/config.xml" do |s|
      s.gsub! "/var/lib/clickhouse/", "#{var}/clickhouse/"
      s.gsub! "/var/log/clickhouse-server/", "#{var}/log/clickhouse/"
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

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/clickhouse-server</string>
            <string>--config-file</string>
            <string>#{etc}/clickhouse-server/config.xml</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
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