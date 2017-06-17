class Qi < Formula
  desc "Dependency manager for Common Lisp"
  homepage "https://github.com/CodyReichert/qi"
  url "https://github.com/CodyReichert/qi/archive/0.2.0.tar.gz"
  sha256 "f1e0119dda0e4a57dbe3ffd6e56eed68fc242c8835a14f0cb0148fd4b500e6ae"
  head "https://github.com/CodyReichert/qi.git"

  resource "manifest" do
    url "https://github.com/CodyReichert/qi-manifest.git"
  end

  def install
    doc.install Dir["docs/*"]

    prefix.install "asdf",
                   "dependencies",
                   "src",
                   Dir["*.lisp"],
                   Dir["*.asd"]

    libexec.install "bin/qi"
    (bin/"qi").write_env_script(libexec/"qi",
                                :QI_PREFIX => prefix)

    (pkgshare/"manfest").install resource("manifest")
  end
end
