# frozen_string_literal: true

require 'spec_helper'

describe 'fail2ban::filter' do
  let(:title) { 'test_filter' }
  let(:pre_condition) { 'include fail2ban' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      # Mandatory param
      let(:params) { { 'failregexes' => ['Failed login from <HOST>'] } }

      # ------------------------------------------------------------------
      # Minimal required parameters
      # ------------------------------------------------------------------
      context 'with mandatory failregexes' do
        it { is_expected.to compile.with_all_deps }

        it 'creates a filter config file in filter.d' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group(0)
            .with_mode('0644')
            .that_notifies('Class[fail2ban::service]')
            .with_content(%r{^\[Definition\]$})
            .with_content(%r{^failregex = Failed login from <HOST>$})
        end
      end

      context 'with filter_template set to a custom template path' do
        let(:params) do
          super().merge({ 'filter_template' => 'testmodule/custom_filter.epp' })
        end

        it { is_expected.to compile.with_all_deps }

        it 'uses the custom template to render the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{# custom template sentinel})
        end

        it 'does not use output unique to the default template' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .without_content(%r{# Fail2Ban configuration file})
        end
      end

      context 'with ensure => absent' do
        let(:params) do
          super().merge({ 'ensure' => 'absent' })
        end

        it 'removes the filter config file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_ensure('absent')
        end
      end

      # Need to override default value for this param
      context 'with multiple failregexes' do
        let(:params) do
          {
            'failregexes' => [
              'Failed login from <HOST>',
              'Invalid user .* from <HOST>',
            ],
          }
        end

        it 'writes all failregexes into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^failregex = Failed login from <HOST>\n            Invalid user .* from <HOST>$})
        end
      end

      context 'with config_file_mode set' do
        let(:params) do
          super().merge({ 'config_file_mode' => '0754' })
        end

        it 'sets permissions on the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_mode('0754')
        end
      end

      # ------------------------------------------------------------------
      # general configurations
      # ------------------------------------------------------------------

      context 'with init set' do
        let(:params) do
          super().merge({ 'init' => [
                          'table = moo',
                          'timeout = 7d',
                        ] })
        end

        it 'writes init section name and lines into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^\[Init\]\ntable = moo\ntimeout = 7d$})
        end
      end

      context 'with includes set' do
        let(:params) do
          super().merge({ 'includes' => %w[library1 lib2] })
        end

        it 'writes includes section name and before lines into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^\[INCLUDES\]\nbefore = library1\n         lib2$})
        end
      end

      context 'with includes_after set' do
        let(:params) do
          super().merge({ 'includes_after' => %w[library98 lib99] })
        end

        it 'writes includes section name and before lines into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^\[INCLUDES\]\nafter = library98\n        lib99$})
        end
      end

      # ------------------------------------------------------------------
      # filter options
      # ------------------------------------------------------------------

      # key name in file is singular
      context 'with ignoreregexes specified' do
        let(:params) do
          super().merge({
                          'ignoreregexes' => ['success from <HOST>', 'localhost'],
                        })
        end

        it 'writes ignoreregex into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^ignoreregex = success from <HOST>\n              localhost$})
        end
      end

      # param name is not output to file
      context 'with additional_defs specified' do
        let(:params) do
          super().merge({
                          'additional_defs' => [
                            'prefregex = ^%(__prefix_line)sfoo',
                            'localvariable = somethingorother',
                          ],
                        })
        end

        it 'writes additional lines into the filter file' do
          is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
            .with_content(%r{^prefregex = \^%\(__prefix_line\)sfoo\nlocalvariable = somethingorother$})
        end
      end

      option_fixtures = {
        'prefregex' => 'hey they?re',
        'maxlines' => 6,
        'datepattern' => '%Y-%Y-%m-%m-%d-%d',
        'journalmatch' => '_SYSTEMD_UNIT=murmurd.service + _COMM=murmurd',
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
            is_expected.to contain_file('/etc/fail2ban/filter.d/test_filter.conf')
              .with_content(%r{^#{key} = #{test_pattern}$})
          end
        end
      end
    end
  end
end
