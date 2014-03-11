#coding: UTF-8
module Kinopoisk
  class Search
    attr_accessor :query, :url, :page

    def initialize(query)
      @query = query
      @url   = SEARCH_URL + URI.escape(query.to_s)
    end

    # Returns an array containing Kinopoisk::Movie instances
    def movies
      parse unless page
      @movies ||= find_nodes('film').map{|n| new_movie n }
    end

    # Returns an array containing Kinopoisk::Person instances
    def people
      parse unless page
      @people ||= find_nodes('name').map{|n| new_person n }
    end

    private

    def parse
      @page = Kinopoisk.fetch url
      case page.status
      when 200
        @doc = Nokogiri::HTML(page.body.encode('utf-8'))
      when 302
        @movies = [Movie.new(page.headers['Location'].to_s.match(/film\/(\d+)/)[1].to_i)]
        @people = []
      else
        raise Kinopoisk::NotFound
      end
    end

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
      Movie.new parse_id(node, 'film'), movie_attributes_from_node(node)
    end

    def new_person(node)
      Person.new parse_id(node, 'name'), node.text
    end

    def movie_attributes_from_node(node)
      {
        :title    => node.text.gsub(/\((сериал|видео|тв)\)/i, '').strip,
        :year     => node.parent.css('.year').text.to_i,
        :title_en => en_title_from_node(node)
      }
    end

    def en_title_from_node(node)
      title_parts = node.parent.parent.css('span.gray').first.text.split(',').map(&:strip)
      title_parts.pop if title_parts.present? && title_parts.last.match(/\d+ *мин\Z/)
      title_parts.join ', '
    end
  end
end
