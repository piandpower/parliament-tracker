module MemberHelper

  def sort_votes_by_date(limit=nil)
    sorted_votes = Vote.where(member_id: @member.id).limit(limit).joins(:vote_tally).order('vote_tallies.date DESC')
  end

  def name_with_honorific
    @member.honorific ? "#{@member.honorific} #{@member.fullname}" : @member.fullname
  end

  def sort_bills_by_date(limit=nil)
    sorted_bills = Bill.where(member_id: @member.id).limit(limit).joins(:member).order('bills.last_event_date DESC')
  end

end
