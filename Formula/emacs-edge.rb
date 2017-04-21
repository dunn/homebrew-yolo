class EmacsEdge < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftpmirror.gnu.org/emacs/emacs-25.2.tar.xz"
  sha256 "59b55194c9979987c5e9f1a1a4ab5406714e80ffcfd415cc6b9222413bc073fa"

  devel do
    url "https://github.com/emacs-mirror/emacs.git",
        :branch => "emacs-25"
    version "25.2-devel"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "pkg-config" => :build
    depends_on "texinfo" => :build
  end

  head do
    url "https://github.com/emacs-mirror/emacs.git"
    depends_on "autoconf" => :build
    depends_on "pkg-config" => :build
    depends_on "texinfo" => :build
  end

  # https://lists.gnu.org/archive/html/emacs-devel/2016-06/msg00630.html
  patch do
    url "https://gist.github.com/dunn/86c9364c009a9ba99243da653aecbd23/raw/49fc227b2b27a3f9aa43e502181dcb19783a2ee5/emoji.patch"
    sha256 "c8a1402c73b5eb6bd1dc747f6411e42760beff8a41ead3726395a90e04f0dae7"
  end

  # https://magit.vc/manual/magit/MacOS-Performance.html
  unless build.head?
    # upstream commit doesn't apply cleanly, so use emacs-plus version
    # https://github.com/d12frosted/homebrew-emacs-plus/blob/cf6f2da402b10a37e3c27fe19c1a8b551d5dd118/Formula/emacs-plus.rb#L87-L96
    patch do
      url "https://gist.githubusercontent.com/aaronjensen/f45894ddf431ecbff78b1bcf533d3e6b/raw/6a5cd7f57341aba673234348d8b0d2e776f86719/Emacs-25-OS-X-use-vfork.patch"
      sha256 "f2fdbc5adab80f1af01ce120cf33e3b0590d7ae29538999287986beb55ec9ada"
    end
  end

  option "with-check-lisp-object-type", "Enable compile-time checks for Lisp_Object"
  option "without-compress-install", "Don't compress elisp, info, etc., files"

  depends_on "librsvg"
  depends_on "mailutils"
  depends_on "gnutls" => :recommended
  depends_on "cairo" => :optional
  depends_on "dbus" => :optional
  depends_on "imagemagick@6" => :optional

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
      --with-rsvg
      --with-xml2
      --without-pop
    ]

    if OS.mac?
      args += %w[
        --disable-ns-self-contained
        --with-ns
        --without-x
      ]
    end

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
    (bin/"ctags").unlink
    rm Dir["#{man1}/ctags*"]
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
