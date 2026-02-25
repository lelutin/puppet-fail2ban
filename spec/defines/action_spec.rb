# frozen_string_literal: true

require 'spec_helper'

describe 'fail2ban::action' do
  let(:title) { 'test_action' }
  let(:pre_condition) { 'include fail2ban' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) do
        {
          actionban:   ['curl -s -X PUT http://yourapi:8080/theapi/v4/firewall/rules -d "{\"ban\": \"<ip>\"}"'],
          actionunban: ['curl -s -X DELETE http://yourapi:8080/theapi/v4/firewall/rules/1'],
        }
      end

      # ------------------------------------------------------------------
      # Minimal / default
      # ------------------------------------------------------------------
      context 'with only mandatory options, rest is default' do
        it { is_expected.to compile.with_all_deps }

        it 'creates an action config file in action.d' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_ensure('present').
            with_owner('root').
            with_group('0').
            with_mode('0644')
        end

        it 'does not have an [INCLUDES] section' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^(?!.*\[INCLUDES\].*)$})
        end

        it 'includes a [Definition] section' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^\[Definition\]$})
        end

        it 'notifies the fail2ban service' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            that_notifies('Class[fail2ban::service]')
        end

        it 'includes actionban with curl command' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{curl -s -X PUT})
        end

        it 'includes actionunban with curl command' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{curl -s -X DELETE})
        end
      end

      # ------------------------------------------------------------------
      # ensure => absent
      # ------------------------------------------------------------------
      context 'with ensure => absent' do
        let(:params) do
          super().merge({ ensure: 'absent' })
        end

        it 'removes the action config file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_ensure('absent')
        end
      end

      context 'with config_file_mode set' do
        let(:params) do
          super().merge({ config_file_mode: '0640' })
        end

        it 'sets the permissions of action file as specified' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_mode('0640')
        end
      end

      context 'with timeout specified' do
        let(:params) do
          super().merge({ timeout: 2600 })
        end

        it 'writes timeout into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^timeout = 2600$})
        end
      end

      context 'with init specified' do
        let(:params) do
          super().merge({ init: ['var1 = /etc/something', 'protocol = tcp'] })
        end

        it 'writes init lines into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^var1 = /etc/something$}).
            with_content(%r{^protocol = tcp$})
        end
      end

      context 'with includes specified' do
        let(:params) do
          super().merge({ includes: %w[banana chestnuts] })
        end

        it 'has [INCLUDES] section and writes includes "before" into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^\[INCLUDES\]$}).
            with_content(%r{^before = banana\n         chestnuts$})
        end
      end

      context 'with includes_after specified' do
        let(:params) do
          super().merge({ includes_after: %w[tea exercise] })
        end

        it 'has [INCLUDES] section and writes includes "after" into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^\[INCLUDES\]$}).
            with_content(%r{^after = tea\n        exercise$})
        end
      end

      # ------------------------------------------------------------------
      # Action commands
      # ------------------------------------------------------------------
      context 'with actioncheck specified' do
        let(:params) do
          super().merge({ actioncheck: ['iptables -n -L INPUT | grep -q f2b-<name>'] })
        end

        it 'writes actioncheck into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^actioncheck = iptables -n -L INPUT | grep -q f2b-<name>$})
        end
      end

      context 'with actionstart specified' do
        let(:params) do
          super().merge({ actionstart: ['iptables -N f2b-<name>'] })
        end

        it 'writes actionstart into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^actionstart = iptables -N f2b-<name>$})
        end
      end

      context 'with actionstop specified' do
        let(:params) do
          super().merge({ actionstop: ['iptables -F f2b-<name>'] })
        end

        it 'writes actionstop into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^actionstop = iptables -F f2b-<name>$})
        end
      end

      # ------------------------------------------------------------------
      # additional_defs
      # ------------------------------------------------------------------
      context 'with additional_defs' do
        let(:params) do
          super().merge({ additional_defs: ['name = default', 'port = 22'] })
        end

        it 'writes additional_defs into the action file' do
          is_expected.to contain_file('/etc/fail2ban/action.d/test_action.conf').
            with_content(%r{^name = default$}).
            with_content(%r{^port = 22$})
        end
      end
    end
  end
end
