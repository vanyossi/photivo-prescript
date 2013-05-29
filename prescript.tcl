#!/usr/bin/wish
#-----------------------::Photivo Prescript::------------------------
# IvanYossi colorathis.wordpress.com ghevan@gmail.com  GPL 3.0
#--------------------------------------------------------------------
# Goal: create ptj job files from pts templates selecting files from
# file managers, image organizers, etc.
# Dependencies: Tk 8.5, Photivo
#--------------------------------------------------------------------
# Disclamer: I'm not a developer, I learn programming on my spare time. Some if not
# many bugs will be present.

#--====User defined variables

# Accepted files
set ::ext ".jpg .tiff .nef"
# Configuration file dir. set at call time with -pts
set ::ptsdir "~/"
# Output dir for created pts files. set at call time with -ptsout
set ::ptsoutdir "~/"
# Default output dir for developed images. set at call time with -out
set ::outdir "~/"

#--====Program start
#Function to send message boxes
proc alert {type icon title msg} {
		tk_messageBox -type $type -icon $icon -title $title \
		-message $msg
}

proc runJobs {joblist} {

	proc progressUpdate { { current false } { max false } { create false } } {
		if {[string is integer $current]} {
			set ::cur $current
		}
		if {$max} {
			.act.pbar configure -maximum $max
			update
			return
		}
		if {$create} {
			#Draw progressbar
			pack [ ttk::progressbar .act.pbar -maximum $create -variable ::cur -length "300" ] -side left -fill x -padx 2 -pady 0
			update
			return
		}
		incr ::cur
		update
	}
	frame .act -bd 6
	pack .act -expand 1 -fill x
	progressUpdate 0 0 [llength $joblist]

	set ago 0
	foreach i $joblist {
		#catch { exec photivo -j $i } msg
		if { [catch { exec photivo -j $i } msg] } {
				append lstmsg "EE: $i discarted\n"
				puts $msg
				continue
		}
		progressUpdate
		incr ago
	}
	alert ok info "$ago operations Done\n" "Messages:\n$lstmsg"
	exit
}

#Overrides script set directories for argument defined directories
proc setDirs {} {
	foreach {arg value} $::argv {
		if { [string range $arg 0 1 ] eq {-j} } {
			runJobs [lrange $::argv 1 end]
		}
		if { [string index $arg 0] eq {-} && [file isdirectory $value]} {
			set ::[string trim $arg {-}]dir $value
		} else {
			break
		}
	}
}

#Validates a list of files based on their extension
proc argValidate {items filter} {
	#-Check if we have files to work on, if not, finish program.
	if {[catch $items] == 0 } { 
		#alert ok info "Operation Done" "No files selected Exiting"
		puts "No files selected, exiting"
		exit
	}
	# For each element of th elist check if their extension is in the permited ones, it it is
	# normalize file path and append to new list.
	set flist {}
	foreach i $items {
		set filext [string tolower [file extension $i] ]
		if { [lsearch $filter $filext] >= 0} {
			lappend flist [file normalize $i]
			continue
		}
#
#		if { $filext eq ".pts" || $filext eq ".ptj"} {
#			set ::sourcepts $i
#		}
	}
	return $flist
}
# Prepares filelist to be compatible with Photivo filename list format
proc compatList {files} {
	return [join $files {, } ]
}
# Get all files from directory matching criteria (.pts and .ptj)
proc getPresets {} {
	catch { set files [glob -directory $::ptsdir *.pt?]} msg
	set presets [argValidate $files {.ptj .pts}]
	return $presets
}
# Reads base format preset file format, divides and create a new file with the new values
proc makeJobfile { line_key arguments preset_file } {
	# Open file for reading
	set file_data [open $::ptsdir$preset_file]
	set source_data [read $file_data]
	close $file_data

	#Create insertion points for key=value to alter
	set lstart [string first $line_key $source_data]
	set lend [string first "\n" $source_data $lstart]

	#If key is missing, read data and split each line into a lit element
	if { $lstart == -1 } {
		set data_list [split $source_data "\n"]
		# Add our element to the correct place in file.
#[lsearch -regexp $data_list "IncludeExif"]+1
		set data_list [linsert $data_list 195 $line_key$arguments]
#[lsearch -regexp $data_list "OutputColorProfilesDirectory"]+1
		# In this case, pts file, there is no outputdir but is needed.
		set outdir [file normalize $::outdir]
		set data_list [linsert $data_list 299 "OutputDirectory=$outdir"]
		# Finally we join the list again using new line as separator.
		set final_data [join $data_list "\n"]	

	} else {
		# If there is a key, use it to split the file and insert file list.
		set part1 [string range $source_data 0 $lstart-1 ]
		append part2 $line_key $arguments
		set part3 [string range $source_data $lend+1 end-1 ]

		append final_data $part1 $part2 $part3
	}
	# Create a new file in pstoutdir directory with suffix aut-
	set ptsoutdir [file normalize $::ptsoutdir]
	set newfile [file join $ptsoutdir "aut-[file rootname $preset_file].ptj"]
	# Open file in append mode for writting. (we need to add a rule to check if file exists!)
	set fout [open $newfile a]
  puts $fout $final_data
	close $fout

	#inform user the operation is done, this does not mean eveything wa ok.
	alert ok info "Operation Done\n" "$newfile created"
	exit
}

#Gui control function
proc startGui {} {
	#Get a list of presets available
	set presets [getPresets]
	#Get the list of available files
	set ::filelist [compatList [argValidate $::argv $::ext]]
	#Get total of files to process
	set ::fc [llength $::filelist]

	#Create window
	wm title . "Photivo presets job maker -- $::fc"

	frame .f -bd 2
	pack .f -fill both -expand 1
	#Create widget in one column mode emulating a listbox
	ttk::treeview .f.listbox -selectmode browse
	.f.listbox heading #0 -text "Presets available"
	.f.listbox column #0 -stretch
	#Add column values using the list, we only need the name of the file for display
	foreach i $presets {
		incr j
		.f.listbox insert {} end -id $j -text "[file tail $i]"
	}
	#When the user selects something, send id to get current text selection.
	bind .f.listbox <<TreeviewSelect>> { set ::sourcepts [%W item [%W selection] -text ] }
	
	frame .b -bd 2
	pack .b -side bottom -fill y
	#Create action button.
	ttk::button .b.make -text "Make ptj job file" -cursor hand2 \
		-command {makeJobfile "InputFileNameList=" $::filelist $::sourcepts}

	pack .f.listbox -side top -expand 1 -fill both
	pack .b.make -side bottom

}

#Run option validation
setDirs

#Run program
startGui
