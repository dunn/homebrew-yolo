class Timeout < Formula
  desc "Resource monitoring program for Linux processes"
  homepage "https://github.com/pshved/timeout"
  head "https://github.com/pshved/timeout.git"

  def install
    bin.install "timeout"
  end

  def caveats; <<-EOS.undent
    Due to how process monitoring differs between Linux and OSX, timeout does not work on OSX.
  EOS
  end

  test do
    system bin/"timeout", "-t", "2", "ping", "0.0.0.0"
  end
end
