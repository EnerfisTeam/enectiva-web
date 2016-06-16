#!/usr/bin/ruby

require 'digest'
require 'fileutils'
require 'uglifier'
require 'compass'
require 'compass/sass_compiler'

$env = ARGV[0]

#$path = File.join(".", "themes", "hugo-bootstrap")
$assets = File.join("static", "assets-web", "")
$css =  File.join("static", "css", "")
$sass = File.join("static", "sass", "")
$coffee = File.join("static", "coffee")
$manifest = "rev_manifest.json"
$manPath = File.join("data", "#{$manifest}")
$newPath = File.join("#{$assets}", "app.css")

def cleanFolder
	FileUtils.rm_rf("assets-web")
	FileUtils.rm_rf("#{$assets}")
end

def cleanJS
	FileUtils.rm_rf(File.join("#{$coffee}", "_setup.js"))
	FileUtils.rm_rf(File.join("#{$coffee}", "setup.js"))
	FileUtils.rm_rf(File.join("layouts", "partials", "setup.js"))
end

def renameFile
	oldPath = File.join("#{$assets}", "app.css.css")
	FileUtils.mv("#{oldPath}", "#{$newPath}", :force => true)
end

def extractMd5
	$md5css = (Digest::MD5.hexdigest File.read ($newPath))[0...10]
	if $env != "debug"
		$md5js = (Digest::MD5.hexdigest File.read (File.join("#{$assets}", "_application.js")))[0...10]
	else
		$md5js = (Digest::MD5.hexdigest File.read (File.join("#{$assets}", "application.js")))[0...10]
	end
	$md5resp = (Digest::MD5.hexdigest File.read (File.join("#{$coffee}", "respond.src.js")))[0...10]
end

def moveFP
	Dir.open(File.join("assets-web", "fp")).each do |p|
		file = File.join("assets-web", "fp", "#{File.basename(p)}")
		FileUtils.mv "#{file}", "assets-web", :force => true
	end
	FileUtils.rm_r "#{File.join("assets-web", "fp")}"
end

def delfp
 	Dir.open(File.join("assets-web")).each do |p|
		file = File.join("assets-web", "#{File.basename(p)}")
		FileUtils.rm "#{file}", :force => true
	end
	moveFP
end

