# coding: utf-8
class Emojify < Formula
  desc "Emoji on the command line 😱"
  homepage "https://github.com/mrowa44/emojify"
  url "https://github.com/mrowa44/emojify/archive/v1.0.0.tar.gz"
  sha256 "fabefc4767428a2634a77e7845e315725b75b50f282d0943c5b65789650c25d1"
  head "https://github.com/mrowa44/emojify.git"

  def install
    bin.install "emojify"
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_equal "I'm a 🐱 ", pipe_output("#{bin}/emojify", "I'm a :cat:").chomp
  end
end
