class Openrefine < Formula
  desc "Tools for working with messy data"
  homepage "http://openrefine.org"
  url "https://github.com/OpenRefine/OpenRefine/releases/download/3.3/openrefine-linux-3.3.tar.gz"
  sha256 "49ac55c6a39b08e4213a2f5c837b8967302401384bceed27cc95de6dc0fe6087"

  def install
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
