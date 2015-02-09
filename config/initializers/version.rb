if Rails.env.development?
  hash = `git log --pretty="%h" -1`.strip
  VERSION_NUMBER = `git log --pretty="%h" -1`.strip
else
  hash = `cat REVISION`.strip
  VERSION_NUMBER = `cat REVISION`.strip
end