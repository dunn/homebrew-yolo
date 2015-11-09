class MicroParserCombinators < Formula
  desc "Parser Combinator library for C"
  homepage "https://github.com/orangeduck/mpc"
  url "https://github.com/orangeduck/mpc/archive/0.8.7.tar.gz"
  sha256 "1eeee4cbbd85d5e76d1c3b1e5b1501a8a5878c4fe44ad72c8957b89c336ddeba"
  head "https://github.com/orangeduck/mpc.git"

  keg_only "Conflicts with libmpc"

  patch do
    url "https://github.com/orangeduck/mpc/pull/38.patch"
    sha256 "1fb0b99f6acc1817a61446822eb1eef32e525a835b20bc502c406a0b600206d4"
  end

  def install
    system "make", "install", "prefix=#{prefix}", "CC=#{ENV.cc}"
  end
end
