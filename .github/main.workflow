workflow "CI" {
  on = "push"
  resolves = [
    "CI - Ruby 2.5",
    "CI - Ruby 2.6"
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
