Pod::Spec.new do |s|
  s.name                  = 'PasseiExecutable'
  s.version               = '0.0.1'
  s.summary               = 'Terminal Executable'
  s.swift_version         = '6.0'
  s.description           = <<-DESC "Commandline Executable"
  process
  DESC
  s.homepage              = 'https://github.com/ziminny/PasseiExecutable'
  s.license               = { :type => 'PASSEI-GROUP', :file => 'LICENSE' }
  s.authors               = { 'Vagner Oliveira' => 'ziminny@gmail.com' }
  s.source                = { :git => 'https://github.com/ziminny/PasseiExecutable.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.6'
  s.osx.deployment_target = '13.0'
  s.source_files          = 'PasseiExecutable/Classes/**/*' 
  s.dependency 'PasseiLogManager'
  end