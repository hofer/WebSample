task :default => [:compile_all]

@track_server = "192.168.2.10"
build_version = "SNAPSHOT"
project_name = "WebSample"
bin_dir = "./bin_build"
classes_main = "#{bin_dir}/classes/"
classes_compile = "#{bin_dir}/compile/"
classes_unit = "#{bin_dir}/unittest/"

# ****************************************************************************************************
# Dependencies
# ****************************************************************************************************

desc "Download all libraries needed in this project"
task :lib => [:clean] do
  sh "mkdir -p lib/main lib/test"
  sh "java -jar .tools/ivy.jar -ivy ivy.xml -retrieve './lib/[conf]/[artifact](-[classifier])-[revision].[ext]'"
  lib_main = FileList["lib/main/*.jar"]
  lib_main.each do | file_to_delete | 
    sh "rm -rf ./lib/test/#{file_to_delete.split('/').last}"
  end
end

desc "Cleanup lib folder"
task :clean do
  sh "rm -rf lib deploy .sass-cache #{bin_dir}"
end

desc "Setup project"
task :setup do
  # sh "mdkir -p src/main/sass src/main/coffee"
  sh "rm -rf .tools"
  sh "wget http://s3.amazonaws.com/share.marc.hofer.ch/BuildTools.tgz"
  sh "tar -xvzf BuildTools.tgz"
  sh "rm BuildTools.tgz"
  sh "echo '.tools' >> .gitignore"
  sh "mkdir -p src/main/java src/test/unit"
  sh "touch src/MANIFEST.MF"
end

desc "Create Eclipse files"
task :eclipse do
  sh "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>' > .project"
  sh "echo '<projectDescription>' >> .project"
  sh "echo '  <name>#{project_name}</name>' >> .project"
  sh "echo '  <comment></comment>' >> .project"
  sh "echo '  <projects></projects>' >> .project"
  sh "echo '  <buildSpec>' >> .project"
  sh "echo '  <buildCommand>' >> .project"
  sh "echo '    <name>org.eclipse.jdt.core.javabuilder</name>' >> .project"
  sh "echo '    <arguments>' >> .project"
  sh "echo '    </arguments>' >> .project"
  sh "echo '  </buildCommand>' >> .project"
  sh "echo '  </buildSpec>' >> .project"
  sh "echo '  <natures>' >> .project"
  sh "echo '    <nature>org.eclipse.jdt.core.javanature</nature>' >> .project"
  sh "echo '    <nature>org.apache.ivyde.eclipse.ivynature</nature>' >> .project"
  sh "echo '  </natures>' >> .project"
  sh "echo '</projectDescription>' >> .project"

  sh "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>' > .classpath"
  sh "echo '<classpath>' >> .classpath"
  sh "echo '  <classpathentry kind=\"src\" path=\"src/main/java\"/>' >> .classpath"
  sh "echo '  <classpathentry kind=\"src\" path=\"src/test/unit\"/>' >> .classpath"
  sh "echo '  <classpathentry kind=\"con\" path=\"org.eclipse.jdt.launching.JRE_CONTAINER\"/>' >> .classpath"
  sh "echo '  <classpathentry kind=\"con\" path=\"org.apache.ivyde.eclipse.cpcontainer.IVYDE_CONTAINER/?project=#{project_name}&amp;ivyXmlPath=ivy.xml&amp;confs=*\"/>' >> .classpath"
  sh "echo '  <classpathentry kind=\"output\" path=\".bin_build/eclipse\"/>' >> .classpath"
  sh "echo '</classpath>' >> .classpath"
end

# ****************************************************************************************************
# Compile
# ****************************************************************************************************

task :compile_all => [:compile, :compile_unit]

desc "Compile the web application"
task :compile => [:clean, :lib] do
  SRC = FileList["src/main/java/**/*.java"]
  mkdir_p classes_main
