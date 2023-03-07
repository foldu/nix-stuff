{ pkgs, lib, ... }:
let
  writeScript = fun:
    { name
    , path ? [ ]
    , source ? null
    , file ? null
    }:
    let
      content = if file != null then builtins.readFile file else source;
      binPath = lib.strings.makeBinPath path;
    in
    fun name ''
      #!${pkgs.nushell}/bin/nu
      let-env PATH = ($env.PATH | append ('${binPath}' | split row ":"))
      ${content}
    '';
in
{
  writeNuScript = writeScript pkgs.writeScript;
  writeNuScriptBin = writeScript pkgs.writeScriptBin;
}
