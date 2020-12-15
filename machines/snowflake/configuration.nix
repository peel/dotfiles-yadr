{ pkgs
, config
, lib
, ...
}:

(import ../../setup/darwin { inherit config pkgs; }) // {
  peel.setup.host = "snowflake";
}
