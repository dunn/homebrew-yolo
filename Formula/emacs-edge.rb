class EmacsEdge < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "http://alpha.gnu.org/gnu/emacs/pretest/emacs-25.1-rc1.tar.xz"
  version "25.1-rc1"
  sha256 "c00c50e66474359d1e24baa2a0703bc64207caffc31d0808d8b4ffa4b3826133"

  head "https://github.com/emacs-mirror/emacs.git"

  devel do
    url "https://github.com/emacs-mirror/emacs.git",
        :branch => "emacs-25"
    version "25.1-pre"
  end

  # https://lists.gnu.org/archive/html/emacs-devel/2016-06/msg00630.html
  patch do
    url "https://gist.github.com/dunn/86c9364c009a9ba99243da653aecbd23/raw/49fc227b2b27a3f9aa43e502181dcb19783a2ee5/emoji.patch"
    sha256 "c8a1402c73b5eb6bd1dc747f6411e42760beff8a41ead3726395a90e04f0dae7"
  end

  option "with-check-lisp-object-type", "Enable compile-time checks for Lisp_Object"
  option "with-ctags", "Don't remove the ctags executable that Emacs provides"
  option "without-cocoa", "Build without the Cocoa window system"
  option "without-compress-install", "Don't compress elisp, info, etc., files"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build

  depends_on "gdk-pixbuf" => :linked
  depends_on "gettext" => :linked
  depends_on "glib" => :linked
  depends_on "jpeg" => :linked

  depends_on "gnutls" => :recommended

  depends_on "cairo" => [:optional, :linked]
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
      --with-modules
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
