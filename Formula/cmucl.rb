class Cmucl < Formula
  desc "High-performance, free Common Lisp implementation"
  homepage "https://www.cons.org/cmucl/"
  url "https://common-lisp.net/project/cmucl/downloads/release/21a/cmucl-src-21a.tar.bz2"
  sha256 "41604a4f828a134dbf8a58623f45bd81b76ae05fc5c4cea5ccb74edfdc9e3167"
  head "https://gitlab.common-lisp.net/cmucl/cmucl.git"

  resource "bootstrap" do
    url "https://common-lisp.net/project/cmucl/downloads/snapshots/2016/06/cmucl-2016-06-x86-darwin.tar.bz2"
    sha256 "6a326515b2015f5dcb8f7f6517cecbf33fdf1bf375adb13c281dea7794d607e3"
  end

  devel do
    url "https://common-lisp.net/project/cmucl/downloads/snapshots/2016/06/cmucl-src-2016-06.tar.bz2"
    sha256 "14fdfb571123df1d02520a97c7beecd253cc0c7f0ecbe9714b9014b216f20735"
  end

  def install
    ENV.m32
    (buildpath/"bootstrap").install resource("bootstrap")
    system "bin/build.sh", "-C", "",
           "-o", buildpath/"bootstrap/bin/lisp"
    system "bin/make-dist.sh", "-I", prefix,
           "-M", "share/man/man1", "darwin-4"
  end

  test do
    cmd = "#{bin}/lisp -batch -quiet -noinit -nositeinit "\
          "-eval '(write-line (write-to-string (+ 2 3)))' -eval '(quit)'"
    assert "5", shell_output(cmd)
  end
end
