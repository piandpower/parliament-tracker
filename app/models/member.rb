class Member < ActiveRecord::Base
  include ActiveModel::Dirty

  belongs_to :party
  belongs_to :electoral_district
  has_many :bills
  has_many :vote_tallies
  has_many :votes
  has_and_belongs_to_many :news_articles

  validates :firstname, presence: true
  validates :lastname, presence: true

  attr_reader :headshot_remote_url
  has_attached_file :headshot
  validates_attachment_content_type :headshot, :content_type => /\Aimage\/.*\Z/

  ### START OF CLASS METHODS ###
  class << self

    # Download members xml, convert to Hash
    def scrape_members
      @@members_xml = open('http://www.parl.gc.ca/Parliamentarians/en/members/export?output=XML').read
      members_hash = Hash.from_xml(@@members_xml)['List']['MemberOfParliament']
      return members_hash
    end

    # Update all members at once.
    def create_members
      members_hash = scrape_members

      members_hash.each do |member|
        new_member = self.find_or_create_by(
          firstname: member["PersonOfficialFirstName"],
          lastname: member["PersonOfficialLastName"]
        )
        new_member.update_member(
          member["PersonShortHonorific"],
          member["FromDateTime"],
          member["CaucusShortName"]
        )
      end
      self.remove_old_members(members_hash)
    end
    handle_asynchronously :create_members

    def remove_old_members(members_hash)
      names = members_hash.map { |m| m["PersonOfficialFirstName"] + " " + m["PersonOfficialLastName"] }
      self.all.each do |member|
        if !member.fullname.in?(names)
          member.remove_from_house
        end
      end
    end
    handle_asynchronously :remove_old_members

  end

  ### END OF CLASS METHODS###
  ### START OF INSTANCE METHODS ###

  # Find MP, if doesn't exist build/scrape with various methods.
  # Called when ElectoralDistrict is built.
  def update_member(honorific, date_elected, party_name)
    self.honorific = honorific
    self.date_elected = date_elected.to_date
    self.party = Party.find_or_create_by(name: party_name)
    scrape_member_info
    save! if changed?
  end

  # Method to scrape MP headshots and emails from www.parl.gc.ca in single method
  def scrape_member_info
    if (headshot_file_name == nil) || (email == nil)

      base_uri = URI(BASE_PARLIAMENT_URI + "/Parliamentarians/en/members/")
      uri_safe_string = I18n.transliterate("#{firstname}-#{lastname}".delete(" .'"))
      bio = Nokogiri::HTML(open(base_uri + uri_safe_string))

      # scrape headshot
      if self.headshot_file_name == nil
        headshot_url = URI.escape(bio.css('div.profile img.picture')[0].attr('src'))
        self.headshot_remote_url(headshot_url)
      end

      # scrape email
      if email == nil
        scrape_email(bio)
      end
      save! if changed?
    end
  end

  def remove_from_house
    self.party = nil
    self.electoral_district = nil
    self.honorific = nil
    self.email = nil
    self.website = nil
    self.sitting = false
    save! if changed?
  end

  # get MP email from www.parl.gc.ca
  def scrape_email(bio)
    attributes = bio.css('.profile.overview.header a')
    attributes.each do |attribute|
      self.email = attribute.content.downcase if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.ca\z/ =~ attribute.content
    end
  end

  # get MP headshot
  def headshot_remote_url(url_value)
    self.headshot = URI.parse(url_value)
    @headshot_remote_url = url_value
  end

  def fullname
    return "#{firstname} #{lastname}"
  end

  # Possible vote % in previous election
  # http://www.elections.ca/Scripts/vis/PastResults?L=e&ED=13002&EV=99&EV_TYPE=6&QID=-1&PAGEID=28
  # ?ED == FEDNUM in electoral_district.geo. Where does this come from?

end
