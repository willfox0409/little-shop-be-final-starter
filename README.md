# Little Shop

This repository is the completed API for use with the Mod 2 Group Project. The FE repo for Little Shop lives [here](https://github.com/turingschool-examples/little-shop-fe-vite).

This repo can be used as the starter repo for the Mod 2 final project.

## Setup

```ruby
bundle install
rails db:{drop,create,migrate,seed}
```

This repo uses a pgdump file to seed the database. Your `db:seed` command will produce lots of output, and that's normal. 

Run your server with `rails s` and you should be able to access endpoints via localhost:3000.
