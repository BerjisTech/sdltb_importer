require 'sdltb_importer/version'
require 'mdb'
require 'open-uri'
require 'pretty_strings'

module SdltbImporter
  class Sdltb
    LANGUAGE_GROUP_REGEX = /<lG>(.*?)<\/lG>/
    TERM_REGEX = /<t>(.*?)<\/t>/
    LANGUAGE_REGEX = /(?<=[^cn]lang=\S)\S{2,5}(?=")/

    attr_reader :file_path
    def initialize(file_path:)
      @file_path = file_path
      @doc = {
        source_language: "",
        target_language: "",
        tc: { id: "", counter: 0, vals: [], creation_date: "" },
        term: { lang: "", counter: 0, vals: [], role: "" },
        language_pairs: []
      }
    end

    def stats
      imported_data
      { tc_count: @doc[:tc][:counter], term_count: @doc[:term][:counter], language_pairs: @doc[:language_pairs].uniq }
    end

    def import
      imported_data
      [@doc[:tc][:vals], @doc[:term][:vals]]
    end

    private

    def imported_data
      @imported_data ||= import_data
    end

    def import_data
      db = Mdb.open(open(file_path).path)
      @doc[:tc][:counter] = db[:mtConcepts].length
      db[:mtConcepts].each_with_index do |record, index|
        @doc[:term][:counter] += record[:text].scan(TERM_REGEX).length
        language_groups = record[:text].scan(LANGUAGE_GROUP_REGEX).flatten
        language_groups.each_with_index do |lg, index|
          language = lg.scan(LANGUAGE_REGEX).flatten[0]
          if index.eql?(0)
            @doc[:source_language] = language
          else
            @doc[:language_pairs] << [@doc[:source_language], language]
          end
          term = lg.scan(TERM_REGEX).flatten[0]
        end
      end

      # puts db[:mtIndexes] #Language Pairs
      # puts db[:mtFields]
      # puts db[:mtFieldsValues]
      # puts db[:I_German]
      # puts db[:I_English]
    end

    def iso_timestamp(timestamp)
      timestamp.delete('-').delete(':').sub(' ','T') + 'Z'
    end
  end
end
