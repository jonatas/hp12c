guard 'livereload' do
  watch('hp12c.rb')
end

guard :rspec, cmd: "rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_files)

  dsl.watch_spec_files_for('hp12c.rb')
end
