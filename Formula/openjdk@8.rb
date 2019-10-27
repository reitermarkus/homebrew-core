class OpenjdkAT8 < Formula
  desc "Development kit for the Java programming language"
  homepage "https://openjdk.java.net/"
  url "https://hg.openjdk.java.net/jdk8u/jdk8u/archive/jdk8u252-b02.tar.bz2"
  version "1.8.0_252-b02"
  sha256 "911dc51f59797af6b0fcf45a883b92b582f6f81262d681c8a5a9f79cbfd6c926"

  keg_only :versioned_formula

  depends_on "autoconf" => :build
  depends_on "freetype"

  resource "boot-jdk" do
    url "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jdk_x64_mac_hotspot_8u232b09.tar.gz"
    sha256 "c237b2c2c32c893e4ee60cdac8c4bcc34ca731a5445986c03b95cf79918e40c3"
  end

  resource "corba" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/corba/archive/jdk8u252-b02.tar.bz2"
    sha256 "b11b896a0e50b6754165877773eb69b86f0540ac97af52fef6e724852eb2a90f"
  end

  resource "jaxp" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/jaxp/archive/jdk8u252-b02.tar.bz2"
    sha256 "b60f8ec6ac85fa64671ef8c08254a67a8ecf71380bfcc42b35dd85f5ab50b1cc"
  end

  resource "jaxws" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/jaxws/archive/jdk8u252-b02.tar.bz2"
    sha256 "ac01d30a1f6d42728de6adda7506821c581a32cfa4f5483a8163cf87ea3acb8f"
  end

  resource "langtools" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/langtools/archive/jdk8u252-b02.tar.bz2"
    sha256 "8cf3858575f5b85bbf843bc512c9da7eea8557512da964d45c24bb15ba56bca7"
  end

  resource "hotspot" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/hotspot/archive/jdk8u252-b02.tar.bz2"
    sha256 "9ed72ee515074004067ea204f66eb77e338d7c4c065fc39f3b14aa0386e326bd"

    patch :p1 do
      url "https://raw.githubusercontent.com/stooke/jdk8u-xcode10/98188e462363f036b947d523300c6cb166ebbc12/jdk8u-patch/mac-jdk8u-hotspot.patch"
      sha256 "f3fd7580561490e67fa25bb3a0c735908ba15c7b63a71684eb2d6e954d1f54cd"
    end
  end

  resource "nashorn" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/nashorn/archive/jdk8u252-b02.tar.bz2"
    sha256 "9e72e9fe1510adfa15fdfdb4488a1cec02b034a0f0a86b00f0346468374655b2"
  end

  resource "jdk" do
    url "https://hg.openjdk.java.net/jdk8u/jdk8u/jdk/archive/jdk8u252-b02.tar.bz2"
    sha256 "94cb9c12e1163dfa6fd99f74446d52d4520011d22f12abc12bc15d9efcd45519"

    patch :p1 do
      url "https://raw.githubusercontent.com/stooke/jdk8u-xcode10/98188e462363f036b947d523300c6cb166ebbc12/jdk8u-patch/mac-jdk8u-jdk.patch"
      sha256 "acf7a8d30ed2b871ceb8aa3a0c313e0a09a02f24c490ef983cc007db45c82cda"
    end
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/stooke/jdk8u-xcode10/98188e462363f036b947d523300c6cb166ebbc12/jdk8u-patch/mac-jdk8u.patch"
    sha256 "f57df82e914dd315ccf7714d874f5d7c0774893ed28e0aa09900e82496241d9d"
  end

  def install
    boot_jdk_dir = buildpath/"boot-jdk"
    resource("boot-jdk").stage boot_jdk_dir
    boot_jdk = boot_jdk_dir/"Contents/Home"
    java_options = ENV.delete("_JAVA_OPTIONS")

    %w[corba jaxp jaxws langtools hotspot nashorn jdk].each do |r|
      resource(r).stage "#{buildpath}/#{r}"
    end

    short_version, _, build = version.to_s.rpartition("-")
    _, update, = version.to_s.split(/[_\-]/)

    chmod 0755, "configure"
    freetype = Formula["freetype"]
    system "./configure", "--with-milestone=fcs",
                          "--with-update-version=#{update}",
                          "--with-build-number=#{build}",
                          "--with-toolchain-path=/usr/bin",
                          "--with-extra-ldflags=-headerpad_max_install_names",
                          "--with-boot-jdk=#{boot_jdk}",
                          "--with-boot-jdk-jvmargs=#{java_options}",
                          "--with-debug-level=release",
                          "--with-native-debug-symbols=none",
                          "--with-jvm-variants=server",
                          "--with-freetype=#{freetype.opt_prefix}",
                          "--with-freetype-include=#{freetype.opt_include}/freetype2",
                          "--with-freetype-lib=#{freetype.opt_lib}",
                          "--with-toolchain-type=clang",
                          "--disable-precompiled-headers"

    ENV["MAKEFLAGS"] = "JOBS=#{ENV.make_jobs}"
    system "make", "images", "COMPILER_WARNINGS_FATAL=false"
    system "make", "test", "TEST=tier1"

    libexec.install "build/macosx-x86_64-normal-server-release/images/j2sdk-bundle/jdk#{short_version}.jdk" => "openjdk.jdk"
    bin.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/bin/*"]
    include.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/include/*.h"]
    include.install_symlink Dir["#{libexec}/openjdk.jdk/Contents/Home/include/darwin/*.h"]
  end

  def caveats
    <<~EOS
      For the system Java wrappers to find this JDK, symlink it with
        sudo ln -sfn #{opt_libexec}/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-8.jdk
    EOS
  end

  test do
    (testpath/"HelloWorld.java").write <<~EOS
      class HelloWorld {
        public static void main(String args[]) {
          System.out.println("Hello, world!");
        }
      }
    EOS

    system bin/"javac", "HelloWorld.java"

    assert_match "Hello, world!", shell_output("#{bin}/java HelloWorld")
  end
end
