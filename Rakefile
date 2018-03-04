require 'puppetlabs_spec_helper/rake_tasks'

begin
  if Gem::Specification::find_by_name('puppet-lint')
    require 'puppet-lint/tasks/puppet-lint'
    # 2018-03-04
    # For some reason configuration doesn't reach destination and linting is
    # still *only* done on modules in fixtures. So as a workaround we clear the
    # task and redefine it.
    #
    # We should be using:
    #PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp", "pkg/**/*.pp"]
    #
    # The fix in
    # https://github.com/rodjek/puppet-lint/commit/0f2e2db90d5a14382eafbdfebff74048a487372f
    # is present in the gem but it still doesn't work as intended.
    #
    Rake::Task[:lint].clear
    PuppetLint::RakeTask.new :lint do |config|
      config.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp", "pkg/**/*.pp"]
    end
    task :default => [:validate, :lint, :spec]
  end
rescue Gem::LoadError
  task :default => [:validate, :spec]
end
