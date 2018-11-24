desc "Install"
task default: %w[install]

desc "Run tests"
task :test do
  ruby "test/hint_test.rb"
end

desc "Run linter"
task :lint do
  sh "bundle exec rubocop"
end

desc "Format ruby code"
task :fmt do
  sh "bundle exec rufo ."
end

desc "Install files to ~/.hint or $HINT_DIR"
task :install do
  hint_dir = ENV["HINT_DIR"] || "#{Dir.home}/.hint"
  puts "Creating #{hint_dir}"
  FileUtils.mkdir_p(hint_dir)
  puts "Copying files"
  FileUtils.rm_rf("#{hint_dir}/bin")
  FileUtils.rm_rf("#{hint_dir}/lib")
  FileUtils.cp_r("./bin", hint_dir)
  FileUtils.cp_r("./lib", hint_dir)
  puts "
Add the following to your shell config:
  export PATH=\"$HOME/.hint/bin:$PATH\"
  "
end
