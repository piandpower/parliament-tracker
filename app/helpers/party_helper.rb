module PartyHelper

  def party_geo
    geo = "{ \"type\": \"FeatureCollection\", \"features\": ["
    @party.electoral_districts.each do |district|
      if district.geo != nil || "null"
        geo += district.geo + ", "
      end
    end
    geo = geo[0..-3] + "] }"
  end

end
