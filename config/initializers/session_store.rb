# Be sure to restart your server when you modify this file.

Chalkle::Application.config.session_store(
  :cookie_store,
  key: '_chalkle_session1',
  domain: :all,
  tld_length: ActionDispatch::Http::URL.tld_length + 1
)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Chalkle::Application.config.session_store :active_record_store
