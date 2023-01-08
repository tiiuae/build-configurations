# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2022 Unikie

{ config }:

import ../../../spectrum/vm/make-vm.nix { inherit config; } {



    run = config.pkgs.callPackage (
      { writeScript, tmux, appvm-firefox-user-run }:
      writeScript "appvm-firefox-run" ''
        #!/bin/sh
        export TERM=foot
        export TERMINFO_DIRS=/usr/share/terminfo
        export TMPDIR=/run
        export USER=user
        export TMUX_TMPDIR=/run
        export HOME=/run/home/user

        cd $HOME
        while ! test -S '/run/tmux-0/default'; do sleep 1; echo waiting for tmux ; done
        sleep 5

        echo "starting user service"
        ${tmux}/bin/tmux neww su user sh -c "${appvm-firefox-user-run}" 
        ${tmux}/bin/tmux neww su user /bin/sh
        sleep inf
      ''
    ) {
          appvm-firefox-user-run = config.pkgs.callPackage (
              { writeScript, socat, waypipe, firefox-wayland }:
              writeScript "appvm-firefox-user-run" ''
                  #!/bin/sh
                  mkdir /run/home/user/0
                  export XDG_RUNTIME_DIR=/run/home/user/0
                  
                  ${socat}/bin/socat  unix-listen:/run/home/user/waypipe.sock,reuseaddr,fork vsock-connect:2:5000 &
                  sleep 1

                  ${waypipe}/bin/waypipe --display wayland-local-user --socket /run/home/user/waypipe.sock server -- sleep inf &
                  export WAYLAND_DISPLAY=wayland-local-user

                  ${firefox-wayland}/bin/firefox https://spectrum-os.org/
                  /bin/sh
      ''
      ) {};
    };
}
