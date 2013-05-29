Prescript
=================

#About
Small script to easy create Photivo project files from presets using the file manager or an image organizer.

Photivo is great for controled photoshots, one preset to rule all the photos of that day. But if you are like me taking a lot of diferent light settings in one day it might be a little problematic to organize your workflow as photivo does not have a light table.

This script is meant to ease my day. I make a series of general preset.pts (nocturnal.pts, nocturnal-CW.pts, daylight.pts, washed.pts, cyanotipe.pts, etc) files to manage my developing as fast as possible using this script.

### How it works
Prescript for photivo takes a file list and creates a project file to develop them in batch mode. It creates the job file using the settings of a preset file from a list. The preset list is generated from the contents of a folder. After you created all your jobfiles, in ex: under-exp.ptj, over-exp.ptj, optimal.ptj, sharpen.ptj. You can load them to the script ot batch process them using the "-j" flag.

#### Goal
- Easen the developing of colections with photivo
- Use the capabilities of other image organizing softwares to collect files for job files.

###License
GPL 3.0

### Disclamer
I'm not a developer, I learn programming on my spare time.  
I made it for my personal use and I tested it as much as I could to avoid data loss.
 

### Dependencies

- **Tk 8.5:** For Gui.  
- **Photivo:** The main program.
 

# Configure
The first lines of the script can be edited to point to a certain folder location. It is important to define a preset folder to get the best out of this script.

If you do now want to alter the script you can use arguments to set the directories.
- -pts : defines de Preset library folder
- -ptsout : defines where to create the output ptj file
- -outdir : If source preset is a pts, define a location for output images

### Input files
Change the value of ext to allow other files to be loaded. All files extensions in the list are added as files to process by photivo.
```set ::ext ".jpg .tiff .nef"```
to add other raw formats or files.

# Usage

The script can be used in many places. I use it in conjuction with geeqie. creating colections and adding files to jobfiles. Below I summarize some ways of using it along side your file manager or terminal.

## How to run it

- Place script somewhere in your hard drive ( I choose /home/User/.scripts )
- Make script executable if it isn't
```  $sh: chmod u+x artscripttk.tcl ```
- Run the script feeding files as arguments  
```	$sh: /path/to/script/prescript.tcl file1.jpg file2.png file3.ora```
- You can add a bash alias in ~/.bashrc file  
```      alias prescript='~/path/to/script/prescript'```
- And you can feed arguments using "xargs" feed pipe like  
```	find . -name '*.png' -print0 | xargs -0 ~/path/to/script/prescript.tcl```
- Or if you use an alias  
```	find . -name '*.png' -print0 | xargs -0 bash -cil 'prescript "$@"' arg0```

## Use in Context Menus

### XFCE

1. Open thunar>Edit>Configure Custom Actions...  
2. Add New action (+)  
3. Select a Name, Description and Icon.  
4. Add the next line to Command  
     --> ```wish path/to/script/prescript.tcl %N```  
5 In Apperance Conditions Tab, set '*' as file pattern and select  
     Image files  
6. A new submenu appears on right-click of Image Files
7. Select files, right-click , select the item on the menu, use GUI.


### Gnome / Nautilus

You will need "nautilus-actions" package installed.
```sudo apt-get install nautilus-actions```
```emerge nautilus-actions```
etc...

Tested on liveCD Mint 13

1. Open nautilus-actions (terminal 'nautilus-actions-config-tool')
2. Click on the plus (+) symbol to add a new action. (or go to "file > add new action")
3. On the action Tab set "Context Label" with "Prescript"
4. In the Command tab set "Path:" as "/path/to/prescript.tcl" (absolute path)
5. In the same tab set "Parameters" as "%B"
6. On mimetype set Mimetype filter as "*/*" and "must match one of "selected"
7. Hit save.
8. Restart nautilus (On the liveCD I had to)
8. A new submenu appears "Nautilus-actions actions", click it, your action should be there.
9. Select files, right-click , select the item on the menu, use GUI.
10. To get "Prescript TCL" on root context menu, open "nautilus-actions-config-tool", in preferences "runtime preferences" uncheck "Create a root 'Nautilus actions' menu"

(references
http://techthrob.com/2009/03/02/howto-add-items-to-the-right-click-menu-in-nautilus/
http://www.howtogeek.com/116807/how-to-easily-add-custom-right-click-options-to-ubuntus-file-manager/
)

## Use with geeqie

Read this https://colorathis.wordpress.com/2013/04/04/integrating-artscript-with-geeqie
The process is the same, only names and places change a little.
