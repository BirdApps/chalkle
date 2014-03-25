class Subdomain
  def self.matches?(request)
    request.subdomain.present? && !['www', 'my', 'localhost'].include?(request.subdomain.split('.').first)
  end
end

class MainDomain
  def self.matches?(request)
    !Subdomain.matches?(request)
  end
end

