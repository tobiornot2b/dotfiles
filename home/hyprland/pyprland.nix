{ pkgs, ...}: {
	home.packages = with pkgs; [ pyprland ];

	home.file.".config/hypr/pyprland.toml".text = ''
	  [pyprland]
	  plugins = [
	    "scratchpads"
	  ]

	  [scratchpads.logseq]
	  command = "logseq"
	  class = "Logseq"
	  size = "80% 80%"
	  position = "150px 150px"
	'';

}
