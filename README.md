# Bookie

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To check health of the application please visit http://localhost/api/health it'll give you all details regarding API health.

To learn more aobut APIs please visit below link.

https://documenter.getpostman.com/view/830312/S1TZyG3h?version=latest

* Database expected in codebase is MySql, You can also use Postgres by changing the driver in dev.exs file and installing the dependecy.

```
NOTE: As MySQL driver doesn't support the new auth system implemented by MySql so you have to create a new user with previous auth system in case you are using latest MySQL database.
Streategy expected for authorization.
`elixir | mysql_native_password`

In latest streategy you will see root  | caching_sha2_password if you run this command
select user,plugin from mysql.user;
so change this streategy and you are good to go.
```

In case any issue you can mail me at

`yatender[dot]nitk[at]outlook[dot]com`