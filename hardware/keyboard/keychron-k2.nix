# Keyboard layout configuration for Keychron K2 (US Layout - Windows/Android Mode)
{ ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";        # Sets the layout to United States
      variant = "";         # Standard US layout
    };
  };

  # Ensures the console (TTY) matches the US layout
  console.keyMap = "us";
}
