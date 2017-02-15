Bundler.require(:default)

APP_ROOT = File.expand_path(File.dirname(__FILE__))
require_relative 'app/cash_machine_api'
require_relative 'app/file_storage'
require_relative 'app/transaction'
require_relative 'app/cash_machine'
