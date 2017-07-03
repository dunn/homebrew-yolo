class Vcmi < Formula
  desc "Open-source engine for Heroes of Might and Magic III"
  homepage "https://vcmi.eu/"
  url "https://github.com/vcmi/vcmi/archive/0.99.tar.gz"
  sha256 "b7f2459d7e054c8bdcf419cbb80040e751d3dbb06dc1113ac28f7365930f902e"
  head "https://github.com/vcmi/vcmi.git", :branch => "develop"

  option "with-dmg", "Build as a .dmg with CPack"

  depends_on "cmake" => :build
  depends_on :xcode => :build

  depends_on "boost"
  depends_on "freetype"
  depends_on "ffmpeg"
  depends_on "innoextract"
  depends_on "libav"
  depends_on "libpng"
  depends_on "minizip"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "sdl2_mixer" => "with-smpeg2"
  depends_on "sdl2_ttf"

  def install
    xcodebuild "-project",
               "#{buildpath}/osx/osx-vcmibuilder/vcmibuilder.xcodeproj",
               "-configuration",
               "Release",
               "SYMROOT=build"
    (buildpath/"osx").install buildpath/"osx/osx-vcmibuilder/build/Release/vcmibuilder.app"

    args = if build.with? "dmg"
      %w[-G Xcode]
    else
      ["-G", "Unix Makefiles"]
    end

    args += [
      "-DFORCE_BUNDLED_FL=ON",
      "-DENABLE_LAUNCHER=OFF",
    ]

    if build.stable?
      args << "-DSPARKLE_FRAMEWORK=#{HOMEBREW_PREFIX}/Caskroom/sparkle/1.17.0/Sparkle.framework"
      args << "-DSPARKLE_INCLUDE_DIR=#{HOMEBREW_PREFIX}/Caskroom/sparkle/1.17.0/Sparkle.framework/Headers"

      inreplace "client/CMakeLists.txt",
                "cp ${CMAKE_HOME_DIRECTORY}/bin/$(CONFIGURATION)/libminizip.dylib ${BUNDLE_PATH}/MacOS/libminizip.dylib &&",
                ""
    end

    if build.with? "dmg"
      inreplace "client/CMakeLists.txt" do |s|
        s.gsub! "${CMAKE_BINARY_DIR}/build",
                "${CMAKE_BINARY_DIR}"
      end
    end

    mkdir "build" do
      system "cmake", "..", *(args + std_cmake_args)

      if build.with? "dmg"
        xcodebuild "-project",
                   "vcmi.xcodeproj",
                   "-configuration",
                   "Release",
                   "-target",
                   "package",
                   "SYMROOT=build"
      else
        make
      end
    end

    if build.with? "dmg"
      prefix.install "build/_CPack_Packages/Darwin/DragNDrop/vcmi-0.99/vcmiclient.app"
    else
      prefix.install "bin/vcmiclient.app"
    end
  end
end
