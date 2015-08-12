class Pioneer < Formula
  desc "Open-ended space adventure game"
  homepage "http://pioneerspacesim.net/"
  url "https://github.com/pioneerspacesim/pioneer/archive/20150810.tar.gz"
  sha256 "b53f342282582f32106d15eb3c81dd3a583f05f76ea279a03df6f65ba8837400"
  head "https://github.com/pioneerspacesim/pioneer.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkgconfig" => :build

  depends_on "assimp"
  depends_on "freetype"
  depends_on "libsigc++"
  depends_on "libvorbis"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "sdl_sound"

  def install
    ENV["PIONEER_DATA_DIR"] = var/"pioneer"
    ENV["GL_CFLAGS"] = "-I#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
    ENV["GL_LIBS"] = "-I#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Libraries"

    system "./bootstrap"
    system "./configure", "--prefix=#{prefix}",
                          "--with-version=#{version}",
                          "--datadir=#{var}/pioneer",
                          "--disable-silent-rules",
                          "--disable-dependency-tracking"
    system "make", "install"
  end
end
