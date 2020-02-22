class DotnetSdk < Formula
  desc "Core functionality needed to create .NET Core projects, that is shared between Visual Studio and CLI"
  homepage "https://dot.net/core"
  url "https://github.com/dotnet/sdk.git",
      :tag => "v3.0.103",
      :revision => "316fbdd10e8829faaf9157ecbb05795e75b618f7"
  sha256 "d53489ee4a8363ff6bc7638611245b6ccf5f492430ccbe87a564a0838812e6b4"

  resource "boot-sdk" do
    url "https://dotnetcli.azureedge.net/dotnet/Sdk/3.0.103-servicing-014446/dotnet-sdk-3.0.103-servicing-014446-osx-x64.tar.gz"
    sha256 "248c4911ff39e26563d2748758b2a39eb2dcc833a01be2d957fdbd046a59624e"
  end

  resource "boot-runtime-1.0.5" do
    url "https://dotnetcli.azureedge.net/dotnet/Runtime/1.0.5/dotnet-osx-x64.1.0.5.tar.gz"
    sha256 "86228ed7ba5f4eb14565104e85f30a3ccc01c544865cdf573b3edfba1cd3bf80"
  end

  resource "boot-runtime-1.1.2" do
    url "https://dotnetcli.azureedge.net/dotnet/Runtime/1.1.2/dotnet-osx-x64.1.1.2.tar.gz"
    sha256 "620a98213e423301fa44abfc1ca0b15e0bc538e676cbf0344c711abef5ed4231"
  end

  resource "boot-runtime-2.1.0" do
    url "https://dotnetcli.azureedge.net/dotnet/Runtime/2.1.0/dotnet-runtime-2.1.0-osx-x64.tar.gz"
    sha256 "075cacb4535656e9fa64adffd1e7cd4b9471b1a06e4d74eb84079c924d7b37f1"
  end

  resource "boot-runtime-2.2.8" do
    url "https://dotnetcli.azureedge.net/dotnet/Runtime/2.2.8/dotnet-runtime-2.2.8-osx-x64.tar.gz"
    sha256 "8ed296058c0de9e2c8c4224546ef9b1669b669cc731937d31bb0dc710d6b45db"
  end

  resource "boot-runtime-2.2.8" do
    url "https://dotnetcli.azureedge.net/dotnet/Runtime/2.2.8/dotnet-runtime-2.2.8-osx-x64.tar.gz"
    sha256 "8ed296058c0de9e2c8c4224546ef9b1669b669cc731937d31bb0dc710d6b45db"
  end

  def install
    resource("boot-sdk").stage(buildpath/".dotnet")
    resource("boot-runtime-1.0.5").stage(buildpath/".dotnet/shared/Microsoft.NETCore.App/1.0.5")
    resource("boot-runtime-1.1.2").stage(buildpath/".dotnet/shared/Microsoft.NETCore.App/1.1.2")
    resource("boot-runtime-2.1.0").stage(buildpath/".dotnet/shared/Microsoft.NETCore.App/2.1.0")
    resource("boot-runtime-2.2.8").stage(buildpath/".dotnet/shared/Microsoft.NETCore.App/2.2.8")
    mv ".dotnet/sdk/3.0.103", ".dotnet/sdk/3.0.103-servicing-014446"
    ENV.prepend_path "PATH", buildpath/".dotnet"

    system "bash", "-x", "./eng/common/build.sh", "--configuration", "Release", "--restore", "--build"

    prefix.install Dir["*"]
  end

  test do
    system "false"
  end
end
