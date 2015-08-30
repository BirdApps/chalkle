class CourseDigest::CourseDigest
  require 'engtagger'

  def initialize(chalkler)
    @chalkler = chalkler
    @courses = @chalkler.course_notifications.unsent.collect(&:course)
  end

  def tagger
    @tagger ||= EngTagger.new
  end

  def chalkler
    @chalkler
  end

  def courses_this_week
    @courses_this_week ||= (chalkler.following_courses_in_next_week || [])
  end

  def courses
    #(courses_this_week.concat from_providers).uniq
    @courses
  end

  def title
    @title ||= I18n.t("email.digest.subject") #generate_title
  end

  def sent!
    @chalkler.course_notifications.update_all(sent_at: DateTime.current)
  end

  private

    def generate_title
      all_names = courses.map(&:name).join(' ')
      tagged = tagger.add_tags(all_names)
      nouns = tagger.get_nouns(tagged).sort{|a,b| a[1] <=> b[1]}.map{|kp| kp [0]}
      title = nouns.map{|s| s.titleize }.take(5)
      if title.count > nouns.count
        title.join(', ') + ", and more..."
      else
        title = title.join(', ')
        last_comma_index = title.rindex(/,/)
        title.slice(0, last_comma_index)+", and "+ title.slice(last_comma_index+1, title.length)
      end
    end

end