tag = `git describe --exact-match --abbrev=0 --tags 2> /dev/null`.strip
hash = `git log --pretty="%h" -1`.strip

VERSION_NUMBER = tag.blank? ? hash : tag