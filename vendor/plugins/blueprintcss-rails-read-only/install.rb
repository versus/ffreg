require 'fileutils'
`unzip #{File.join(File.dirname(__FILE__), 'blueprint.zip')}`
FileUtils.mv(File.join(File.dirname(__FILE__), 'blueprint'), File.join(File.dirname(__FILE__), '../../../public/stylesheets'))