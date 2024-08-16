# rm-jrollo
ReMarkable 2 notes, observations, and scripts for my cybersecurity research project :) 

# Observations

- Linux based ARM tablet
- <img width="988" alt="image" src="https://github.com/user-attachments/assets/d75c649e-5d6f-44bb-8761-bd1886497738">
- Runs Busybox and systemd
- - ????? y bof tho????? busybox has init scripts????
- When you USB into a computer, it will create an Ethernet gadget where you can hit the device at 10.11.99.1
- - There is also a web interface for transferring files from the ReMarkable if you enable it in the settings
- QT6 framework for the interface
- Interface is a proprietary program referred to as "xochitl"
- - Xochitl also does config management for the RM interface - including passcode storage in plaintext :)
  - - All ReMarkable system configs are stored in /home/root/.config/remarkable and can be read with any Unix tools (cat, nano etc)
    - Config parsing is poorly written, or maybe lazily written
    - - "false" and 0" are usable interchangeably
      - If any bool has a value that isn't 0 or false, it's treated as if it's "true"
      - I changed the checkbox for web access bool to "this shouldnt work" and it enabled. 😎
    - They appear to do some input parsing but only on certain options
    - - SSH password for example, will replace ' with ", and also replaced # with the HTML code
      - I tried to comment out the original password and keep it in the config for safekeeping and it replaced it with the HTML code
      - I tried to do lazy command injection with '`"'`" mainipulation to confuse the parser but didn't have any luck
      - - I do genuinely believe the parser is still vulnerable to this, just need to spend some time with it.
- - Xochitl apparently renders directly to the framebuffer on RM2
- - There are some programs that have been ported from RM1 to RM2 to support the new framebuffer tech, but not everything works out of the box
- Every process runs under root
- - Root password is found under the licenses section of settings
- - Interestingly, that would mean that you can install a SSH key on a device, or write a password down, and get access
- - If you have a PIN code on the device and don't have the root password, there is no way to get into it (officially)
- - Remember that /home/root/xochitl.conf is in plantext on disk 😎 
- Unofficially, you can use a series of jigs on both the USB C port as well as the pogo pins on the side to kick it into recovery mode
- Recovery mode will let you mount partitions as well as chroot into the ReMarkable's OS
- This means you can gain completely unauthenticated access to data on the machine. The parts are cheap, too, under $20 for everything you need.

# Current projects or research ideas

- ssh-remarkable-hostkey.sh - script to automatically remove every ReMarkable device in your host key's so you don't get annoying errors when SSHing to multiple ReMarkables.
- - Yes this is a very first world problem to have, shut up.
  - Progress: not started yet
- ssh-remarkable - in my .zshrc i have: `alias ssh-remarkable="ssh root@10.11.99.1"
-   - this is basically because I just got tired of forgetting to write root@
- ssh-remarkable-logo - automatically convert an input image to a new logo for ReMarkable2, and push it to the device.
- - Wrapper for rm2-img
  - Progress: not started yet
- Want to change some text in the interface somewhere
- - Ideas for vulnerabilities:
  - - SSH password
    -   - Confirmed, this will pass text from xochitl.conf
        - There appear to be some escape vulnerabilities here, I just need to find it (see notes in Obserations above for details)
    - Open source license files
    - String editing the QT6 menus
    - API for web access locally
    - API for ReMarkable clound sync
   
This readme is a living document, and will update as I find more stuff.
