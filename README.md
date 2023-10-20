# Database Management Systems

## Set up

Clone the repo and run `bundle install`.

Run `rails db:migrate` to set up the database. (If you already set up the database from our project repo, please skip this step.)

## Start server

Run `rails s`

## Import data from CSV to database

Go brower and use `http://127.0.0.1:3001/applicants/savedata` to import data from CSV to database. (Skip this step if you already import data from CSV to database. If you really want to try this step, go `rails console` and run `Applicant.all.destroy_all` and then try this step again.)

After doing this, go go `rails console` and run `Applicant.all`, `Gre.all` ,etc. to see the data.

## Test API

GET `http://127.0.0.1:3001/api/v1/applicantsapi` to see all applications.

GET `http://127.0.0.1:3001/api/v1/applicantsapi/<id>` to search application by id.

POST `http://127.0.0.1:3001/api/v1/applicantsapi` to create a new application.

PUT `http://127.0.0.1:3001/api/v1/applicantsapi/<id>` to update an application.

Beacause we will have different api formats for different functions. So, here I only create the API for the application table. And we can decide what format we will use to manage the data, and what the response we will need for every api url.

My suggestion is `http://127.0.0.1:3001/api/v1/<tablename>/<id>` for update data in tables. And `http://127.0.0.1:3001/api/v1/filter/<item>/<range>` for filter gre score , gender, etc.

## Heroku database migrate

Everytime we make changes on database, run `heroku run rake db:migrate`.

## How to delete everything from Database

`Applicants.all.destroy_all`
