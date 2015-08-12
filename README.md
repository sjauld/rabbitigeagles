# Hello!

This is a simple app to track the results of a betting syndicate.

Each week the syndicate puts in 1 tip per person (6 in total), then we bet on the 3x, 4x, 5x and 6x combinations.

Skeleton based on https://github.com/bootstrap-ruby/sinatra-bootstrap

# Install

I just deploy the thing to Heroku but you could put it wherever. Clone it and then run the following setup:
```
rake db:migrate
rake assets:precompile (heroku does this for you)
```

# Configure

If you had a different betting pattern you could just edit routes/gamblor.rb#calculate_payout to match what you're doing. At the moment it looks like this:
```
def calculate_payout(tips)
  # we use all 6x, 5x, 4x and 3x combinations
  total = 0
  (3..6).each do |i|
    total += tips.map{|x| x.odds.to_f}.combination(i).to_a.map{|x| x.reduce(:*)}.reduce(:+).to_f
  end
  return total
end
```
I guess I could manage this in config, but at the moment this is it!
