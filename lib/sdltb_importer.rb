require 'sdltb_importer/version'
require 'mdb'
require 'open-uri'
require 'pretty_strings'

module SdltbImporter
  class Sdltb
    LANGUAGE_GROUP_REGEX = /<lG[^>]*>(.*?)<\/lG>/m
    TERM_REGEX = /<t>(.*?)<\/t>/m
    LANGUAGE_REGEX = /(?<=[^cn]lang=\S)\S{2,5}(?=")/
    DEFINITION_REGEX = /<d type="Definition">(.*?)<\/d>/m

    attr_reader :file_path
    def initialize(file_path:)
      @file_path = file_path
      @doc = {
        source_language: "",
        target_language: "",
        tc: { id: "", counter: 0, vals: [], creation_date: "", definition: "" },
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
      db[:mtConcepts].each_with_index do |record, index|
        @doc[:tc][:definition] = PrettyStrings::Cleaner.new(record[:text].scan(DEFINITION_REGEX).flatten[0]).pretty.gsub("\\","&#92;").gsub("'",%q(\\\'))
        generate_unique_id
        @doc[:term][:counter] += record[:text].scan(TERM_REGEX).length
        language_groups = record[:text].scan(LANGUAGE_GROUP_REGEX).flatten
        language_groups.each_with_index do |lg, i|
          @doc[:term][:lang] = lg.scan(LANGUAGE_REGEX).flatten[0]
          if i.eql?(0)
            @doc[:source_language] = @doc[:term][:lang]
          else
            @doc[:language_pairs] << [@doc[:source_language], @doc[:term][:lang]]
          end
          lg.scan(TERM_REGEX).flatten.each do |term|
            write_term(term)
          end
        end
      end
    end

    def write_term(text)
      return if text.nil? || text.empty?
      text = PrettyStrings::Cleaner.new(text).pretty.gsub("\\","&#92;").gsub("'",%q(\\\'))
      @doc[:term][:vals] << [@doc[:tc][:id], @doc[:term][:lang], nil, text]
    end

    def generate_unique_id
      @doc[:tc][:id] = [(1..4).map{rand(10)}.join(''), Time.now.to_i, @doc[:tc][:counter] += 1 ].join("-")
      @doc[:tc][:vals] << [@doc[:tc][:id], @doc[:tc][:definition]]
      @doc[:tc][:definition] = ''
    end
  end
end
