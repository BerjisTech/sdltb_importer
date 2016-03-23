require 'spec_helper'

describe SdltbImporter do
  it 'has a version number' do
    expect(SdltbImporter::VERSION).not_to be nil
  end

  describe '#stats' do
    it 'reports the stats of a .sdltb file 1' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_1.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.stats).to eq({:tc_count=>144, :term_count=>300, :language_pairs=>[["DE", "EN"]]})
    end

    it 'reports the stats of a .sdltb file 2' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_2.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.stats).to eq({:tc_count=>10, :term_count=>24, :language_pairs=>[["DE", "NL"]]})
    end

    it 'reports the stats of a .sdltb file 3' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_3.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.stats).to eq({:tc_count=>904, :term_count=>9571, :language_pairs=>[["DE", "EN-GB"], ["DE", "PL"], ["DE", "HU"], ["DE", "CS"], ["DE", "SL"], ["DE", "TR"], ["DE", "PT"], ["DE", "IT"], ["DE", "DA"], ["DE", "FR"]]})
    end
  end

  describe '#import' do
    it 'imports a .sdltb file 1' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_1.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[0].length).to eq(144)
    end

    it 'imports a .sdltb file 1' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_1.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[1].length).to eq(300)
    end

    it 'imports a .sdltb file 2' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_2.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[0].length).to eq(10)
    end

    it 'imports a .sdltb file 2' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_2.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[1].length).to eq(24)
    end

    it 'imports a .sdltb file 3' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_3.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[0].length).to eq(904)
    end

    it 'imports a .sdltb file 3' do
      file_path = File.expand_path('../sdltb_importer/spec/sample_files/sample_3.sdltb')
      sdltb = SdltbImporter::Sdltb.new(file_path: file_path)
      expect(sdltb.import[0].length).to eq(9571)
    end
  end
end
