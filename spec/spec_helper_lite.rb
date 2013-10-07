require 'rspec'

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))

if !defined?(Rails)
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'app', 'models')
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'app', 'controllers')
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'app', 'helpers')
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'app', 'logic')
  $LOAD_PATH.unshift File.join(ROOT_PATH, 'lib')
end
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "support"))

require 'active_support/core_ext/module/delegation'

