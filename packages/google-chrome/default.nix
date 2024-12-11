{
  lib,
  stdenvNoCC,
  darwin,
  fetchurl,
  _7zz,
}:

let
  sources = import ./sources.nix;
in
stdenvNoCC.mkDerivation {
  pname = "google-chrome";
  version = sources.version;

  src = fetchurl {
    url = sources.url;
    sha256 = sources.hash;
  };

  nativeBuildInputs = [
    _7zz
  ] ++ lib.optionals stdenvNoCC.hostPlatform.isAarch64 [ darwin.autoSignDarwinBinariesHook ];

  unpackPhase = ''
    runHook preUnpack

    7zz e -y $src "Google Chrome/Google Chrome.app"

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -a "Google Chrome.app" $out/Applications

    runHook postInstall
  '';
  
  meta = {
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
