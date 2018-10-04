self: super: {

   haskellEnv = (self.haskellPackages.override {
      overrides = hself: hsuper: with super.haskell.lib; with hsuper; {
        hasktags = dontCheck hasktags;
      };
   }).ghcWithHoogle(
    haskellPackages: with haskellPackages; [
      # libraries
      aeson
      attoparsec
      conduit
      hashable
      mtl
      microlens
      parsec
      
      # tools
      cabal-install
      ghcid
      hasktags
      hlint
      hindent
      structured-haskell-mode
      stylish-haskell
    ]);

  scalaEnv = self.buildEnv {
    name = "scala";
    paths = with self; [
      bloop
      scalafmt
      sbt
    ];
  };

  beamEnv = self.buildEnv {
    name = "beam";
    paths = with self; [
      elixir_1_7
    ] ++ (with beamPackages; [
      
    ]);
  };

  awsEnv = self.buildEnv {
    name = "aws";
    paths = with self; [
      awscli
      awslogs
    ];
  };

  nodeEnv = self.buildEnv {
    name = "node";
    paths = with self; [
      nodejs
      yarn
      nodePackages.prettier
    ];
  };
  
  clrEnv = self.buildEnv {
    name = "clr";
    paths = with self; [
      scalaEnv
      awsEnv
      nodeEnv
      codeship-jet
    ];
  };
  
}