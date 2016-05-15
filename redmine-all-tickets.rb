require 'open-uri'
require 'rexml/document'
require 'openssl'


class ReadmineTickets
  REDMINE_HOST = 'redmine.sataku.jp'
  API_KEY = "80f4bc2c0db530c2ef84a3544b96e988adb376d8"
  ALL_ISSUES_API = 'https://%{host}/issues.xml?key=%{key}&status_id=%%2a&limit=%{limit}&page=%{page}'

  ISSUE_LIMIT = 100

  def initialize(a_redmine_host = REDMINE_HOST, a_api_key = API_KEY)
    @issues = Hash.new
    @redmine_host = a_redmine_host
    @api_key = a_api_key
  end

  def printTicketsHash(a_floor_id = 0)
    last_id = 0
    i = 0

    sorted = @issues.sort_by{|key, value| key.to_i }
    sorted.each{|key, value|
      if(a_floor_id < key.to_i) then
        if i % 100 == 0 then
          puts ""
          puts "New Page"
          puts ""
        end

        print "\##{key}_#{value},\n"

        i = i + 1

        last_id = key
      end
    }

    puts ""

    last_id
  end

  def getTicketsFromAPI()
    uri = ALL_ISSUES_API % {:host => @redmine_host, :key => @api_key, :limit => ISSUE_LIMIT, :page => '1'}

    total_count = 0
    page_count = 0

    begin
      # Firstly, get total issues count and calcurate page_count
      open(uri, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) {|f|
        doc = REXML::Document.new(f)

        total_count = doc.elements['issues'].attributes['total_count'].to_s
        page_count = (total_count.to_f / ISSUE_LIMIT).ceil
      }

      puts "Total Issues Count is %{total_count}" % {:total_count => total_count}
      puts "Page Count is %{page_count}" % {:page_count => page_count}

      # Loop until to fetch all pages
      for i in 1..page_count do
        uri = ALL_ISSUES_API % {:host => @redmine_host, :key => @api_key, :limit => ISSUE_LIMIT, :page => i}

        # :ssl_verify_mode prevent self signed certificate error
        open(uri, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) {|f|
          doc = REXML::Document.new(f)

          doc.elements.each('issues/issue') {|e|
            @issues[e.elements['id/text()'].to_s] = e.elements['subject/text()'].to_s
          }
        }
      end

      # printTicketsHash(@issues)

    rescue SocketError
    rescue OpenURI::HTTPError

    end
  end
end
