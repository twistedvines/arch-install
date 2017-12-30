# frozen_string_literal: true

require 'spec_helper'

describe 'FS Table' do
  # we only need to test its existence because we've already tested
  # mount points in another spec.
  describe file '/etc/fstab' do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
  end
end

describe 'Timezone configuration' do
  let(:timezone) do
    command('timedatectl status | grep "Time zone" | cut -d":" -f2').stdout
  end

  it 'sets the timezone to Europe/London' do
    expect(timezone)
      .to match(/Europe\/London/)
  end
end

describe 'Locale configuration' do
  describe 'Available locales' do
    let(:locale_gen) { command('cat /etc/locale.gen').stdout }
    it 'specifies the British UTF-8 locale' do
      expect(locale_gen)
        .to match(/en_GB\.UTF-8 UTF-8/)
    end

    it 'specifies the British ISO-8859-1 locale' do
      expect(locale_gen)
        .to match(/en_GB ISO-8859-1/)
    end
  end

  describe 'Configured locales' do
    let(:locale_conf) { command('cat /etc/locale.conf').stdout }
    it 'specifies the British English language' do
      expect(locale_conf)
        .to match(/LANG=en_GB\.UTF-8/)
    end
  end
end

describe 'Keyboard configuration' do
  let(:vconsole_conf) { command('cat /etc/vconsole.conf').stdout }
  it 'sets the KEYMAP to "uk"' do
    expect(vconsole_conf)
      .to match(/KEYMAP=uk/)
  end
end

describe 'Hostname configuration' do
  let(:hostname) { command('hostname -f').stdout }

  it 'sets the hostname' do
    expect(hostname)
      .to match(/arch-linux/)
  end
end

describe 'Enabled services' do
  describe 'dhcpcd' do
    let(:is_enabled) { command('systemctl is-enabled dhcpcd').stdout }
    it 'is enabled' do
      expect(is_enabled)
        .to match(/enabled/)
    end
  end

  describe 'sshd' do
    let(:is_enabled) { command('systemctl is-enabled sshd').stdout }
    it 'is enabled' do
      expect(is_enabled)
        .to match(/enabled/)
    end
  end
end
