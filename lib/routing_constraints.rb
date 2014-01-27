class Subdomain
  def self.matches?(request)
    request.subdomain.present? && !['www', 'my', 'my.staging', 'localhost'].include?(request.subdomain)
  end
end

class MainDomain
  def self.matches?(request)
    !Subdomain.matches?(request)
  end
end

