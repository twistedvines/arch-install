# frozen_string_literal: true
require 'spec_helper'

describe 'mount points' do

  let(:etc_fstab) do
    command('cat /etc/fstab')
      .stdout
      .split("\n")
  end

  let(:blkid) do
    command('sudo blkid')
      .stdout
      .split("\n")
  end

  shared_examples 'mount_points' do |partition_device, mount_point_regex, fs|
    let!(:blkid_line) do
      blkid_line = blkid.select do |line|
        Regexp.new(partition_device).match(line)
      end&.first
    end

    let(:device_uuid) do
      /[0-9a-f]{8}\-([0-9a-f]{4}\-){3}[0-9a-f]{12}/.match(blkid_line)
    end

    it "is mounted on #{partition_device}" do
      expect(
        etc_fstab.select{|line| Regexp.new(device_uuid.to_s).match(line)}&.first
      ).to match(mount_point_regex)
    end

    it "mounts as filesystem #{fs}" do
      expect(
        etc_fstab.select{|line| Regexp.new(device_uuid.to_s).match(line)}&.first
      ).to match(Regexp.new(fs))
    end
  end

  describe '/boot' do
    it_behaves_like 'mount_points', '/dev/sda1', /\s+\/boot\s+/, 'ext2'
  end

  describe '/' do
    it_behaves_like 'mount_points', '/dev/sda2', /\s+\/\s+/, 'ext4'
  end

  describe '/var' do
    it_behaves_like 'mount_points', '/dev/sda3', /\s+\/var\s+/, 'ext4'
  end

  describe '/home' do
    it_behaves_like 'mount_points', '/dev/sda4', /\s+\/home\s+/, 'ext4'
  end
end
