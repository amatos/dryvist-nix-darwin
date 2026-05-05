{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
  gzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cribl-edge";
  version = "4.17.0-7e952fa7"; # cribl-edge

  src = fetchurl {
    url = "https://cdn.cribl.io/dl/4.17.0/cribl-${version}-darwin-universal.pkg";
    hash = "sha256-A9oKAVzMCAW3cIcJpYTyu3EXmOrZLA5pPxv3FZyUbLY=";
  };

  nativeBuildInputs = [
    xar
    cpio
    gzip
  ];

  unpackPhase = ''
    xar -xf $src
    cat Payload | gzip -d | cpio -id
  '';

  installPhase = ''
    mkdir -p $out/opt/cribl
    cp -r cribl/* $out/opt/cribl/
  '';

  meta = {
    description = "Cribl Edge — streaming observability agent";
    homepage = "https://cribl.io/cribl-edge/";
    license = lib.licenses.unfree;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
