SimpleCov.start 'rails' do
  add_filter 'app/admin'
  add_filter 'app/controllers'

  add_group 'Decorators', 'app/decorators'
end