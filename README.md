# Chalkle
*Taking learning out of the classroom*

The online platform for Learners and teachers to connect. 

## Development Environment Setup

### Requirements

* ruby 1.9.3 – best to use [rb env](https://github.com/sstephenson/rbenv)
* [qt](http://qt-project.org) – to install use homebrew: `brew install qt`

### Instructions

1. Run `bundle install`
2. copy `config/database.yml.pg` to `config/database.yml` and modify to suit your particular postgres setup
3. Create your databases using `rake db:create`
4. Build the database schema using `rake db:schema:load` 

## Deployment

### Deploy to staging
_TK_

### Deploy to Production
_TK_