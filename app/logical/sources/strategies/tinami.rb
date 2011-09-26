module Sources
  module Strategies
    class Tinami < Base
      attr_reader :artist_name, :profile_url, :image_url, :tags

      def self.url_match?(url)
        url =~ /^https?:\/\/(?:\w+\.)?tinami\.com/
      end

      def site_name
        "Tinami"
      end
      
      def get
        url = URI.parse(normalized_url).request_uri
        agent.get(url) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = get_tags_from_page(page)
        end
      end
      
      def normalized_url
        url
      end
      
      def unique_id
        profile_url =~ /\/profile\/(\d+)/
        "tinami" + $1
      end
      
    protected
      def get_profile_from_page(page)
        links = page.search("div.prof a")

        if links.any?
          profile_url = "http://www.tinami.com" + links[0]["href"]
        else
          profile_url = nil
        end
        
        links = page.search("div.prof p a strong")
        
        if links.any?
          artist_name = links[0].text
        else
          artist_name = nil
        end
        
        return [artist_name, profile_url].compact
      end
      
      def get_image_url_from_page(page)
        img = page.search("img.captify[rel=caption]").first
        if img
          img.attr("src")
        else
          nil
        end
      end
      
      def get_tags_from_page(page)
        links = page.search("div.tag a")

        links.map do |node|
          [node.text, "http://www.tinami.com" + node.attr("href")]
        end
      end
    
      def agent
        @agent ||= begin
          mech = Mechanize.new

          mech.get("http://www.tinami.com/login") do |page|
            page.form_with do |form|
              form["action_login"] = "true"
              form['username'] = "r888888888@gmail.com"
              form['password'] = "uroobnad556"
              form["rem"] = "1"
            end.click_button
          end

          mech
        end
      end
    end
  end
end
