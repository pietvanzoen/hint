task default: %w[lint test]

task :test do
  ruby "test/hint_test.rb"
end

task :lint do
  sh "bundle exec rubocop"
end

task :fmt do
  sh "bundle exec rufo ."
end
