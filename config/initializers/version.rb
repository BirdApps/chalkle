if Rails.env.development?
  hash = `git log --pretty="%h" -1`.strip
  VERSION_NUMBER = `git log --pretty="%h" -1`.strip
else
  hash = `cd ../repo && git log --pretty="%h" -1`.strip
  VERSION_NUMBER = `cd ../repo && git log --pretty="%h" -1`.strip
end