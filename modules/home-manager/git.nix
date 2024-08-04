{ lib, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matthew Booe";
    userEmail = "mirdaki@users.noreply.github.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    };
  };
}
