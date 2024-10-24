# rm-jrollo
ReMarkable 2 notes, observations, and scripts for my cybersecurity research project :)

## Update 10-23-24

Well, unfortunately I had to give back my loaner device. The only reason I was able to do this in the first place
was because work had a free unit after someone left and specifically because I asked to do cybersecurity research on it.
I was told after I started using the device for normal work things to see how the software works, that I was not allowed
to use it in this manner and it was specifically just for cybersecurity research. That hampered my efforts quite a bit,
so my exploring the software turned into more of just jailbreaking the device and seeing what it *could* be used for,
while not actually being able to use it for any of these use cases I discovered. As you can imagine, progress slowed
quite a bit after this occured.

As such, this repo will now be put public, updated with all the notes I currently have and was in the middle of writing.
I would like to pick up a used one, especialy since now the insanely priced Pro model is out.

I bet I can find a cheap RM2 somewhere in the future very easily. I still have a lot of research to do :)

# Observations

- Linux based ARM tablet running a 5.x kernel (I think 5.15 but I don't remember 100%)
- <img width="988" alt="image" src="https://github.com/user-attachments/assets/d75c649e-5d6f-44bb-8761-bd1886497738">
- Runs Busybox and systemd
- - ????? busybox has init scripts, why both?
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
- Using this jig you can 100% exfiltrate any data you want from the device, given enough time to access any device.
- There is no disk encryption whatsoever :(
- Files are stored in the /home/root/ directory and very easily accessible.
- Files are stored in folders that are named as random UUID's
- There are several individual components of each folder that makes up the entire "file" you access in the interface.
- One manages metadata, like last edited time, what page you were on etc.
- The other is the content itself, and the final one is a thumbnail.
- You can manually generate UUID's and store files in these directories and the device will just read them. There is no validation or blessing process.
- There is however a specific mechanism to tell the UI to show the new files. I have not figured out how to do this without restarting the xochitl process.
- The web interface you can access with a direct wire connection will trigger this refresh without a process restart. Need to check devtools or do some pcaps.

# Current projects or research ideas

- ssh-remarkable-hostkey.sh - script to automatically remove every ReMarkable device in your host key's so you don't get annoying errors when SSHing to multiple ReMarkables.
  - Yes this is a very first world problem to have, shut up.
  - Progress: Mostly complete. Still has a few todo's.
- ssh-remarkable - in my .zshrc i have: `alias ssh-remarkable="ssh root@10.11.99.1"
    - this is basically because I just got tired of forgetting to write root@
- ssh-remarkable-logo - automatically convert an input image to a new logo for ReMarkable2, and push it to the device.
  - Wrapper for rm2-img
  - Device uses uboot, so this is fairly trivial once the image is converted, which this repo does perfectly.
  - I recommend using solid B/W images, and make sure you read the resolution requirements carefully. The images will be incorrectly rotated if you aren't careful.
  - Progress: The process is totally working manually. We just need to clean it up a tiny bit and write the bash script to make it nice.
  - tldr use main.py in rm2-img to convert the image, then upload it.
  - `scp splash.dat root@10.11.99.1:/var/lib/uboot/splash.dat` is the command we used. Make sure you take a backup of the original file :) 
- ssh-sync.sh - Copy files to your ReMarkable via SSH.
  - This will basically just generate a UUID, create the directory, and copy the file.
  - We could *probably* generate a thumbnail and metadata on the fly, but realistically I will just use a blank thumbnail if required and a templete for the metadata.
- Want to change some text in the interface somewhere, like rename a menu or add a custom button somewhere.
  - Ideas for vulnerabilities:
  - - SSH password
    -   - Confirmed, this will pass text from xochitl.conf
        - There appear to be some escape vulnerabilities here, I just need to find it (see notes in Obserations above for details)
    - Open source license files
    - String editing the QT6 menus
      - Binary editing? The packages don't seem signed, so if the QT code is compiled directly into binaries this might be the only way.
    - API for web access locally
    - API for ReMarkable clound sync
- Can you use the ReMarkable as an external monitor for Windows?
  - Yes! There is a program to add a VNC server to it.
  - Unfortunately, there was a firmware update to the ReMarkable 2 that changed how the framebuffer worked, among other nonsense.
  - There is however a way to get around this, buuuuut you will quickly run into another problem: it's kind of impossible to load software on newer firmwares.
- Is there a package manager?
  - The ReMarkable uses opkg to install programs manually.
  - There is a community applicatin/repository, toltec, which is super nifty however it only runs on *very* out of date firmwares.
- Can you downgrade?
  - Yes! Very easily! You can litearlly just acquire the firmware file and write it to flash via a standard copy operation in a SSH session.
  - Yes! This is VERY dangerous! Mess it up and the only recovery method is via the recovery jig!
- Can you get file persistence?
  - Trivially, in fact. Remember, nothing is encrypted or signed. In fact installing toltec will actually warn you that this can damage your device.
  - Factory reset on the device just wipes /home/root so any changes outside that are *permanent*.
   
This readme is a living document, and will update as I find more stuff.
