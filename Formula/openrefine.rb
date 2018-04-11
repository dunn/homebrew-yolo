class Openrefine < Formula
  desc "Tools for working with messy data"
  homepage "http://openrefine.org"
  url "https://github.com/OpenRefine/OpenRefine/archive/2.8.tar.gz"
  sha256 "a7e00b404d7d11f2da7f01977e4e920c23e227c7f025cc2593c17a088d62da33"

  def install
    system "./refine", "build"
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"refine", libexec/"unsign"
  end

  test do
    begin
      pid = fork do
        exec bin/"refine"
      end
      sleep 5
      system "curl", "127.0.0.1:3333"
      sleep 5
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
