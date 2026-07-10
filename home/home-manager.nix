{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # System-wide Home Manager settings
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.admin = { pkgs, ... }: {
    
    # Import your structural package modules here
    imports = [
      ../packages/environment-packages.nix
    ];

    # User Profile Definition
    home.username = "admin";
    home.homeDirectory = "/home/admin";

    # Dotfiles & File management
    home.file.".config/mango/config.conf".text = ''
      # ==============================================================================
      # MANGO WINDOW MANAGER (MangoWM) DEFAULT CONFIGURATION
      # ==============================================================================
    
      env=XDG_CURRENT_DESKTOP,mango
      env=XDG_SESSION_TYPE,wayland
      env=QT_QPA_PLATFORM,wayland
      env=GDK_BACKEND,wayland,x11
    
      gappih=6
      gappoh=6
      borderpx=3
    
      focuscolor=0xc9b890ff
      unfocuscolor=0x444444ff
    
      blur=1
      shadows=1
      border_radius=8
      focused_opacity=1.0
      unfocused_opacity=0.85
    
      animations=1
      animation_type_open=slide
      animation_duration_open=400
      animation_type_close=fade
      animation_duration_close=300
    
      xkb_rules_layout=us
      repeat_rate=25
      repeat_delay=600
    
      tap_to_click=1
      mouse_natural_scrolling=0
      click_method=2
    
      keymode=common
      bind=SUPER,r,reload_config    
    
      keymode=default
      bind=ALT,Return,spawn,foot           
      bind=ALT,space,spawn,bemenu-run
      bind=ALT,q,killclient                  
      bind=SUPER,m,quit                       
    
      bind=ALT,Left,movefocus,l
      bind=ALT,Right,movefocus,r
      bind=ALT,Up,movefocus,u
      bind=ALT,Down,movefocus,d
    
      bind=SUPER,f,toggle_fullscreen
      bind=ALT,Backslash,toggle_floating
    
      bind=SUPER,1,view,1
      bind=SUPER,2,view,2
      bind=SUPER,3,view,3
      bind=SUPER,4,view,4
      bind=SUPER,5,view,5
    
      bind=SUPER+SHIFT,1,movewindowtotag,1
      bind=SUPER+SHIFT,2,movewindowtotag,2
      bind=SUPER+SHIFT,3,movewindowtotag,3
      bind=SUPER+SHIFT,4,movewindowtotag,4
      bind=SUPER+SHIFT,5,movewindowtotag,5
    
      bind=SUPER,space,nextlayout
    
      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:scroller
      tagrule=id:3,layout_name:monocle
      tagrule=id:4,layout_name:grid
    
      monitorrule=name:HDMI-A-1,width:2560,height:1440,refresh:60,x:0,y:0
      monitorrule=name:DP-1,width:2560,height:1440,refresh:60,x:0,y:1440
    '';

    # Programs & Services
    programs.git = {
      enable = true;
    };

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    programs.home-manager.enable = true;
    home.stateVersion = "26.05"; 
  };
}
