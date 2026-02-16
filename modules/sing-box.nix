{ pkgs, lib, ... }:
let
  # 1. Define your configuration as a Nix Attribute Set
  # We use placeholders like $VPS_IP which envsubst will replace later.
  singboxSettings = {
    log = {
      level = "info";
      timestamp = true;
    };
    dns = {
      servers = [
        { tag = "dns-remote"; type = "udp"; server = "1.1.1.1"; }
        { tag = "dns-direct"; type = "tcp"; server = "1.1.1.1"; }
        { tag = "dns-local"; type = "local"; }
      ];
      rules = [
        { domain = [ "$VPS_IP" ]; server = "dns-direct"; }
      ];
      strategy = "prefer_ipv4";
      final = "dns-remote";
      independent_cache = true;
    };
    inbounds = [{
      type = "tun";
      address = [ "172.19.0.1/28" ];
      auto_route = true;
      endpoint_independent_nat = true;
      stack = "gvisor";
    }];
    outbounds = [
      {
        type = "selector";
        tag = "select";
        outbounds = [ "auto" "hysteria-out" ];
        default = "auto";
        interrupt_exist_connections = true;
      }
      {
        type = "urltest";
        tag = "auto";
        outbounds = [ "hysteria-out" ];
        url = "http://cp.cloudflare.com";
        interval = "10m0s";
        tolerance = 1;
        idle_timeout = "30m0s";
        interrupt_exist_connections = true;
      }
      {
        type = "hysteria2";
        tag = "hysteria-out";
        server = "$VPS_IP";
        server_port = 443; # Envsubst handles these as strings
        password = "$AUTH_PASSWORD";
        up_mbps = 50;
        down_mbps = 100;
        tls = {
          enabled = true;
          server_name = "$SNI_NAME";
          insecure = true;
        };
        obfs = {
          type = "salamander";
          password = "$OBFS_PASSWORD";
        };
      }
      { type = "direct"; tag = "direct"; }
      { type = "direct"; tag = "bypass"; }
      { type = "block"; tag = "block"; }
    ];
    route = {
      rules = [
        { action = "sniff"; }
        { protocol = "dns"; action = "hijack-dns"; }
        { ip_is_private = true; outbound = "bypass"; }
        {
          rule_set = [ "geosite-ads" "geosite-malware" "geosite-phishing" "geosite-cryptominers" "geoip-malware" "geoip-phishing" ];
          outbound = "block";
        }
        { domain_suffix = [ ".ru" ".by" ]; outbound = "direct"; }
        { rule_set = [ "geoip-ru" "geosite-ru" ]; outbound = "direct"; }
      ];
      rule_set = [
        { type = "remote"; tag = "geosite-ads"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geosite-category-ads-all.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geosite-malware"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geosite-malware.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geosite-phishing"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geosite-phishing.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geosite-cryptominers"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geosite-cryptominers.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geoip-phishing"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geoip-phishing.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geoip-malware"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/block/geoip-malware.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geoip-ru"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/country/geoip-ru.srs"; update_interval = "120h0m0s"; }
        { type = "remote"; tag = "geosite-ru"; format = "binary"; url = "https://raw.githubusercontent.com/hiddify/hiddify-geo/rule-set/country/geosite-ru.srs"; update_interval = "120h0m0s"; }
      ];
      final = "select";
      auto_detect_interface = true;
    };
    experimental = {
      cache_file = { enabled = true; path = "clash.db"; };
      clash_api = {
        external_controller = "127.0.0.1:16756";
        secret = "$CLASH_SECRET";
      };
    };
  };

  # 2. Convert that Nix set into a JSON file in the Nix Store
  singboxConfigFile = pkgs.writeText "sing-box-config.json" (builtins.toJSON singboxSettings);

in {
  services.sing-box.enable = true;

  systemd.services.sing-box = {
    # Ensure the service waits for network
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      # 1. Access to /home is blocked by default in the official module.
      # This is critical to read your .env file.
      ProtectHome = lib.mkForce false;
      ProtectSystem = lib.mkForce "soft";
      PrivateTmp = lib.mkForce false;

      # 2. Disable the module's default non-root user settings
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
      DynamicUser = lib.mkForce false;

      # 3. Use StateDirectory (/var/lib/sing-box) instead of RuntimeDirectory.
      # It is more persistent and easier to debug than /run.
      StateDirectory = "sing-box";
      StateDirectoryMode = "0700";

      # 4. Update the script to use /var/lib/sing-box
      ExecStartPre = lib.mkForce [
        (pkgs.writeShellScript "setup-singbox-conf" ''
          # No need to mkdir, StateDirectory creates it
          ${pkgs.envsubst}/bin/envsubst -i ${singboxConfigFile} -o /var/lib/sing-box/config.json
          chmod 600 /var/lib/sing-box/config.json
        '').outPath
      ];

      # 5. Point ExecStart to the file in /var/lib/sing-box
      ExecStart = lib.mkForce [ 
        "" 
        "${pkgs.sing-box}/bin/sing-box run -c /var/lib/sing-box/config.json" 
      ];
      
      # 6. Inherit environment for envsubst
      EnvironmentFile = "/home/aleh/Sync/singbox.env";
    };
  };
}
