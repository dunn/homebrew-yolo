class Rdf < Formula
  desc "Multi-tool for doing Semantic Web jobs on the command-line."
  homepage "https://github.com/seebi/rdf.sh"
  url "https://github.com/seebi/rdf.sh/archive/v0.7.0.tar.gz"
  sha256 "3210042265082092540e698202f6aa1a7dadefff97924c23ea9e2da18a8fa94b"
  head "https://github.com/seebi/rdf.sh.git"

  depends_on "raptor"
  depends_on "rasqal"

  def install
    bin.install "rdf"
    man1.install "rdf.1"
    zsh_completion.install "_rdf"
  end

  test do
    system bin/"rdf", "ns", "foaf"
  end
end
