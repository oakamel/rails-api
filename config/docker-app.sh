#! /bin/sh

# Wait for MySQL
until nc -z -v -w30 db 3306; do
 echo 'Waiting for MySQL...'
 sleep 1
done
echo "MySQL is up and running!"
bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate
bundle exec rails server -b 0.0.0.0 -p 3000