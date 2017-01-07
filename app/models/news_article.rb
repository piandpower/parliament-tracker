class NewsArticle < ActiveRecord::Base
  # THIS ADDED ON JAN 6, 2017
  has_and_belongs_to_many :members

  def self.scrape_cbc
    @@cbc_xml = open("http://rss.cbc.ca/lineup/politics.xml")
    stories = Hash.from_xml(@@cbc_xml)['rss']['channel']['item']

    Member.all.each do |member|
      stories.each do |story|
        if story['title'].include?(member.fullname[2..-1])  || story['description'].include?(member.fullname[2..-1])
          article = NewsArticle.find_or_create_by(
            link: story["link"],
            title: story["title"],
            outlet: "CBC",
            date: Date.parse(story["pubDate"]),
          )
          # article.description = story['description'],
          member.news_articles << article
          article.save!
        end
      end
    end

  end
end
