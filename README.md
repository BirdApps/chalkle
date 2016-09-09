[![Code Climate](https://codeclimate.com/repos/51e495cdc7f3a33ba7001482/badges/3bbdfdbfec9d58bcbe9c/gpa.svg)](https://codeclimate.com/repos/51e495cdc7f3a33ba7001482/feed)
[![Test Coverage](https://codeclimate.com/repos/51e495cdc7f3a33ba7001482/badges/3bbdfdbfec9d58bcbe9c/coverage.svg)](https://codeclimate.com/repos/51e495cdc7f3a33ba7001482/coverage)

# Chalkle
*Taking learning out of the classroom*

The online platform for Learners and teachers to connect.

## Development Environment Setup

### Requirements

* Ruby 2.1.5
* PostgreSQL 9.4.4
* Redis (Ubuntu/Debian: `apt-get install redis-server` OS X: `brew install redis`)

### Instructions

1. Run `bundle install`
1. copy `config/database.yml.pg` to `config/database.yml`, including your db's username/password
1. Create your databases using `rake db:create`
1. Build the database schema using `rake db:schema:load`

# Contribution

Enspiralites! Feel free to contribute by way or comments, issues, or pull requests :D Thanks!

## Deployment

Deployment can currently be performed by Genevieve Parkes (genevieve@enspiral.com)
