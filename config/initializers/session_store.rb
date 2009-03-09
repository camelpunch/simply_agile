# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simply-agile_session',
  :secret      => '6a935ee9d26f6e94a44ed9f46b3ea9361f880855aa884195e617da9d74083f460f91b6d3adb0745c6a6ddc55fe857c7df28d0a9655a09a7d7ebd1060a756a2a8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
