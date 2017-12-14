# frozen_string_literal: true
require 'spec_helper'

describe 'packages' do
  describe 'base group packages' do
    base_packages_list = command("pacman -Sg base | awk '{print $2}'")
      .stdout
      .split("\n")

    base_packages_list.each do |pkg|
      it "installs package #{pkg}" do
        package_query_exitcode = command("pacman -Q #{pkg}").exit_status
        expect(package_query_exitcode)
          .to be 0
      end
    end
  end

  describe 'additional packages' do
    additional_packages = [
      'grub', 'openssh', 'ntp', 'linux', 'sudo', 'git', 'linux-headers'
    ]

    additional_packages.each do |pkg|
      it "installs package #{pkg}" do
        package_query_exitcode = command("pacman -Q #{pkg}").exit_status
        expect(package_query_exitcode)
          .to be 0
      end
    end
  end
end
