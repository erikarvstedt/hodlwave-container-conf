{
  containers.btc-regtest =
    let
      nix-bitcoin = builtins.fetchTarball {
        url = "https://github.com/fort-nix/nix-bitcoin/archive/v0.0.73.tar.gz";
        sha256 = "sha256-E9z3KTOZOVCzwtcF2jLExpZpFtAwrDm+f1cCVjH8NQM=";
      };

      regtestPort = 18443;
    in
    {
      extra = {
        addressPrefix = "10.250.0";
        # Always allow connections from hostAddress
        firewallAllowHost = true;
        # Make the container's localhost reachable via localAddress
        exposeLocalhost = true;
      };
      config =
        { config, pkgs, lib, ... }: {
          imports = [
            "${nix-bitcoin}/modules/modules.nix"
          ];

          # To login to the container as "operator"
          # $ sudo nixos-container login btc-regtest
          users.users.operator = {
            isNormalUser = true;
            home = "/home/operator";
            password = "<YOUR_PASSWORD_HERE>";
          };

          # Automatically generate all secrets required by services.
          # The secrets are stored in /etc/nix-bitcoin-secrets
          nix-bitcoin.generateSecrets = true;

          # Enable some services.
          # See ./configuration.nix for all available features.
          services.bitcoind = {
            enable = true;
            regtest = true;
            disablewallet = false;
            rpc = {
              port = regtestPort;
              allowip = [ "127.0.0.1" "10.250.0.0/16" ];
            };
          };

          # Enable interactive access to nix-bitcoin features (like bitcoin-cli) for
          # your system's main user
          nix-bitcoin.operator = {
            enable = true;
            name = "operator";
          };

          # Prevent garbage collection of the nix-bitcoin source
          system.extraDependencies = [ nix-bitcoin ];

          # networking
          networking.firewall.allowedTCPPorts = [ regtestPort ];
        };
    };
}
'+
