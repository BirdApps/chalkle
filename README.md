# Chalkle
*Taking learning out of the classroom*

The online platform for Learners and teachers to connect.

## Development Environment Setup

### Requirements

* Ruby 2.1.5
* PostgreSQL 9.4.4

### Instructions

1. Run `bundle install`
1. copy `config/database.yml.pg` to `config/database.yml`, including your db's username/password
1. Create your databases using `rake db:create`
1. Build the database schema using `rake db:schema:load`

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

View open issues and upcoming features on [Jira](https://chalkle.atlassian.net/projects/CHAL/issues/CHAL-493?filter=allopenissues)
Mandrill is used to view and send emails.
Swipe HQ is used to accept payments.
Contact Josh Dean (josh@chalkle.com) if access is needed to these services.

## Deployment

Deployment can currently be performed by Matthew Kerr (contact at matthew@chalkle.com)
or by Josh Dean (contact at josh@chalkle.com)
