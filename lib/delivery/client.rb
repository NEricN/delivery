require 'httparty'
require 'hashie'
require 'json'

module Delivery
  class Client
    include HTTParty

    attr_accessor :client_id, :authentication_token, :base_uri

    def initialize(client_id, authentication_token, options={})
      @client_id = client_id
      @authentication_token = authentication_token

      options[:base_uri] ||= 'https://api.delivery.com'
      @base_uri = options[:base_uri]
    end

    def search(address, options={})
      get('/merchant/search/delivery', {address: address}.merge(options))
    end
    alias_method :merchant_search, :search

    def info(id, options={})
      get("/merchant/#{id}", options)
    end
    alias_method :merchant_info, :info

    def menu(id, options={})
      get("/merchant/#{id}/menu", options)
    end
    alias_method :merchant_menu, :menu

    def hours(id, options={})
      get("/merchant/#{id}/hours", options)
    end
    alias_method :merchant_hours, :hours

    def add_to_cart(id, order_type, items, options={})
      post("/customer/cart/#{id}", {order_type: order_type, items: items}.merge(options))
    end

    def cart(id, options={})
      get("/customer/cart/#{id}", options)
    end

    def clear_cart(id, cart_index=nil, options={})
      delete("/customer/cart/#{id}", {cart_index: cart_index}.merge(options))
    end

    def get_checkout(id, options={})
      get("/customer/cart/#{id}/checkout", options)
    end

    def checkout(id, location_id, payments, options={})
      post("/customer/cart/#{id}/checkout", {location_id: location_id, payments: payments}.merge(options))
    end

    def payments(options={})
      get("/customer/cc", options)
    end

    def add_location(location, options={})
      post("/customer/location", location.merge(options))
    end

    def locations(options={})
      get("/customer/location", options)
    end

    private

    def get(path, options={})
      http_verb :get, path, options
    end

    def post(path, options={})
      http_verb :post, path, options
    end

    def delete(path, options={})
      http_verb :delete, path, options
    end

    def http_verb(verb, path, options={})
      response = self.class.send(verb, "#{base_uri}#{path}", { headers: {
        "Authorization" => authentication_token,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'},
       body: {client_id: client_id}.merge(options).to_json})
      Hashie::Mash.new(JSON.parse(response.body))
    end
  end
end
