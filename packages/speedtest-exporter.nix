{
  lib,
  fetchFromGitHub,
  python3Packages,
  makeWrapper,
  ookla-speedtest,
}:

python3Packages.buildPythonApplication rec {
  pname = "speedtest-exporter";
  version = "3.5.4";

  format = "py";

  src = fetchFromGitHub {
    owner = "MiguelNdeCarvalho";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-x2vFdWAzr1qWNdv/LVNnA5Tlk4AtDYoUZAUOoqP1o5g=";
  };

  propagatedBuildInputs = with python3Packages; [
    flask
    prometheus-client
    waitress
    werkzeug
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  dontWrapPythonPrograms = true;

  installPhase = ''
    runHook preInstall

    # Install the python script into the site-packages directory
    install -Dm644 $src/src/exporter.py $out/${python3Packages.python.sitePackages}/speedtest_exporter.py

    mkdir -p $out/bin
    makeWrapper ${python3Packages.python}/bin/python $out/bin/speedtest-exporter \
      --add-flags "$out/${python3Packages.python.sitePackages}/speedtest_exporter.py" \
      --prefix PATH : ${lib.makeBinPath [ ookla-speedtest ]} \
      --prefix PYTHONPATH : "$PYTHONPATH"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Prometheus exporter for Ookla Speedtest results";
    homepage = "https://github.com/MiguelNdeCarvalho/speedtest-exporter";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = ookla-speedtest.meta.platforms;
  };
}
