workflow "CI" {
  on = "push"
  resolves = ["CI - All"]
}

action "CI - All" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  needs = [
    "CI - Ruby 2.5",
    "CI - Ruby 2.6",
    "CI - Mutant"
  ]
}

action "CI - Ruby 2.5" {
  uses = "docker://ruby:2.5"
  runs = "bash"
  args = ["-c", "gem install bundler:2.0.1 && bundle && bundle exec rake test"]
}

action "CI - Ruby 2.6" {
  uses = "docker://ruby:2.6"
  runs = "bash"
  args = ["-c", "gem install bundler:2.0.1 && bundle && bundle exec rake test"]
}

action "CI - Mutant" {
  uses = "docker://ruby:2.6"
  runs = "bash"
  args = ["-c", "gem install bundler:2.0.1 && bundle && bundle exec mutant --use minitest --include test --include lib --require 'simple_parameter_store' -- 'SimpleParameterStore*'"]
}
