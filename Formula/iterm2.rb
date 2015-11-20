class Iterm2 < Formula
  desc "Modern terminal emulator for Mac OS X"
  homepage "https://iterm2.com"
  url "https://github.com/gnachman/iTerm2/archive/v2.1.1.tar.gz"
  sha256 "a803b11e5068cc9f0863084e001b86660451d8242334a50b85d060d791dbee0f"
  head "https://github.com/gnachman/iTerm2.git"

  depends_on :xcode => :build

  def install
    target = build.stable? ? "iTerm" : "iTerm2"
    xcodebuild "-parallelizeTargets", "-target", target, "-configuration", "Deployment"
    prefix.install "build/Deployment/iTerm2.app"
  end
end
