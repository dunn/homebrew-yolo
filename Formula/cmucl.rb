class Cmucl < Formula
  desc "High-performance, free Common Lisp implementation"
  homepage "https://www.cons.org/cmucl/"
  url "https://common-lisp.net/project/cmucl/downloads/release/21b/cmucl-src-21b.tar.bz2"
  sha256 "6f9ea5920d38d6881cee85d976565b3a6070bf6473dd64254e0e9f2f23625875"
  head "https://gitlab.common-lisp.net/cmucl/cmucl.git"

  resource "bootstrap" do
    url "https://common-lisp.net/project/cmucl/downloads/snapshots/2017/01/cmucl-2017-01-x86-darwin.tar.bz2"
    sha256 "a458035577a7c5893f36da457087679999a3e472b0ad0fd3ad122a35630061a7"
  end

  devel do
    url "https://common-lisp.net/project/cmucl/downloads/snapshots/2017/01/cmucl-src-2017-01.tar.bz2"
    sha256 "1b6b813eca3d48652ca69529ffc4819598e3d0e21ac76f74c66a928bd7bfd062"
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
