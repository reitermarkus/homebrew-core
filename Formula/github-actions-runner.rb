class GithubActionsRunner < Formula
  desc "The Runner for GitHub Actions :rocket:"
  homepage "https://github.com/actions/runner"
  url "https://github.com/actions/runner.git",
      :tag      => "v2.165.2",
      :revision => "745b90a8b27fe9e2d13ec08a17890597a7582899"

  depends_on "node@12"

  def install
    ENV.prepend_path "PATH", "/usr/local/share/dotnet"

    cd "src" do
      inreplace "Misc/layoutbin/runsvc.sh", "./externals/node12/bin", Formula["node@12"].opt_bin

      inreplace "Runner.Listener/Runner.cs" do |s|
        s.gsub! ".{separator}config.{ext}", "github-actions-runner-config"
        s.gsub! ".{separator}run.{ext}", "github-actions-runner-run"

        s.gsub! "(autoUpdateInProgress", "(false"
      end

      system "dotnet", "msbuild", "-t:layout", "-p:PackageRuntime=osx-x64", "-p:BUILDCONFIG=Release", "-p:RunnerVersion=#{version}",
             "./dir.proj"
    end

    cd "_layout" do
      rm_rf "_diag"
      rm Dir["bin/**/*.pdb"]
      rm "bin/installdependencies.sh"
      libexec.install Dir["*"]
    end

    bin.install_symlink libexec/"config.sh" => "github-actions-runner-config"
    bin.install_symlink libexec/"run.sh" => "github-actions-runner-run"
  end

  test do
    system "#{bin}/github-actions-runner-run", "--help"
  end
end