#  sh "cp -f ./src/resources/*.properties #{classes_main}"
#  sh "cp -f ./src/resources/logback.xml #{classes_main}"
  sh "javac -cp ./lib/main/*:. -d #{classes_main} #{SRC.join(" ")}"
  sh "cp -f ./src/main/java/ch/websample/template/*.jade #{classes_main}/ch/websample/template/"
end

task :compile_unit => [:compile] do
  src_unit = FileList["src/test/unit/**/*.java"]
  mkdir_p classes_unit
  sh "javac -cp ./lib/main/*:./lib/test/*:#{classes_main}. -d #{classes_unit} #{src_unit.join(" ")}"
end

task :jar => [:compile] do
  mkdir_p "deploy"
  sh "jar -cvmf src/MANIFEST.MF deploy/#{project_name}-#{build_version}.jar -C #{classes_main} ."
end

task :jar_unit => [:compile_unit] do
  mkdir_p "deploy"
  sh "jar -cvf deploy/#{project_name}-#{build_version}-unittest.jar -C #{classes_unit} ."
end

# ****************************************************************************************************
# Test
# ****************************************************************************************************

task :test_unit => [:jar_unit, :jar] do
  JARS = FileList["deploy/*.jar"]
  lib_main = FileList["lib/main/*.jar"]
  lib_test = FileList["lib/test/*.jar"]
  sh "java -cp #{lib_main.join(":")}:#{lib_test.join(":")}:#{JARS.join(":")} org.junit.runner.JUnitCore JadeRendererTest"
end

task :test => [:test_unit]

# ****************************************************************************************************
# Run
# ****************************************************************************************************

task :run => [:package_webapp] do
  sh "cd deploy && unzip WebSample-SNAPSHOT.zip"
  sh "cd deploy/WebSample && java -cp 'lib/*:.' ch.websample.WebSample"
end

# ****************************************************************************************************
# Package
# ****************************************************************************************************

task :package => [:clean, :package_webapp, :package_test, :doc_jar, :sources_jar]

task :package_webapp => [:jar, :process_css, :process_js] do
  tmp_dir = "#{project_name}"
  mkdir_p "deploy/#{tmp_dir}/lib"
  sh "cp deploy/#{project_name}-#{build_version}.jar deploy/#{tmp_dir}/lib/#{project_name}-#{build_version}.jar"
  sh "cp lib/main/*.jar deploy/#{tmp_dir}/lib/"
  sh "cp -r src/main/webapp deploy/#{tmp_dir}/"
  sh "cd deploy && zip -r -b #{tmp_dir}/ #{project_name}-#{build_version} #{tmp_dir}/*"
  sh "rm -rf deploy/#{project_name}-#{build_version}.jar deploy/#{tmp_dir}"
  create_distribution_files("#{project_name}-#{build_version}", "zip")
end

task :package_test => [:jar_unit] do
#  tmp_dir = "#{project_name}"
#  mkdir_p "deploy/#{tmp_dir}/lib"
#  sh "cp deploy/#{project_name}-#{build_version}.jar deploy/#{tmp_dir}/lib/#{project_name}-#{build_version}.jar"
#  sh "cp lib/main/*.jar deploy/#{tmp_dir}/lib/"
#  sh "cp -r src/main/webapp deploy/#{tmp_dir}/"
#  sh "cp tools/scripts/galleryshop2webapp.startscript deploy/galleryshop2/start-server.sh"
#  sh "cp tools/scripts/galleryshop2webapp.stopscript deploy/galleryshop2/stop-server.sh"
#  sh "cp tools/scripts/galleryshop2webapp.initscript deploy/galleryshop2/galleryshop2webapp"
#  sh "cd deploy && zip -r -b #{tmp_dir}/ #{project_name}-#{build_version} #{tmp_dir}/*"
#  sh "rm -rf deploy/#{project_name}-#{build_version}.jar deploy/#{tmp_dir}"
#  create_distribution_files("#{project_name}-#{build_version}", "zip")
end

# ****************************************************************************************************
# JavaScript and CSS processing
# ****************************************************************************************************

task :csslint do
  sh "java -jar .tools/rhino.jar .tools/csslint-rhino.js --rules=zero-units,shorthand,vendor-prefix,gradients,regex-selectors ./src/main/css/ --quiet"
