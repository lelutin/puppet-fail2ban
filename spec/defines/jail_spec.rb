# frozen_string_literal: true

require 'spec_helper'

describe 'fail2ban::jail' do
  let(:title) { 'test_jail' }
  let(:pre_condition) { 'include fail2ban' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      # Minimal param requirement
      let(:params) do
        { 'logpath' => ['/var/log/test.log'] }
      end

      # ------------------------------------------------------------------
      # Mandatory / minimal parameters
      # ------------------------------------------------------------------
      context 'with minimum required parameters (logpath only)' do
        it { is_expected.to compile.with_all_deps }

        it 'creates a jail config file in jail.d' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group(0)
            .with_mode('0644')
            .with_content(%r{^\[test_jail\]$})
            .with_content(%r{^logpath\s*=.*/var/log/test\.log$})
            .that_notifies('Class[fail2ban::service]')
        end
      end

      # ------------------------------------------------------------------
      # ensure => absent
      # ------------------------------------------------------------------
      context 'with ensure => absent' do
        let(:params) do
          super().merge({ 'ensure' => 'absent' })
        end

        it 'removes the jail config file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_ensure('absent')
        end
      end

      context 'with config_file_mode set' do
        let(:params) do
          super().merge({ 'config_file_mode' => '0660' })
        end

        it 'sets the permissions for jail config file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_mode('0660')
        end
      end

      # ------------------------------------------------------------------
      # Optional jail parameters - each should render in the file
      # ------------------------------------------------------------------

      # Take this out once the deprecated type is removed
      context 'with action as a String (deprecated type)' do
        let(:params) do
          super().merge({ 'action' => 'email_santa' })
        end

        before { Puppet.settings[:strict] = :warning }
        after  { Puppet.settings[:strict] = :error }

        it 'expects a deprecation notice' do
          logs = []
          Puppet::Util::Log.newdestination(Puppet::Test::LogCollector.new(logs))
          catalogue
          Puppet::Util::Log.close_all
          expect(logs).to include(an_object_having_attributes(level: :warning, message: include('will only take an array of strings')))
        end

        it 'writes the one action to configuration file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_content(%r{^action = email_santa$})
        end
      end

      # Value 'all' gets transformed to something else
      context 'with port set to all' do
        let(:params) do
          super().merge({ 'port' => 'all' })
        end

        it 'writes port = 1:65535 into the jail file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_content(%r{port\s*=\s*1:65535})
        end
      end

      # Overriding the value above, can't do a simple merge
      context 'with multiple logpath values' do
        let(:params) do
          { 'logpath' => ['/var/log/app1.log', '/var/log/app2.log'] }
        end
        let(:test_pattern) { ['/var/log/app1.log', '/var/log/app2.log'].map { |v| Regexp.escape(v) }.join(%r{\n#{' ' * ('logpath'.length + 3)}}.to_s) }

        it 'writes both log paths into the jail file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_content(%r{^logpath = #{test_pattern}$})
        end
      end

      option_fixtures = {
        'enabled' => true,
        'mode' => 'loosey',
        'backend' => 'pyinotify',
        'usedns' => 'warn',
        'filter' => 'custom_filter',
        'logencoding' => 'ISO-2022-JP-2004',
        'logtimezone' => 'Asia/Tokyo',
        'datepattern' => '%m-%Y-%d aka everything not iso8601 is cursed',
        'prefregex' => '(not )?my cup of (tea|coffee)',
        'failregex' => ['error number [0-9]+', 'major (crash|programmer oops)'],
        'ignoreregex' => ['this is somebody(else)?\'s problem'],
        'ignoreself' => true,
        'ignoreip' => ['192.168.1.0/24', '10.0.0.1'],
        'ignorecommand' => '/opt/lib/you_got_ignored.py',
        'ignorecache' => 'key="<F-USER>@<ip-host>", max-count=40, max-time=30',
        'maxretry' => 10,
        'maxlines' => 30,
        'maxmatches' => '%(maxretry)s',
        'findtime' => 900,
        'action' => ['%(action_mw)s', '%(action_mwl)s'],
        'bantime' => 7200,
        'banaction' => 'nftables-allports',
        'banaction_allports' => 'nope',
        'chain' => 'letter',
        'port' => 'smtp',
        'protocol' => 'tcp',
        'mta' => 'nc',
        'destemail' => 'santa@satan.org',
        'sender' => 'Ho Ho HO',
        'fail2ban_agent' => 'Tor Browser 1.2.3.4.5 - beind great anonymity',
      }

      option_fixtures.each do |key, value|
        context "with #{key} set to #{value}" do
          let(:params) do
            super().merge({ key => value })
          end
          let(:test_pattern) do
            if value.is_a?(Array)
              value.map { |v| Regexp.escape(v) }.join(%r{\n#{' ' * (key.length + 3)}}.to_s)
            else
              Regexp.escape(value.to_s)
            end
          end

          it "writes #{key} into jail.conf" do
            is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
              .with_content(%r{^#{key} = #{test_pattern}$})
          end
        end
      end

      # Option contradictions
      context 'with backend set to systemd and with a logpath defined' do
        let(:params) { super().merge({ 'backend' => 'systemd' }) }

        it { is_expected.not_to compile }
      end

      context 'with backend not systemd but with no logpath set' do
        let(:params) { { 'backend' => 'auto' } }

        it { is_expected.not_to compile }
      end

      # Options that don't trivially ouptut in the config file:
      context 'with bantime_extra set' do
        let(:formula) { 'ban.Time * (1<<(ban.Count if ban.Count<10 else 30)) * banFactor' }
        let(:params) do
          super().merge({
                          'bantime_extra' => {
                            'increment' => false,
                            'formula' => formula,
                            'factor' => '2',
                          },
                        })
        end

        it 'writes individual suboptions to the jail config file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_content(%r{^bantime.increment = false$})
            .with_content(%r{^bantime.formula = #{Regexp.escape(formula)}$})
            .with_content(%r{^bantime.factor = 2})
        end
      end

      context 'with additional_options set' do
        let(:params) do
          super().merge({
                          'additional_options' => {
                            'variable1' => 'value1',
                            'train_of_thoughts' => 'derailed',
                          },
                        })
        end

        it 'writes additional lines in to the jail config file' do
          is_expected.to contain_file('/etc/fail2ban/jail.d/test_jail.conf')
            .with_content(%r{^variable1 = value1$})
            .with_content(%r{^train_of_thoughts = derailed$})
        end
      end
    end
  end
end
