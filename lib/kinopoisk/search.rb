#coding: UTF-8
module Kinopoisk
  class Search
    attr_accessor :query, :url

    def initialize(query)
      @query = query
      @url   = SEARCH_URL + query.to_s
    end

    def movies
      find_nodes('film').map{|n| new_movie n }
    end

    def people
      find_nodes('people').map{|n| new_person n }
    end

    private

    def doc
      @doc ||= Kinopoisk.parse url
    end

    def find_nodes(type)
      doc.search ".info .name a[href*='/#{type}/']"
    end

    def parse_id(node, type)
      node.attr('href').match(/\/#{type}\/(\d*)\//)[1].to_i
    end

    def new_movie(node)
      Movie.new parse_id(node, 'film'), node.text.gsub(' (сериал)', '')
    end

    def new_person(node)
      Person.new parse_id(node, 'people'), node.text
    end
  end
end
