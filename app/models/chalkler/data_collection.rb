class Chalkler::DataCollection

  PREFIXES   = %w(chalklers data_collection)
  EMAIL_PATH = "email"

  def initialize(chalkler, options = {})
    @chalkler      = chalkler
    @default_path  = options.fetch(:default_path, "")
    @original_path = options[:original_path]
    @add_params    = true
  end

  def path
    result = main_path
    result += with_original_path if add_params?
    result
  end

private

  attr_reader :chalkler, :original_path, :default_path
  attr_accessor :add_params

  def main_path
    return email_path if request_email?
    self.add_params = false
    original_path ? original_path : default_path
  end

  def add_params?
    add_params && original_path
  end

  def with_original_path
    "?original_path=#{CGI::escape(original_path.to_s)}"
  end

  def request_email?
    !!chalkler.email.nil?
  end

  def email_path
    [ prefix_path, EMAIL_PATH ].join("/")
  end

  def prefix_path
    PREFIXES.join("/")
  end

end
