module Picloud
  module Recommendation

    attr_reader :profile_id :image_id :song_ids

    def intialize(profile_id, image_id, song_ids)
      @profile_id = profile_id
      @image_id = image_id
      @song_ids = song_ids
    end
  end
end