def renameFingerprint
	Dir.open(File.join("#{$assets}")).each do |p|
		next if File.extname(p) != ".css"
		filename = File.basename(p, File.extname(p))
		a = p[0...3]
		newname = a + "-" + $md5css + ".css"
		fullPathOld = File.join("#{$assets}", "#{p}")
		fullPathNew = File.join("#{$assets}", "#{newname}")
		FileUtils.mv("#{fullPathOld}", "#{fullPathNew}", :force => true)
	end
	newname = "application-" + $md5js + ".js"
	if $env != "debug"
		fullPathOld = File.join("#{$assets}", "_application.js")
	else
		fullPathOld = File.join("#{$assets}", "application.js")
	end
	fullPathNew = File.join("#{$assets}", "#{newname}")
	FileUtils.mv("#{fullPathOld}", "#{fullPathNew}", :force => true)

	name = "respond.src-" + $md5resp + ".js"
	old = File.join("#{$coffee}", "respond.src.js")
	newf = File.join("#{$assets}", "#{name}")
	FileUtils.copy(old, newf)

	%x(cd #{$assets} && git add *.css *.js)
end

def compile
	Compass.add_configuration 'config.rb'
	if $env != "debug"
		Compass.configuration.output_style = :compressed
	else
		Compass.configuration.output_style = :expanded
	end
	Compass.configuration.asset_cache_buster
	Compass.configuration.project_path = Dir.pwd
	Compass.sass_compiler.clean!
	Compass.sass_compiler({ :time => true }).compile!
end

def manifest
	File.open("#{$manPath}", 'w') { |f|
	f << "{\n"
	f << '  "app.css": "app-' + $md5css + '.css"' << ",\n"
	f << '  "application.js": "application-' + $md5js + '.js"' << ",\n"
	f << '  "respond.src.js": "respond.src-' + $md5resp + '.js"' << "\n"
	f << "}\n"
	}
end

def concatCoffee
	File.open(File.join("#{$assets}", "application.js"), 'a') do |mergedfile|
		text = File.open(File.join("#{$coffee}", "jquery.swipebox.js"), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join("#{$coffee}", "jquery.waypoints.js"), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join("#{$coffee}", "slick.js"), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join("#{$coffee}", "app.js.js"), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
		text = File.open(File.join("#{$coffee}", "features.js.js"), 'r').read
		text.each_line do |line|
			mergedfile << line
		end
	end
	setup = File.join("#{$coffee}", "setup.js.js")
	path = File.join("#{$coffee}", "setup.js")
	if $env != "debug"
		FileUtils.cp("#{setup}", "#{path}")
	else
		File.open(path, 'w') do |f|
			f.write Uglifier.compile(File.read(setup))
		end
	end
end

def moveSetup
	if $env != "debug"
		set_new = File.join("#{$coffee}", "_setup.js")
	else
		set_new = File.join("#{$coffee}", "setup.js")
	end

	layout = File.join("layouts", "partials", "setup.js")
	FileUtils.cp("#{set_new}", "#{layout}")
end

def uglifier
	app_old = File.join("#{$assets}", "application.js")
	app_new = File.join("#{$assets}", "_application.js")
	File.open(app_new, 'w') do |f|
		f.write Uglifier.compile(File.read(app_old))
	end
	File.delete(app_old)
	sleep(2)
	set_old = File.join("#{$coffee}", "setup.js")
	set_new = File.join("#{$coffee}", "_setup.js")
	File.open(set_new, 'w') do |f|
		f.write Uglifier.compile(File.read(set_old))
	end
end
if not ARGV.empty?
	if $env != "debug"
		abort("Invalid argumets. Please use debug or empty\nExiting")
	end
end

def copyassets
	FileUtils.cp_r "static/images/.", "assets-web"
	FileUtils.cp_r "static/fonts/.", "assets-web"
end

def copystatic
	FileUtils.cp_r "assets-web/.", "static/assets-web"
	sleep(2)
	FileUtils.rm_r "assets-web"
end

puts "======================================================================"
puts ""
puts ""
puts ""
puts ""
puts ""
if $env == "debug"
	puts "			Compiling in #{$env} mode!! "
else
	puts "			Compiling in normal mode!!"
end
puts ""
puts ""
puts ""
puts ""
puts ""
puts "======================================================================"


# Clean all CSS files of folder and JS
puts "==================================="
puts "  Cleaning CSS and JS folders"
puts "==================================="
cleanFolder
cleanJS
sleep(1)

# Exect the command to compile all SASS files.
puts "==========================="
puts "  Compiling SASS files"
puts "==========================="
copyassets
sleep(1)
compile
sleep(1)
delfp
sleep(1)

# Rename app.css.css to app.css
puts "================================="
puts "  Merging all CSS and all JS"
puts "================================="
renameFile
concatCoffee
if $env != "debug"
	uglifier
end
moveSetup
sleep(1)

# Digest extract md5 hash from file and do a "for" between character 1 and 10
puts "==================="
puts "  Extracting MD5"
puts "==================="
extractMd5
sleep(1)

# Renaming file with fingerprint
puts "==============================================================="
puts "  Renaming app.css to app-#{$md5css}.css "
puts "  Renaming application.js to application-#{$md5js}.js "
puts "  Renaming respond.src.js to respond.src-#{$md5resp}.js "
puts "==============================================================="
renameFingerprint
sleep(1)

# Creating a rev_manifest.json
puts "==============================================="
puts "  Creating rev_manifest.json "
puts "==============================================="
manifest
copystatic
