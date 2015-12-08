class Xombrero < Formula
  desc "Minimalist web browser with sophisticated security features"
  homepage "https://opensource.conformal.com/wiki/xombrero"
  url "https://opensource.conformal.com/snapshots/xombrero/xombrero-1.6.4.tgz"
  sha256 "3d818d22fa4b4fd6625522a8901ea695bbf6ae79074f4ec55a1ee16fdc5d2fd9"
  head "https://github.com/conformal/xombrero.git"

  depends_on "pkg-config" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "gtk+3"
  depends_on "libsoup"
  depends_on "webkitgtk"
  depends_on :x11

  def install
    inreplace "osx/Makefile", "webkitgtk-3.0", "webkit2gtk-4.0"
    inreplace "xombrero.h", "<webkit/webkit.h>", "<webkit2/webkit2.h>"

    cd "osx"
    system "make", "install", "PREFIX=#{prefix}", "APPDIR=#{libexec}"
  end
end
