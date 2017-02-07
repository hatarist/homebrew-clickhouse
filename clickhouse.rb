class Clickhouse < Formula
  desc "is an open-source column-oriented database management system."
  homepage "https://clickhouse.yandex/"
  url "https://github.com/yandex/ClickHouse/archive/v1.1.54159-stable.zip"
  version "1.1.54159"
  sha256 "21da277ad5bb14dfeaea8dba57dce9225c24e432d219e4f344fdf15c99bc1eb8"

  devel do
    url "https://github.com/yandex/ClickHouse/archive/v1.1.54159-testing.zip"
    version "1.1.54159"
    sha256 "25a155c98c32e305cac164ae05088da0ca17294b41e4f3561fe0c3d4e65fd325"
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
      stable do
        s.gsub! "/opt/clickhouse/", "#{var}/clickhouse/"
      end
      devel do
        s.gsub! "/var/lib/clickhouse/", "#{var}/clickhouse/"
      end
      
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