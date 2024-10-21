class SstAT1310 < Formula
  desc "Structural Simulation Toolkit (SST) Core and Elements"
  homepage "https://github.com/sstsimulator"
  url "https://github.com/sstsimulator/sst-core/releases/download/v13.1.0_Final/sstcore-13.1.0.tar.gz"
  version "13.1.0"

  resource "sst-elements" do
    url "https://github.com/sstsimulator/sst-elements/releases/download/v13.1.0_Final/sstelements-13.1.0.tar.gz"
    version "13.1.0"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "ncurses" => :build
  depends_on "python" => :build

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
