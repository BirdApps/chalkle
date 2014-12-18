if Rails.env.development? || Rails.env.test?
  I18n.exception_handler = lambda do |exception, locale, key, options|
    raise "missing translation: #{key}"
  end
else
  I18n.exception_handler = lambda do |exception, locale, key, options|
    Airbrake.notify(exception)
    "Sorry, we lost this bit of text."
  end
end

