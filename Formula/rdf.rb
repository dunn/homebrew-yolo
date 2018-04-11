class Rdf < Formula
  desc "Multi-tool for doing Semantic Web jobs on the command-line"
  homepage "https://github.com/seebi/rdf.sh"
  url "https://github.com/seebi/rdf.sh/archive/v0.8.1.tar.gz"
  sha256 "b43624b33d1ba074f1976c93c18db4e3b94cd9a82a80ba8a34922c3c778b81d1"
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
