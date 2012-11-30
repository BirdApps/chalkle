RMeetup::Client.api_key = '7e4a52464f704b4e1ea2a43166b1410'

RMeetup::Fetcher::Base.module_eval do
  def get_response(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Accept-Charset"] = "utf-8"

    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    res.body || raise(NoResponseError.new)
  end
end
