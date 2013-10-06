module Chargify
  class Parser < HTTParty::Parser

    def parse
      begin
        ::Oj.load(body, mode: :compat) unless body.strip.empty?
      rescue Oj::ParseError => e
        raise(Chargify::Error::UnexpectedResponse.new(e.message), body)
      end
    end

  end
end
