class PassGitHelper < Formula
  include Language::Python::Virtualenv

  desc "Git credential helper for password-store"
  homepage "https://github.com/languitar/pass-git-helper"
  url "https://github.com/languitar/pass-git-helper/archive/release-0.3.tar.gz"
  sha256 "d0b0ffa40e609eddabef2f00153af06064a5985be4cc17c8c22d97422dce0760"
  head "https://github.com/languitar/pass-git-helper.git"

  depends_on :python3

  resource "pyxdg" do
    url "https://files.pythonhosted.org/packages/26/28/ee953bd2c030ae5a9e9a0ff68e5912bd90ee50ae766871151cd2572ca570/pyxdg-0.25.tar.gz"
    sha256 "81e883e0b9517d624e8b0499eb267b82a815c0b7146d5269f364988ae031279d"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: pass-git-helper [-h] [-m MAPPING_FILE] [-l] ACTION",
                 shell_output("#{bin}/pass-git-helper 2>&1", 2)
  end
end
