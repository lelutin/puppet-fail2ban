# frozen_string_literal: true

require 'spec_helper'

describe 'fail2ban' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it 'installs before configuring' do
        is_expected.to contain_class('fail2ban::install').
          that_comes_before('Class[fail2ban::config]')
      end

      it 'configures before managing the service' do
        is_expected.to contain_class('fail2ban::config').
          that_notifies('Class[fail2ban::service]')
      end

      # ------------------------------------------------------------------
      # Default behaviour
      # ------------------------------------------------------------------
      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('fail2ban') }
        it { is_expected.to contain_class('fail2ban::install') }
        it { is_expected.to contain_class('fail2ban::config') }
        it { is_expected.to contain_class('fail2ban::service') }

        it 'installs the fail2ban package' do
          is_expected.to contain_package('fail2ban').with_ensure('installed')
        end

        it 'enables and starts the fail2ban service' do
          is_expected.to contain_service('fail2ban').
            with_ensure('running').
            with_enable(true)
        end

        it 'manages jail.conf' do
          is_expected.to contain_file('/etc/fail2ban/jail.conf').
            with_ensure('file').
            with_owner('root').
            with_group('0')
        end

        it 'manages fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_ensure('file').
            with_owner('root').
            with_group('0')
        end

        it 'removes .local files by default' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.local').
            with_ensure('absent')
          is_expected.to contain_file('/etc/fail2ban/jail.local').
            with_ensure('absent')
        end

        it 'purges fail2ban.d directory by default' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.d').
            with_ensure('directory').
            with_purge(true).
            with_recurse(true)
        end

        it 'purges jail.d directory by default' do
          is_expected.to contain_file('/etc/fail2ban/jail.d').
            with_ensure('directory').
            with_purge(true).
            with_recurse(true)
        end
      end

      # ------------------------------------------------------------------
      # module global options
      # ------------------------------------------------------------------
      context 'with rm_fail2ban_local set to false' do
        let(:params) { { rm_fail2ban_local: false } }

        it 'does not remove fail2ban.local' do
          is_expected.not_to contain_file('/etc/fail2ban/fail2ban.local')
        end
      end

      context 'with rm_jail_local set to false' do
        let(:params) { { rm_jail_local: false } }

        it 'does not remove jail.local' do
          is_expected.not_to contain_file('/etc/fail2ban/jail.local')
        end
      end

      context 'with purge_fail2ban_dot_d set to false' do
        let(:params) { { purge_fail2ban_dot_d: false } }

        it 'does not purge fail2ban.d' do
          is_expected.not_to contain_file('/etc/fail2ban/fail2ban.d')
        end
      end

      context 'with purge_jail_dot_d set to false' do
        let(:params) { { purge_jail_dot_d: false } }

        it 'does not manage jail.d' do
          is_expected.not_to contain_file('/etc/fail2ban/jail.d')
        end
      end

      context 'with config_file_mode set to 0640' do
        let(:params) { { config_file_mode: '0640' } }

        it 'sets mode on config files' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_mode('0640')
          is_expected.to contain_file('/etc/fail2ban/jail.conf').
            with_mode('0640')
        end
      end

      context 'with manage_service set to false' do
        let(:params) { { manage_service: false } }

        it 'does not manage the service' do
          is_expected.not_to contain_service('fail2ban')
        end
      end

      # ------------------------------------------------------------------
      # fail2ban.conf settings
      # ------------------------------------------------------------------

      # TODO: how can we test the behavior of fail2ban_conf_template? : possibly
      # with a fixture file! err hmm but how do I mock out the call to `epp()` ?
      #
      # context 'with fail2ban_conf_template set to a template path' do
      #   let (:params) {{
      #     fail2ban_conf_template: "spec/fixtures/files/fail2ban_conf_template.epp",
      #     bantime: 12345
      #   }}

      #   it "writes fail2ban.conf using the given template" do
      #     allow(Puppet::Parser::Functions::epp).to receive(:epp).with("spec/fixtures/files/fail2ban_conf_template.epp").and_return("# test template\nbantime=<%= $bantime %>")
      #     is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
      #       with_content("# test template\nbantime=12345")
      #   end
      # end

      context 'with loglvl set to DEBUG' do
        let(:params) { { loglvl: 'DEBUG' } }

        it 'writes loglevel into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{loglevel\s*=\s*DEBUG})
        end
      end

      context 'with logtarget set to a custom path' do
        let(:params) { { logtarget: '/var/log/fail2ban.log' } }

        it 'writes logtarget into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{logtarget\s*=\s*/var/log/fail2ban\.log})
        end
      end

      context 'with syslogsocket set to a custom path' do
        let(:params) { { syslogsocket: '/var/run/syslog.custom.socket' } }

        it 'writes syslogsocket into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{syslogsocket\s*=\s*/var/run/syslog\.custom\.socket})
        end
      end

      context 'with socket set to a custom path' do
        let(:params) { { socket: '/var/run/fail2ban.custom.socket' } }

        it 'writes socket into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{socket\s*=\s*/var/run/fail2ban\.custom\.socket})
        end
      end

      context 'with pidfile set to a custom path' do
        let(:params) { { pidfile: '/var/run/fail2ban.custom.pidfile' } }

        it 'writes pidfile into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{pidfile\s*=\s*/var/run/fail2ban\.custom\.pidfile})
        end
      end

      context 'with allowipv6 set to false' do
        let(:params) { { allowipv6: false } }

        it 'writes allowipv6 into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{allowipv6\s*=\s*false})
        end
      end

      context 'with dbfile set to a custom path' do
        let(:params) { { dbfile: '/var/lib/fail2ban/custom.sqlite3' } }

        it 'writes dbfile into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{dbfile\s*=\s*/var/lib/fail2ban/custom\.sqlite3})
        end
      end

      context 'with dbpurgeage set to two days' do
        let(:params) { { dbpurgeage: 172_800 } }

        it 'writes dbpurgeage into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{dbpurgeage\s*=\s*172800})
        end
      end

      context 'with dbmaxmatches set to 25' do
        let(:params) { { dbmaxmatches: 25 } }

        it 'writes dbmaxmatches into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{dbmaxmatches\s*=\s*25})
        end
      end

      context 'with stacksize set to 64' do
        let(:params) { { stacksize: 64 } }

        it 'writes stacksize into fail2ban.conf' do
          is_expected.to contain_file('/etc/fail2ban/fail2ban.conf').
            with_content(%r{stacksize\s*=\s*64})
        end
      end

      # ------------------------------------------------------------------
      # jail.conf global defaults
      # ------------------------------------------------------------------
      option_fixtures = {
        'enabled' => true,
        'mode' => 'strict',
        'backend' => 'systemd',
        'usedns' => 'no',
        'filter' => 'custom-default',
        'logpath' => ['/var/log/tothemoon', '/var/log/launchpad'],
        'logencoding' => 'utf-8',
        'logtimezone' => 'UTC',
        'prefregex' => 'this.*message',
        'failregex' => ['user failed to .*'],
        'ignoreregex' => ['(ai|script kiddie) chatbot being annoying again'],
        'ignoreself' => false,
        'ignoreip' => ['127.0.0.1', '10.0.0.1'],
        'ignorecommand' => '/usr/bin/true',
        'ignorecache' => 'key="<F-USER>@<ip-host>", max-count=100, max-time=5',
        'maxretry' => 5,
        'maxlines' => 3,
        'maxmatches' => 10,
        'findtime' => 1800,
        'action' => ['action1'],
        'bantime' => 3600,
        'banaction' => 'nftables',
        'banaction_allports' => 'nft_allports_expiring',
        'chain' => 'lightning',
        'port' => '100,200,300,410',
        'protocol' => 'udp',
        'mta' => 'sendmail',
        'destemail' => 'admin@example.com',
        'sender' => 'fail2ban@yourserver.com',
      }
      if facts[:os]['family'] == 'Debian'
        option_fixtures.update({
                                 'fail2ban_agent' => 'Mozilla Firefox no truly Chrome but in fact fail2ban',
                                 'datepattern' => '%Y-%m-%d standard earth core time',
                               })
      end

      option_fixtures.each do |key, value|
        context "with #{key} set to #{value}" do
          let(:params) { { key => value } }

          test_pattern = if value.is_a?(Array)
                           value.map { |v| Regexp.escape(v) }.join(%r{\n#{" " * (key.length + 3)}}.to_s)
                         else
                           Regexp.escape(value.to_s)
                         end

          it "writes #{key} into jail.conf" do
            is_expected.to contain_file('/etc/fail2ban/jail.conf').
              with_content(%r{^#{key} = #{test_pattern}$})
          end
        end
      end

      # Options that don't trivially ouptut in the config file:
      context 'with bantime_extra set' do
        formula = 'ban.Time * (1<<(ban.Count if ban.Count<20 else 20)) * banFactor'
        let(:params) { { 'bantime_extra' => { 'increment' => true, 'formula' => formula } } }

        it 'writes individual suboptions to jail.conf' do
          is_expected.to contain_file('/etc/fail2ban/jail.conf').
            with_content(%r{^bantime.increment = true$}).
            with_content(%r{^bantime.formula = #{Regexp.escape(formula)}$})
        end
      end
    end
  end
end
