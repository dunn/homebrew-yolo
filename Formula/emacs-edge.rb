class EmacsEdge < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftpmirror.gnu.org/emacs/emacs-25.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/emacs/emacs-25.1.tar.xz"
  sha256 "19f2798ee3bc26c95dca3303e7ab141e7ad65d6ea2b6945eeba4dbea7df48f33"

  devel do
    url "https://github.com/emacs-mirror/emacs.git",
        branch: "emacs-25"
    version "25.2-devel"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "pkg-config" => :build
  end

  head do
    url "https://github.com/emacs-mirror/emacs.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "pkg-config" => :build
  end

  # https://lists.gnu.org/archive/html/emacs-devel/2016-06/msg00630.html
  patch do
    url "https://gist.github.com/dunn/86c9364c009a9ba99243da653aecbd23/raw/49fc227b2b27a3f9aa43e502181dcb19783a2ee5/emoji.patch"
    sha256 "c8a1402c73b5eb6bd1dc747f6411e42760beff8a41ead3726395a90e04f0dae7"
  end

  option "with-check-lisp-object-type", "Enable compile-time checks for Lisp_Object"
  option "with-ctags", "Don't remove the ctags executable that Emacs provides"
  option "without-compress-install", "Don't compress elisp, info, etc., files"

  depends_on "librsvg"
  depends_on "mailutils"
  depends_on "gnutls" => :recommended
  depends_on "cairo" => :optional
  depends_on "dbus" => :optional
  depends_on "imagemagick" => :optional

  fails_with :llvm do
    build 2334
    cause "Duplicate symbol errors while linking."
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-ns-self-contained
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --with-modules
      --with-ns
      --with-rsvg
      --with-xml2
      --without-pop
      --without-x
    ]

    if build.with? "dbus"
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

    system "./autogen.sh" unless build.stable?
    system "./configure", *args
    system "make"
    system "make", "install"

    # Install C sources
    pkgshare.install "src", "lib"

    prefix.install "nextstep/Emacs.app"

    # Replace the symlink with one that avoids starting Cocoa.
    (bin/"emacs").unlink # Kill the existing symlink
    (bin/"emacs").write <<-EOS.undent
      #!/bin/bash
      exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
    EOS

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    if build.without? "ctags"
      (bin/"ctags").unlink
      rm Dir["#{man1}/ctags*"]
    end
  end

  def caveats
    "Source files were installed in #{opt_pkgshare}."
  end

  plist_options manual: "emacs"

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
