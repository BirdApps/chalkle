class ClassDigest
  require 'engtagger'
  def initilize(chalkler)
    @chalkler = chalkler
    @courses = recommended_courses
  end

  def tagger
    @tagger ||= EngTagger.new
  end

  def chalkler
    @chalkler
  end

  def courses
    @courses
  end

  def title
    @title ||= ()
  end

  private

    def generate_title
      all_names = @courses.map(&:name).join(' ')
      tagged = tagger.add_tags(all_names)
      nouns = tagger.get_nouns(tagged).sort{|a,b| a[1] <=> b[1]}.map{|kp| kp [0]}
      #nouns >    
    end

end