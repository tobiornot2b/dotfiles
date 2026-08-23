{ pkgs }:

let
  pdfSpread = pkgs.writeShellApplication {
    name = "pdf-spread";
    runtimeInputs = with pkgs; [ poppler-utils imagemagick img2pdf gawk ];
    text = builtins.readFile ./pdf-spread.sh;
  };
in
pkgs.mkShell {
  packages = [ pdfSpread pkgs.poppler-utils pkgs.imagemagick pkgs.img2pdf ];
}
