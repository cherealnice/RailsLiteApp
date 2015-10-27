require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
    @params = {}
    @params = parse_www_encoded_form(req.query_string) unless req.query_string.nil?
    @route_params = route_params
    end


    def [](key)
      @params[key.to_sym]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      decoded_array = URI::decode_www_form(www_encoded_form)
      values = []
      paths = []
      params = {}

      decoded_array.each do |(keypath, value)|
        level = params
        parsed_key = parse_key(keypath)
        parsed_key.each_with_index do |key, index|

          if index == parsed_key.length - 1
            level[key] = value
          else
            level[key] ||= {}
            level = level[key]
          end
        end
      end

      params
    end


    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split('[').map{ |a| a.gsub(']', '') }
    end
  end
end
