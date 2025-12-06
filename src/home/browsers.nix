{ inputs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.librewolf = {
    languagePacks = [ "en-GB" ];
  };
}
