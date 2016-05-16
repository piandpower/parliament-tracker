class Bill < ActiveRecord::Base
  belongs_to :member
  has_many :vote_tallies

  def bill_number
    return "#{self.prefix}-#{self.number}"
  end

  # Download bills xml, convert to Hash
  def self.scrape_bills
    @@bills_xml = open("http://www.parl.gc.ca/LEGISInfo/Home.aspx?language=E&ParliamentSession=42-1&Mode=1&download=xml").read
    @@bills = Hash.from_xml(@@bills_xml)['Bills']['Bill'] # Scraped Array of bills
  end

  def self.create_bills(bills=@@bills)
    bills.each do |bill|
      new_bill = Bill.find_or_create_by(parliament_number: bill["id"])

      new_bill.prefix = bill["BillNumber"]["prefix"] if new_bill.prefix == nil
      new_bill.number = bill["BillNumber"]["number"] if new_bill.number == nil
      new_bill.date_introduced = bill["BillIntroducedDate"].to_date if new_bill.date_introduced == nil
      new_bill.bill_type = bill["BillType"]["Title"][0] if new_bill.bill_type == nil
      new_bill.title_long = bill["BillTitle"]["Title"][0] if new_bill.title_long == nil
      if (new_bill.title_short == nil) && (bill["ShortTitle"]["Title"][0].class == String)
        new_bill.title_short = bill["ShortTitle"]["Title"][0]
      end

      new_bill.member = Member.find_by(
        firstname: bill["SponsorAffiliation"]["Person"]["FirstName"],
        lastname: bill["SponsorAffiliation"]["Person"]["LastName"]
      )

      new_bill.get_vote_tallies
      new_bill.save!
    end
  end

  # TEST THIS ALL
  # Doesn't account for MPs no longer serving
  def get_vote_tallies
    base_uri = "http://www.parl.gc.ca"
    votes_uri = base_uri + "/LEGISInfo/BillDetails.aspx?Language=E&Mode=1&billId=#{self.parliament_number}&View=5"
    votes_page = Nokogiri::HTML(open(votes_uri))
    # votes = votes_page.css(".VoteLink")
    vote_links = votes_page.css(".VoteLink").select { |vote| vote.attr('href') }

    vote_links.each do |vote_link|
      new_tally = VoteTally.create_vote_tally(base_uri + vote_link.attr('href'))
      self.vote_tallies << new_tally
    end
  end

end
