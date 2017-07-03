class ClaspCl < Formula
  desc "Common Lisp implementation built on LLVM"
  homepage "https://github.com/drmeister/clasp/tree/testing"
  url "https://github.com/drmeister/clasp.git", :branch => "testing"
  version "0.5-pre"

  depends_on "cmake" => :build
  depends_on "sbcl" => :build
  depends_on "bdw-gc"
  depends_on "boost"

  resource "externals" do
    url "https://github.com/drmeister/externals-clasp.git"
  end

  def install
    (buildpath/"externals").install resource("externals")
    cd "externals" do
      system "make"
    end

    (buildpath/"wscript.config").write <<-EOS.undent
      EXTERNALS_CLASP_DIR = "#{buildpath}/externals"
      INSTALL_PATH_PREFIX = "#{prefix}"
    EOS

    system "./waf", "configure", "update_submodules", "build_cboehm"
  end

  test do
  end
end
