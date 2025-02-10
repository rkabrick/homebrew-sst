class Sst < Formula
  desc "Structural Simulation Toolkit (SST) Core and Elements"
  homepage "https://github.com/sstsimulator"

  # Stable tarball for sst-core
  url "https://github.com/sstsimulator/sst-core/releases/download/v14.1.0_Final/sstcore-14.1.0.tar.gz"
  version "14.1.0"

  # HEAD build for sst-core: clone from the main branch
  head do
    url "https://github.com/sstsimulator/sst-core.git", branch: "main"
  end

  resource "sst-elements" do
    if ARGV.build_head?
      # For HEAD builds, clone via Git from the main branch.
      url "https://github.com/sstsimulator/sst-elements.git", using: :git, branch: "main"
    else
      # Stable tarball for sst-elements.
      url "https://github.com/sstsimulator/sst-elements/releases/download/v14.1.0_Final/sstelements-14.1.0.tar.gz"
      version "14.1.0"
    end
  end

  depends_on "autoconf"  => :build
  depends_on "automake"  => :build
  depends_on "libtool"   => :build
  depends_on "ncurses"   => :build
  depends_on "python"    => :build

  def install
    # Run autogen.sh for HEAD builds (stable tarballs already include configure)
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
      system "./autogen.sh" if build.head?
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
    assert_match version.to_s, shell_output("#{bin}/sst --version")
    system "#{bin}/sst-info", "-q"
  end
end
