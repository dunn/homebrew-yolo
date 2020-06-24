class EmacsEdge < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftp.gnu.org/gnu/emacs/emacs-26.3.tar.xz"
  mirror "https://ftpmirror.gnu.org/emacs/emacs-26.3.tar.xz"
  sha256 "4d90e6751ad8967822c6e092db07466b9d383ef1653feb2f95c93e7de66d3485"

  head do
    url "https://github.com/emacs-mirror/emacs.git"

    depends_on "autoconf" => :build
    depends_on "gnu-sed" => :build
    depends_on "texinfo" => :build
  end

  # https://lists.gnu.org/archive/html/emacs-devel/2016-06/msg00630.html
  patch do
    url "https://gist.github.com/dunn/86c9364c009a9ba99243da653aecbd23/raw/49fc227b2b27a3f9aa43e502181dcb19783a2ee5/emoji.patch"
    sha256 "c8a1402c73b5eb6bd1dc747f6411e42760beff8a41ead3726395a90e04f0dae7"
  end

  option "with-check-lisp-object-type", "Enable compile-time checks for Lisp_Object"
  option "without-compress-install", "Don't compress elisp, info, etc., files"

  depends_on "pkg-config" => :build
  depends_on "gnutls"
  depends_on "cairo" => :optional
  depends_on "dbus" => :optional
  depends_on "imagemagick" => :optional

  on_linux do
    depends_on "jpeg"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --with-gnutls
      --with-modules
      --with-rsvg
      --with-xml2
    ]

    if OS.mac?
      args += %w[
        --disable-ns-self-contained
        --with-ns
        --without-x
      ]
    end

    args << if build.with? "dbus"
      "--with-dbus"
    else
      "--without-dbus"
    end

    args << "--enable-check-lisp-object-type" if build.with? "check-lisp-object-type"
    args << "--with-cairo" if build.with? "cairo"
    args << "--with-imagemagick" if build.with? "imagemagick"

    if build.head?
      ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"
      system "./autogen.sh"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    # Install C sources
    pkgshare.install "src", "lib"

    if OS.mac?
      prefix.install "nextstep/Emacs.app"

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<~EOS
        #!/bin/bash
        exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
      EOS
    end

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    (bin/"ctags").unlink
    (man1/"ctags.1.gz").unlink
  end

  def caveats
    "Source files were installed in #{opt_pkgshare}."
  end

  plist_options :manual => "emacs"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/emacs</string>
          <string>--fg-daemon</string>
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
