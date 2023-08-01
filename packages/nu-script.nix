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
      pathDecl =
        if pkgs.lib.versionAtLeast pkgs.nushell.version "0.83.0" then
          "$env.PATH"
        else
          "let-env PATH";
    in
    fun name ''
      #!${pkgs.nushell}/bin/nu
      ${pathDecl} = ($env.PATH | append ('${binPath}' | split row ":"))
      ${content}
    '';
in
{
  writeNuScript = writeScript pkgs.writeScript;
  writeNuScriptBin = writeScript pkgs.writeScriptBin;
}
