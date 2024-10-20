{ config, lib, ... }:

let
  vhostOptions =
    { config, ... }:
    {
      options = {
        enableAuthelia = lib.mkEnableOption "Enable authelia location";
      };
      config = lib.mkIf config.enableAuthelia {
        locations."/authelia".extraConfig = ''
          ## Essential Proxy Configuration
          internal;
          proxy_pass https://auth.codecaptured.com/api/verify;

          ## Headers
          ## The headers starting with X-* are required.
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Original-Method $request_method;
          proxy_set_header X-Forwarded-Method $request_method;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Content-Length "";
          proxy_set_header Connection "";

          ## Basic Proxy Configuration
          proxy_pass_request_body off;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
          proxy_redirect http:// $scheme://;
          proxy_http_version 1.1;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;
          proxy_buffers 4 32k;
          client_body_buffer_size 128k;

          ## Advanced Proxy Configuration
          send_timeout 5m;
          proxy_read_timeout 240;
          proxy_send_timeout 240;
          proxy_connect_timeout 240;
        '';
        locations."/".extraConfig = ''
          ## Send a subrequest to Authelia to verify if the user is authenticated and has permission to access the resource.
          auth_request /authelia;

          ## Set the $target_url variable based on the original request.

          ## Comment this line if you're using nginx without the http_set_misc module.
          # set_escape_uri $target_url $scheme://$http_host$request_uri;

          ## Uncomment this line if you're using NGINX without the http_set_misc module.
          set $target_url $scheme://$http_host$request_uri;

          ## Save the upstream response headers from Authelia to variables.
          auth_request_set $user $upstream_http_remote_user;
          auth_request_set $groups $upstream_http_remote_groups;
          auth_request_set $name $upstream_http_remote_name;
          auth_request_set $email $upstream_http_remote_email;

          ## Inject the response headers from the variables into the request made to the backend.
          proxy_set_header Remote-User $user;
          proxy_set_header Remote-Groups $groups;
          proxy_set_header Remote-Name $name;
          proxy_set_header Remote-Email $email;

          ## If the subreqest returns 200 pass to the backend, if the subrequest returns 401 redirect to the portal.
          error_page 401 =302 https://auth.codecaptured.com/?rd=$target_url;
        '';
      };
    };
in
{
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule vhostOptions);
  };
}
