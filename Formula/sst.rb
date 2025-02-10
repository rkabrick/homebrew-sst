class Sst < Formula
  desc "Structural Simulation Toolkit (SST) Core and Elements"
  homepage "https://github.com/sstsimulator"

  # Stable release from a tarball
  url "https://github.com/sstsimulator/sst-core/releases/download/v14.1.0_Final/sstcore-14.1.0.tar.gz"
  version "14.1.0"

  # HEAD build: clone the latest source from the main branch
  head do
    url "https://github.com/sstsimulator/sst-core.git", branch: "main"
  end

  resource "sst-elements" do
    # Stable release for sst-elements
    url "https://github.com/sstsimulator/sst-elements/releases/download/v14.1.0_Final/sstelements-14.1.0.tar.gz"
    version "14.1.0"
    # HEAD build for sst-elements: clone from the main branch
    head "https://github.com/sstsimulator/sst-elements.git", branch: "main"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build
  depends_on "ncurses"  => :build
  depends_on "python"   => :build

  def install
    system "./configure", "--enable-debug",
                          "--enable-profile",
                          "--disable-mpi",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "-j#{ENV.make_jobs}"
    system "make", "install"

    resource("sst-elements").stage do
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
