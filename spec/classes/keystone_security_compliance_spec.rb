require 'spec_helper'

describe 'keystone::security_compliance' do
  shared_examples_for 'keystone security_compliance' do
    it 'should configure security compliance defaults' do
      is_expected.to contain_keystone_config('security_compliance/change_password_upon_first_use').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/disable_user_account_days_inactive').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/lockout_duration').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/lockout_failure_attempts').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/minimum_password_age').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/password_expires_days').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/password_regex').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/password_regex_description').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_keystone_config('security_compliance/unique_last_password_count').with_value('<SERVICE DEFAULT>')
    end

    context 'with specific params' do
      let :params do
        {
          :change_password_upon_first_use     => true,
          :disable_user_account_days_inactive => 1,
          :lockout_duration                   => 2,
          :lockout_failure_attempts           => 3,
          :minimum_password_age               => 4,
          :password_expires_days              => 5,
          :password_regex                     => 'SomeRegex',
          :password_regex_description         => 'this is some regex',
          :unique_last_password_count         => 6,
        }
      end
      it 'should have configure security compliance with params' do
        is_expected.to contain_keystone_config('security_compliance/change_password_upon_first_use').with_value(true)
        is_expected.to contain_keystone_config('security_compliance/disable_user_account_days_inactive').with_value(1)
        is_expected.to contain_keystone_config('security_compliance/lockout_duration').with_value(2)
        is_expected.to contain_keystone_config('security_compliance/lockout_failure_attempts').with_value(3)
        is_expected.to contain_keystone_config('security_compliance/minimum_password_age').with_value(4)
        is_expected.to contain_keystone_config('security_compliance/password_expires_days').with_value(5)
        is_expected.to contain_keystone_config('security_compliance/password_regex').with_value('SomeRegex')
        is_expected.to contain_keystone_config('security_compliance/password_regex_description').with_value('this is some regex')
        is_expected.to contain_keystone_config('security_compliance/unique_last_password_count').with_value(6)
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'keystone security_compliance'
    end
  end
end
