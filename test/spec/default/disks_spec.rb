# frozen_string_literal: true
require 'spec_helper'

describe 'partitions' do
  let(:fdisk_devices) do
    command('sudo fdisk -l -o Device')
      .stdout
      .split("\n")[8..-1]
  end

  let(:fdisk_bootables) do
    command('sudo fdisk -l -o Boot')
      .stdout
      .split("\n")[8..-1]
  end

  let(:fdisk_sizes) do
    command('sudo fdisk -l -o Size')
      .stdout
      .split("\n")[8..-1]
  end

  let(:fdisk_types) do
    command('sudo fdisk -l -o Type')
      .stdout
      .split("\n")[8..-1]
  end

  shared_examples 'not_bootable' do |fdisk_bootable_id|
    it 'must not have the bootable flag' do
      expect(fdisk_bootables[fdisk_bootable_id])
        .to be nil
    end
  end

  describe '/dev/sda1' do
    it 'must be present' do
      expect(fdisk_devices.first)
        .to match(Regexp.new('/dev/sda1'))
    end

    it 'must have the bootable flag' do
      expect(fdisk_bootables.first)
        .to match(Regexp.new('\*'))
    end

    it 'must be small (< 350MB)' do
      expect(fdisk_sizes.first.tr('M', '').to_f)
        .to be < 350
    end

    it 'must be of type "Linux"' do
      expect(fdisk_types.first)
        .to eq('Linux')
    end
  end

  describe '/dev/sda2' do
    it 'must be present' do
      expect(fdisk_devices[1])
        .to match(Regexp.new('/dev/sda2'))
    end

    it_behaves_like 'not_bootable', 1

    it 'must be bigger than 3GB' do
      expect(fdisk_sizes[1].tr('G', '').to_f)
        .to be > 3
    end

    it 'must be of type "Linux"' do
      expect(fdisk_types[1])
        .to eq('Linux')
    end
  end

  describe '/dev/sda3' do
    it 'must be present' do
      expect(fdisk_devices[2])
        .to match(Regexp.new('/dev/sda3'))
    end

    it_behaves_like 'not_bootable', 2

    it 'must be bigger than 5GB' do
      expect(fdisk_sizes[2].tr('G', '').to_f)
        .to be > 5
    end

    it 'must be of type "Linux"' do
      expect(fdisk_types[2])
        .to eq('Linux')
    end
  end

  describe '/dev/sda4' do
    it 'must be present' do
      expect(fdisk_devices[3])
        .to match(Regexp.new('/dev/sda4'))
    end

    it_behaves_like 'not_bootable', 3

    it 'must be bigger than 10GB' do
      expect(fdisk_sizes[3].tr('G', '').to_f)
        .to be > 10
    end

    it 'must be of type "Linux"' do
      expect(fdisk_types[3])
        .to eq('Linux')
    end
  end

end
