class Sst < Formula
  desc "Structural Simulation Toolkit (SST) Core and Elements"
  homepage "https://github.com/sstsimulator"

  # Stable release tarball for sst-core
  url "https://github.com/sstsimulator/sst-core/releases/download/v15.1.1_Final/sstcore-15.1.1.tar.gz"
  version "15.1.1"

  # HEAD build for sst-core: clone from master branch
  head do
    url "https://github.com/sstsimulator/sst-core.git", branch: "master"
  end

  resource "sst-elements" do
    if ARGV.include?("--HEAD")
      url "https://github.com/sstsimulator/sst-elements.git", using: :git, branch: "master"
    else
      url "https://github.com/sstsimulator/sst-elements/releases/download/v15.1.0_Final/sstelements-15.1.0.tar.gz"
      version "15.1.1"
    end
  end

  depends_on "autoconf"  => :build
  depends_on "automake"  => :build
  depends_on "libtool"   => :build
  depends_on "ncurses"   => :build
  depends_on "python"    => :build

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--enable-debug",
                          "--enable-profile",
                          "--disable-mpi",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "-j#{ENV.make_jobs}"
    system "make", "install"

    resource("sst-elements").stage do
      system "./autogen.sh" if ARGV.include?("--HEAD")
      system "./configure", "--enable-debug",
                            "--enable-profile",
                            "--disable-mpi",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}",
                            "--with-sst-core=#{prefix}"
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  test do
    # Verify that the installed binary prints its version.
    assert_match version.to_s, shell_output("#{bin}/sst --version")
    system "#{bin}/sst-info", "-q"
  end
end
