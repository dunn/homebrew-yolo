class EmacsEdge < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "http://alpha.gnu.org/gnu/emacs/pretest/emacs-25.0.93.tar.xz"
  sha256 "b39199a491ce53f8b8a5b74fe6f1f191257e424f3ba047b3098ff9218e1579f1"
  head "https://github.com/emacs-mirror/emacs.git"

  devel do
    url "https://github.com/emacs-mirror/emacs.git",
        :branch => "emacs-25"
    version "25.1-pre"
  end

  option "with-check-lisp-object-type", "Enable compile-time checks for Lisp_Object"
  option "with-ctags", "Don't remove the ctags executable that Emacs provides"
  option "without-cocoa", "Build without the Cocoa window system"
  option "without-compress-install", "Don't compress elisp, info, etc., files"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build

  depends_on "gnutls" => :recommended

  depends_on "cairo" => :optional
  depends_on "d-bus" => :optional
  depends_on "imagemagick" => :optional
  depends_on "librsvg" => :optional
  depends_on "mailutils" => :optional

  fails_with :llvm do
    build 2334
    cause "Duplicate symbol errors while linking."
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --with-xml2
      --without-x
    ]

    if build.with? "d-bus"
      args << "--with-dbus"
    else
      args << "--without-dbus"
    end

    if build.with? "gnutls"
      args << "--with-gnutls"
    else
      args << "--without-gnutls"
    end

    args << "--enable-check-lisp-object-type" if build.with? "check-lisp-object-type"
    args << "--with-cairo" if build.with? "cairo"
    args << "--with-imagemagick" if build.with? "imagemagick"
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-compress-install" if build.without? "compress-install"
    args << "--without-pop" if build.with? "mailutils"

    if build.with? "cocoa"
      args << "--with-ns" << "--disable-ns-self-contained"
    else
      args << "--without-ns"
    end

    system "./autogen.sh"
    system "./configure", *args
    system "make"
    system "make", "install"

    # Install C sources
    pkgshare.install "src", "lib"

    if build.with? "cocoa"
      prefix.install "nextstep/Emacs.app"

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<-EOS.undent
        #!/bin/bash
        exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
      EOS
    end

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    if build.without? "ctags"
      (bin/"ctags").unlink
      rm Dir["#{man1}/ctags*"]
    end
  end

  def caveats
    s = "Source files were installed in #{opt_pkgshare}.\n"
    if build.with? "cocoa"
      s += <<-EOS.undent

      A command line wrapper for the cocoa app was installed to:
        #{bin}/emacs
      EOS
    end
    s
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/emacs</string>
        <string>--daemon</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_equal "4", shell_output("#{bin}/emacs --batch --eval='(print (+ 2 2))'").strip
  end
end
