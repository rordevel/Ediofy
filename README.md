Ediofy
================

Dependencies
-------------

This application requires:

- Ruby 2.3.1
- Rails 5.1.7
- PostgreSQL 8.2 or later
- Redis

Getting Started
---------------

Install dependencies and setup database by executing `bin/setup`. Currently, we use DB procedures so loading DB schema doesn't work and all DB migrations need to be run. Execute `bin/rails db:drop db:create db:migrate db:seed`. If you run into issues with seeds run them again using `bin/rails db:seed`.

To run tests prepare DB using `RAILS_ENV=test rails db:drop db:create db:migrate` (just once since we clean DB on each run) and then execute both commands to run all the tests.
```
bin/rails test
bin/rails test:system
```


To deploy the application
```
mina staging deploy
```


To Start workers execute `QUEUE=* rake environment resque:work`
