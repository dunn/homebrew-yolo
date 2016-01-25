class Openrefine < Formula
  desc "Tools for working with messy data"
  homepage "http://openrefine.org"
  url "https://github.com/OpenRefine/OpenRefine/archive/2.5.tar.gz"
  sha256 "bd1692093e9a34393fad6e06fc2113974f58d37b501f2542de934223692887a4"

  devel do
    url "https://github.com/OpenRefine/OpenRefine/archive/2.6-rc.2.tar.gz"
    version "2.6-rc.2"
    sha256 "0b790d0c43a88004874f1cfa298ad66388443b6ddb9392cc628fff84ee1a79cb"
  end

  def install
    ENV.java_cache
    system "./refine", "build"
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"refine", libexec/"unsign"
  end

  test do
    ENV.java_cache
    begin
      pid = fork do
        exec bin/"refine"
      end
      sleep 5
      system "curl", "127.0.0.1:3333"
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
