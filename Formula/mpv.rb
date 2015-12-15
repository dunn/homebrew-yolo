class Mpv < Formula
  desc "Video player based on MPlayer/mplayer2"
  homepage "http://mpv.io/"
  url "https://github.com/mpv-player/mpv/archive/v0.14.0.tar.gz"
  sha256 "042937f483603f0c3d1dec11e8f0045e8c27f19eee46ea64d81a3cdf01e51233"

  depends_on "ffmpeg"
  depends_on "jpeg"
  depends_on "libass"
  depends_on "openssl"
  depends_on :x11

  resource "waf" do
    url "https://waf.io/waf-1.8.12"
    sha256 "01bf2beab2106d1558800c8709bc2c8e496d3da4a2ca343fe091f22fca60c98b"
  end

  def install
    buildpath.install resource("waf")
    system "python", "waf-1.8.12", "configure", "--prefix=#{prefix}"
    system "python", "waf-1.8.12", "build"
    system "python", "waf-1.8.12", "install"
  end
end
