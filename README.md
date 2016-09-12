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

### Testing
1. Start a redis instance by running `redis-server`
1. Run `rake db:test:prepare`
1. Run `rspec spec`

Mailer specs are currently broken (14 failures) see improvement ticket [here](https://trello.com/c/JpLgdgQe/27-fix-mailer-tests)

### Data Structure

**TODO**

### User Permissions

Users are **Chalklers**
**Provider Admin** are Chalklers with admin permissions over a certain Provider
**Super Admin** can access analytic and payment information at /sudo in addition to holding Provider Admin permissions.
For development purposes create a Super Admin by setting the Chalkler's role => 'super'
In the admin interface content only visible to Super Admin is visually identified as pink.

# Contribution

Enspiralites! Feel free to contribute by way or comments, issues, or pull requests :D Thanks!

View open issues and upcoming features on [trello](https://trello.com/b/gy3n5ZJs/chalkle-spark-sprint)
Mandrill is used to view and send emails.
Swipe HQ is used to accept payments.
Contact Josh Dean (josh@chalkle.com) if access is needed to these services.

## Deployment

Deployment can currently be performed by Genevieve Parkes (genevieve@enspiral.com)