end

task :jslint do
  sh "java -jar .tools/rhino.jar .tools/fulljslint.js $@ maxerr=25,evil=true,browser=true,eqeqeq=true,immed=true,newcap=false,es5=true,rhino=true,white=false,devel=false"
end

task :process_js do
  tmp_dir = "#{bin_dir}/tmp_js"
  SRC = FileList["src/main/coffee/**/*.coffee"]
  process_script( tmp_dir,
                  "coffee -c -o #{tmp_dir} -j #{tmp_dir}/#{project_name}_coffee.js #{SRC.join(" ")}", 
                  "js")
end

task :process_css do
  tmp_dir = "#{bin_dir}/tmp_css"
  process_script( tmp_dir,
                  "sass src/main/sass/#{project_name}.scss:#{tmp_dir}/#{project_name}.css", 
                  "css")  
end

# ****************************************************************************************************
# Doc, code analysis ...
# ****************************************************************************************************

task :doc_jar => :clean do
  SRC = FileList["src/main/java/**/*.java"]
  doc_dir = "deploy/tmp_doc"
  sh "rm -rf #{doc_dir}"
  mkdir_p "#{doc_dir}"
  sh "javadoc -classpath ./lib/main/*:. -d #{doc_dir} #{SRC.join(" ")}"
  sh "jar -cvf deploy/#{project_name}-#{build_version}-javadoc.jar -C #{doc_dir} ."
  sh "rm -rf #{doc_dir}"
  create_distribution_files("#{project_name}-#{build_version}-javadoc", "jar")
end

task :sources_jar => :clean do
  mkdir_p "deploy/"
  sh "jar -cvf deploy/#{project_name}-#{build_version}-sources.jar -C src/main/java/ ."
  create_distribution_files("#{project_name}-#{build_version}-sources", "jar")
end

# ****************************************************************************************************
# Helper functions:
# ****************************************************************************************************

def minify(input_dir, output_file_name, file_type)
  input_file_name = "tmp.#{file_type}"
  files_to_concat = Dir.new(input_dir).entries
  files_to_concat.keep_if{|v| !File.directory?(v) && v != ".DS_Store"}.sort.each do | file_to_concat |
    sh "echo '\n' >> #{input_file_name}"
    sh "cat #{input_dir}/#{file_to_concat} >> #{input_file_name}"
  end
  sh "java -jar .tools/yuicompressor-2.4.6.jar --line-break 8000 -o #{output_file_name} #{input_file_name}"
  sh "rm #{input_file_name}"
end

def process_script(tmp_dir, command, file_type)
  mkdir_p tmp_dir
  out_dir = "./src/main/webapp/static"
  file_name = "#{out_dir}/all.min.#{file_type}"
  sh "rm -rf #{tmp_dir}/* #{file_name}"
  sh "mkdir -p #{out_dir}"
  sh command
  if File.directory?("./src/main/#{file_type}")
    sh "cp src/main/#{file_type}/* #{tmp_dir}"
  end
  minify(tmp_dir, file_name, file_type)
end

def create_distribution_files(file_name, file_extension)
  create_checkfiles(file_name, file_extension)
  create_torrent("#{file_name}.#{file_extension}", "#{file_name}.torrent")  
end

def create_checkfiles(file_to_check, file_extension)
  sh "cd deploy && md5 -q #{file_to_check}.#{file_extension} > #{file_to_check}.md5"
  sh "cd deploy && openssl sha1 #{file_to_check}.#{file_extension} > #{file_to_check}.sha1"
  
  # Sign:
  #sh "cd deploy && gpg -a --output #{file_to_check}.sig --detach-sig #{file_to_check}.#{file_extension}"
end

def create_torrent(package_name, torrent_name)
  sh "java -cp .tools/ttorrent-1.0.4.jar:. com.turn.ttorrent.common.Torrent deploy/#{torrent_name} #{@track_server} deploy/#{package_name}"  
end
