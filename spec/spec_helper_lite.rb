require 'rspec'

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))

if !defined?(Rails)
  %w(models controllers helpers logic services concerns).each do |folder|
    $LOAD_PATH.unshift File.join(ROOT_PATH, 'app', folder)
  end
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'lib')
end
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "support"))

require 'active_support/core_ext/module/delegation'

